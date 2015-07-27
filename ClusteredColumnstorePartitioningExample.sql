USE master;
GO

IF DATABASEPROPERTYEX('ClusteredColumnstorePartitioningExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ClusteredColumnstorePartitioningExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ClusteredColumnstorePartitioningExample;
END
GO

CREATE DATABASE ClusteredColumnstorePartitioningExample
ON PRIMARY (
    NAME='ClusteredColumnstorePartitioningExampleData',
    FILENAME='H:\_DATA\ClusteredColumnstorePartitioningExample.MDF',
    SIZE = 10MB,
    FILEGROWTH=20%
)
LOG ON (
    NAME = 'ClusteredColumnstorePartitioningExampleLog',
    FILENAME = 'C:\_LOG\ClusteredColumnstorePartitioningExample.LDF',
    SIZE = 10MB,
    FILEGROWTH=20%
);
GO

USE ClusteredColumnstorePartitioningExample;
GO

DBCC TRACEON (3604);
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2009;
ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2010;
ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2011;
ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2012;
ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2013;
ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP CURRENT_FINANCE;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2009', FILENAME='E:\_DATA\ClusteredColumnstorePartitioningExample_Year2009.ndf')
TO FILEGROUP YEAR2009;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2010', FILENAME='E:\_DATA\ClusteredColumnstorePartitioningExample_Year2010.ndf')
TO FILEGROUP YEAR2010;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2011', FILENAME='G:\_DATA\ClusteredColumnstorePartitioningExample_Year2011.ndf')
TO FILEGROUP YEAR2011;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2012', FILENAME='F:\_DATA\ClusteredColumnstorePartitioningExample_Year2012.ndf')
TO FILEGROUP YEAR2012;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2013', FILENAME='H:\_DATA\ClusteredColumnstorePartitioningExample_Year2013.ndf')
TO FILEGROUP YEAR2013;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='CURRENT_FINANCE', FILENAME='C:\_DATA\ClusteredColumnstorePartitioningExample_Current.ndf')
TO FILEGROUP CURRENT_FINANCE;
GO

CREATE SCHEMA Partitioning;
GO

CREATE TABLE Partitioning.DimState (
ID tinyint PRIMARY KEY NOT NULL,
NAME char(20) NOT NULL
)
GO

INSERT Partitioning.DimState
VALUES (1, 'Alabama'), (2, 'Alaska'), (3, 'Arizona'), (4, 'Arkansas'), (5, 'California'), (6, 'Colorado'), (7, 'Connecticut'), (8, 'Delaware'), (9, 'Florida'), (10, 'Georgia'), (11, 'Hawaii'), (12, 'Idaho'), (13, 'Illinois'), (14, 'Indiana'), (15, 'Iowa'), (16, 'Kansas'), (17, 'Kentucky'), (18, 'Louisiana'), (19, 'Maine'), (20, 'Maryland'), (21, 'Massachusetts'), (22, 'Michigan'), (23, 'Minnesota'), (24, 'Mississippi'), (25, 'Missouri'), (26, 'Montana'), (27, 'Nebraska'), (28, 'Nevada'), (29, 'NewHampshire'), (30, 'NewJersey'), (31, 'NewMexico'), (32, 'NewYork'), (33, 'NorthCarolina'), (34, 'NorthDakota'), (35, 'Ohio'), (36, 'Oklahoma'), (37, 'Oregon'), (38, 'Pennsylvania'), (39, 'RhodeIsland'), (40, 'SouthCarolina'), (41, 'SouthDakota'), (42, 'Tennessee'), (43, 'Texas'), (44, 'Utah'), (45, 'Vermont'), (46, 'Virginia'), (47, 'Washington'), (48, 'WestVirginia'), (49, 'Wisconsin'), (50, 'Wyoming'), (51, 'District of Columbia')
GO

--++ heap rowstore
CREATE TABLE Partitioning.FactFinance (
ID int IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Segment date NOT NULL,
Value int NOT NULL
);
GO

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 30000
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
INSERT Partitioning.FactFinance
SELECT ABS(CHECKSUM(NewId())) % 51, [Month], [Year], CONVERT(date, CONVERT(VARCHAR(4), [Year]) + RIGHT('0' + CONVERT(VARCHAR(2), [Month]), 2) + '01', 112), NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000)
GO 10

ALTER TABLE Partitioning.FactFinance REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

CREATE PARTITION FUNCTION FinanceYearPF (date)
AS RANGE LEFT FOR VALUES ('2009-12-31', '2010-12-31', '2011-12-31', '2012-12-31', '2013-12-31');
GO

CREATE PARTITION SCHEME FinanceYearPS
AS PARTITION FinanceYearPF
TO (YEAR2009, YEAR2010, YEAR2011, YEAR2012, YEAR2013, CURRENT_FINANCE);
GO

--++ create CI first (CI is required when partitioning; go straight to CCSI when not using partitioning)
CREATE CLUSTERED INDEX CI_FactFinance
ON Partitioning.FactFinance (Segment DESC)
ON FinanceYearPS(Segment); -- must equal partition column
GO

--++ then create CCSI
CREATE CLUSTERED COLUMNSTORE INDEX CI_FactFinance
ON Partitioning.FactFinance
WITH (DROP_EXISTING=ON)
ON FinanceYearPS (Segment); -- must equal partition column
GO

--++ HOWTO: add file group
ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2014;
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2014', FILENAME='H:\_DATA\ClusteredColumnstorePartitioningExample_Year2014.ndf')
TO FILEGROUP YEAR2014;
GO

ALTER PARTITION SCHEME FinanceYearPS NEXT USED YEAR2013
GO

--++ drop index; can't figure out another way to update it
DROP INDEX CI_FactFinance
ON Partitioning.FactFinance
GO

ALTER PARTITION FUNCTION FinanceYearPF ()
SPLIT RANGE ('2014-12-31');
GO

--++ create CI first
CREATE CLUSTERED INDEX CI_FactFinance
ON Partitioning.FactFinance (Segment DESC)
ON FinanceYearPS(Segment);
GO

--++ then create CCSI
CREATE CLUSTERED COLUMNSTORE INDEX CI_FactFinance
ON Partitioning.FactFinance
WITH (DROP_EXISTING=ON)
ON FinanceYearPS (Segment);
GO

--++ columnstore is used
SELECT  TOP 100 $partition.FinanceYearPF(Segment), Segment, [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE [Year] = 2014
GO

ALTER DATABASE ClusteredColumnstorePartitioningExample SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO

SELECT 2009, $partition.FinanceYearPF('20090101');
SELECT 2010, $partition.FinanceYearPF('20100101');
SELECT 2011, $partition.FinanceYearPF('20110101');
SELECT 2012, $partition.FinanceYearPF('20120101');
SELECT 2013, $partition.FinanceYearPF('20130101');
SELECT 2014, $partition.FinanceYearPF('20140101');
SELECT 2015, $partition.FinanceYearPF('20150101');
GO

--++ 240000
SELECT COUNT(*)
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF(Segment) = 6
GO

UPDATE STATISTICS Partitioning.FactFinance
GO

SELECT [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO

SELECT [Year], [Month]
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO

--++ FASTEST
SELECT Segment
FROM Partitioning.FactFinance
WHERE Segment = '2009-11-01'
GO

SELECT [Year], [Month], State
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO

SELECT * FROM sys.column_store_segments
SELECT * FROM sys.column_store_dictionaries
SELECT * FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('ClusteredColumnstorePartitioningExample'), NULL, NULL, 'DETAILED')