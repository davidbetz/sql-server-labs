USE master;
GO

IF DATABASEPROPERTYEX('ClusteredColumnstoreExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ClusteredColumnstoreExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ClusteredColumnstoreExample;
END
GO

CREATE DATABASE ClusteredColumnstoreExample;
GO

USE ClusteredColumnstoreExample;
GO

--ALTER DATABASE ClusteredColumnstoreExample SET RECOVERY SIMPLE;
--GO

DBCC TRACEON (3604);
GO

CREATE FUNCTION dbo.GetLatestInRowPageID(@name varchar(20))
RETURNS INT
AS
BEGIN
	DECLARE @page_id INT;
	SELECT TOP 1 @page_id = allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID(@name), null, null, 'DETAILED') WHERE page_type = 1 ORDER BY allocated_page_page_id DESC;
	RETURN @page_id;
END
GO

CREATE PROC dbo.GenerateData(@count int)
AS
WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < @count
),
Years([Year])
AS
(
	SELECT Years.[Year]
	FROM
	(
		VALUES (2009), (2010), (2011), (2012), (2013), (2014), (2015)
	) Years ([Year])
),
Months ([Month])
AS
(
	SELECT 1
	UNION ALL
	SELECT [Month] + 1
	FROM Months
	WHERE [Month] < 12
)
INSERT CS.FactFinance
SELECT ABS(CHECKSUM(NEWID())) % 51, [Month], [Year], CONVERT(date, CONVERT(VARCHAR(4), [Year]) + RIGHT('0' + CONVERT(VARCHAR(2), [Month]), 2) + '01', 112), NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000)
GO

ALTER DATABASE ClusteredColumnstoreExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

CREATE SCHEMA CS;
GO

CREATE TABLE CS.DimState (
ID tinyint PRIMARY KEY NOT NULL,
NAME char(20) NOT NULL
)
GO

INSERT CS.DimState
VALUES (1, 'Alabama'), (2, 'Alaska'), (3, 'Arizona'), (4, 'Arkansas'), (5, 'California'), (6, 'Colorado'), (7, 'Connecticut'), (8, 'Delaware'), (9, 'Florida'), (10, 'Georgia'), (11, 'Hawaii'), (12, 'Idaho'), (13, 'Illinois'), (14, 'Indiana'), (15, 'Iowa'), (16, 'Kansas'), (17, 'Kentucky'), (18, 'Louisiana'), (19, 'Maine'), (20, 'Maryland'), (21, 'Massachusetts'), (22, 'Michigan'), (23, 'Minnesota'), (24, 'Mississippi'), (25, 'Missouri'), (26, 'Montana'), (27, 'Nebraska'), (28, 'Nevada'), (29, 'NewHampshire'), (30, 'NewJersey'), (31, 'NewMexico'), (32, 'NewYork'), (33, 'NorthCarolina'), (34, 'NorthDakota'), (35, 'Ohio'), (36, 'Oklahoma'), (37, 'Oregon'), (38, 'Pennsylvania'), (39, 'RhodeIsland'), (40, 'SouthCarolina'), (41, 'SouthDakota'), (42, 'Tennessee'), (43, 'Texas'), (44, 'Utah'), (45, 'Vermont'), (46, 'Virginia'), (47, 'Washington'), (48, 'WestVirginia'), (49, 'Wisconsin'), (50, 'Wyoming'), (51, 'District of Columbia')
GO

--++ heap rowstore
CREATE TABLE CS.FactFinance (
ID int IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Segment date NOT NULL,
Value int NOT NULL
);
GO

GenerateData 30000
GO 1000

SELECT TOP 10 * FROM CS.FactFinance
GO

SELECT COUNT(*) FROM CS.FactFinance
GO

ALTER TABLE CS.FactFinance REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

--++ then create CCSI
CREATE CLUSTERED COLUMNSTORE INDEX CI_FactFinance
ON CS.FactFinance
WITH (DATA_COMPRESSION=COLUMNSTORE_ARCHIVE)
GO

ALTER DATABASE ClusteredColumnstoreExample SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO

SELECT * FROM sys.column_store_row_groups
SELECT * FROM sys.column_store_segments
SELECT * FROM sys.column_store_dictionaries
GO

DBCC FREEPROCCACHE
SET STATISTICS IO ON

SELECT
f.ID as RecordID,
Value 
FROM CS.FactFinance f
INNER JOIN CS.DimState s on f.State = s.ID
WHERE [Year] = 2010 AND [Month] = 8 AND s.ID = 27
GO

DBCC FREEPROCCACHE
GO

SELECT [Year], [Month], SUM(CAST(Value AS bigint))
FROM CS.FactFinance
WHERE [Year] = 2010
GROUP BY YEAR, MONTH
-- this is clustered so it's ignored
OPTION(IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
GO

SELECT Segment
FROM CS.FactFinance
WHERE Segment = '2009-11-01'
GO

SELECT  [Year], [Month], State
FROM CS.FactFinance
WHERE [Year] = 2010 AND [Month] = 8
GO

SELECT *
FROM sys.stats
WHERE object_id = OBJECT_ID('CS.FactFinance')
GO

DBCC SHOW_STATISTICS('CS.FactFinance', '_WA_Sys_00000002_1273C1CD') WITH HISTOGRAM
DBCC SHOW_STATISTICS('CS.FactFinance', '_WA_Sys_00000003_1273C1CD') WITH HISTOGRAM
DBCC SHOW_STATISTICS('CS.FactFinance', '_WA_Sys_00000004_1273C1CD') WITH HISTOGRAM
DBCC SHOW_STATISTICS('CS.FactFinance', '_WA_Sys_00000005_1273C1CD') WITH HISTOGRAM
GO

UPDATE STATISTICS CS.FactFinance
GO

--++ nothing
SELECT *
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('CS.FactFinance'), NULL, NULL, 'DETAILED')
WHERE page_type = 1
GO

dbo.GenerateData 400
GO

--++ delta record
SELECT *
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('CS.FactFinance'), NULL, NULL, 'DETAILED')
WHERE page_type = 1
GO

--++ look for CSILOCATOR
DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID('CS.FactFinance')
DBCC PAGE ('ClusteredColumnstoreExample', 1, @page_id, 3);
GO

ALTER INDEX CI_FactFinance ON CS.FactFinance REBUILD
GO

--++ nothing
SELECT *
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('CS.FactFinance'), NULL, NULL, 'DETAILED')
WHERE page_type = 1
GO

DELETE
FROM CS.FactFinance
WHERE Value % 512 = 0
GO

--++ deleted bitmap data pages
SELECT *
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('CS.FactFinance'), NULL, NULL, 'DETAILED')
WHERE page_type = 1
GO

DBCC PAGE ('ClusteredColumnstoreExample', 1, 291, 3);
GO

ALTER INDEX CI_FactFinance ON CS.FactFinance REBUILD
GO

--++ nothing
SELECT *
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('CS.FactFinance'), NULL, NULL, 'DETAILED')
WHERE page_type = 1
GO