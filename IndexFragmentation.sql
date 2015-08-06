USE master;
GO

IF DATABASEPROPERTYEX('IndexModification', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexModification SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexModification;
END
GO

CREATE DATABASE IndexModification
ON PRIMARY (
    NAME='IndexModificationData',
    FILENAME='H:\_DATA\IndexModification.MDF',
    SIZE = 250MB
),
FILEGROUP FG01
(
	NAME='FG01',
    FILENAME='H:\_DATA\FG01.MDF',
	SIZE=250MB
),
FILEGROUP FG02 (
	NAME='FG02',
    FILENAME='G:\_DATA\FG02.MDF',
	SIZE=250MB
),
FILEGROUP FG03 (
	NAME='FG03',
    FILENAME='G:\_DATA\FG03.MDF',
	SIZE=250MB
),
FILEGROUP FG04 (
	NAME='FG04',
    FILENAME='G:\_DATA\FG04.MDF',
	SIZE=250MB
),
FILEGROUP FG05 (
	NAME='FG05',
    FILENAME='G:\_DATA\FG05.MDF',
	SIZE=250MB
)
LOG ON (
    NAME = 'IndexModificationLog',
    FILENAME = 'C:\_LOG\IndexModification.LDF',
    SIZE = 200MB,
    FILEGROWTH=100MB
);
GO

USE IndexModification;
GO

CREATE TABLE UniqueIdentifierTable (
ID uniqueidentifier NOT NULL,
CaptureDate datetime2(0) NOT NULL,
EntityID INT NOT NULL,
StateID INT NOT NULL,
Value INT NOT NULL
)
ON FG01;
GO

CREATE TABLE IntTable (
ID int IDENTITY NOT NULL,
CaptureDate datetime2(0) NOT NULL,
EntityID INT NOT NULL,
StateID INT NOT NULL,
Value INT NOT NULL
)
ON FG02;
GO

CREATE PROC ViewFactTableIndexes
AS
SELECT t.name AS [Table Name], i.name AS [Index Name], i.type_desc, i.data_space_id, f.name AS [Filegroup Name], fill_factor
FROM sys.indexes AS i
JOIN sys.filegroups AS f ON i.data_space_id = f.data_space_id
JOIN sys.tables as t ON i.object_id = t.object_id AND i.object_id = OBJECT_ID(N'UniqueIdentifierTable','U');
SELECT t.name AS [Table Name], i.name AS [Index Name], i.type_desc, i.data_space_id, f.name AS [Filegroup Name], fill_factor
FROM sys.indexes AS i
JOIN sys.filegroups AS f ON i.data_space_id = f.data_space_id
JOIN sys.tables as t ON i.object_id = t.object_id AND i.object_id = OBJECT_ID(N'IntTable','U');
GO

CREATE PROC CheckIndexes
AS
SELECT
DB_NAME(database_id) as [Database],
OBJECT_NAME(object_id) [Object],
index_level,
avg_fragmentation_in_percent,
avg_page_space_used_in_percent
fragment_count,
page_count,
record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('UniqueIdentifierTable'), 1, NULL, 'DETAILED');
SELECT
DB_NAME(database_id),
index_level,
avg_fragmentation_in_percent,
avg_page_space_used_in_percent
fragment_count,
page_count,
record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('IntTable'), 1, NULL, 'DETAILED');
GO

CREATE PROC AddData
AS
;WITH NumericValue(Tracker)
AS
(
	SELECT 1
	UNION ALL
	SELECT Tracker + 1
	FROM NumericValue
	WHERE Tracker < 30000
)
INSERT UniqueIdentifierTable
SELECT NEWID(), DATEADD(day, (ABS(CHECKSUM(NEWID())) % (60)) * -1, CURRENT_TIMESTAMP), RAND(CHECKSUM(NEWID())) * 100, RAND(CHECKSUM(NEWID())) * 20, ABS(CHECKSUM(NEWID()))
FROM NumericValue 
OPTION (MAXRECURSION 30000);

;WITH NumericValue(Tracker)
AS
(
	SELECT 1
	UNION ALL
	SELECT Tracker + 1
	FROM NumericValue
	WHERE Tracker < 30000
)
INSERT IntTable
SELECT DATEADD(day, (ABS(CHECKSUM(NEWID())) % (60)) * -1, CURRENT_TIMESTAMP), RAND(CHECKSUM(NEWID())) * 100, RAND(CHECKSUM(NEWID())) * 20, ABS(CHECKSUM(NEWID()))
FROM NumericValue 
OPTION (MAXRECURSION 30000)
GO

CREATE PROC Iterator
AS
DECLARE @i int = 1
WHILE @i < 30
BEGIN
	EXEC AddData
	SET @i = @i + 1
END
GO

SET STATISTICS TIME ON

CREATE CLUSTERED INDEX CI_UniqueIdentifierTable_ID
ON UniqueIdentifierTable(ID)
GO

CREATE CLUSTERED INDEX CI_IntTable_ID
ON IntTable(ID)
GO

--CREATE CLUSTERED INDEX CI_UniqueIdentifierTable_ID
--ON UniqueIdentifierTable(ID)
--WITH (FILLFACTOR = 50);
--GO

--CREATE CLUSTERED INDEX CI_IntTable_ID
--ON IntTable(ID)
--WITH (FILLFACTOR = 50);
--GO

Iterator
GO

ViewFactTableIndexes
GO

SELECT
REPLACE(CONVERT(varchar, CAST((count(*)) as money), 1), '.00', '') AS WaitingRequestsCount
FROM UniqueIdentifierTable WITH (NOLOCK)
GO

CheckIndexes
GO

-- run in new window to compare data before and after
CREATE UNIQUE CLUSTERED INDEX CI_UniqueIdentifierTable_ID
ON UniqueIdentifierTable(ID)
WITH (
	DROP_EXISTING=ON,
	FILLFACTOR = 70,
	ONLINE = ON,
	DATA_COMPRESSION = PAGE
)
ON FG03;
GO

CREATE UNIQUE CLUSTERED INDEX CI_IntTable_ID
ON IntTable(ID)
WITH (
	DROP_EXISTING=ON,
	FILLFACTOR = 70,
	SORT_IN_TEMPDB = ON,
	ONLINE = ON,
	DATA_COMPRESSION = PAGE
)
ON FG04;
GO

ViewFactTableIndexes
GO

CheckIndexes
GO
--/

DROP INDEX CI_UniqueIdentifierTable_ID
ON UniqueIdentifierTable
WITH (
	MOVE TO FG02
)
GO

ViewFactTableIndexes
GO

CheckIndexes
GO

USE master;
GO

IF DATABASEPROPERTYEX('IndexModification', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexModification SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexModification;
END
GO