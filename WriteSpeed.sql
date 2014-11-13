USE master;
GO

IF DATABASEPROPERTYEX('WriteSpeed', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE WriteSpeed SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE WriteSpeed;
END
GO

CREATE DATABASE WriteSpeed;
GO

USE WriteSpeed;
GO

DBCC TRACEON (3604);
GO

CREATE FUNCTION dbo.GetLatestInRowPageID()
RETURNS INT
AS
BEGIN
	DECLARE @page_id INT;
	SELECT TOP 1 @page_id = allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('DataTableMax'), null, null, 'DETAILED') WHERE page_type = 1 ORDER BY allocated_page_page_id DESC;
	RETURN @page_id;
END
GO

CREATE TABLE HeapTable (
	ID BIGINT IDENTITY NOT NULL,
	Data1 VARCHAR(MAX),
	Data2 VARCHAR(MAX)
) ON [Primary];
GO

CREATE TABLE ClusteredIndexTable (
	ID BIGINT IDENTITY NOT NULL PRIMARY KEY,
	Data1 VARCHAR(MAX),
	Data2 VARCHAR(MAX)
) ON [Primary];
GO

SET STATISTICS IO ON
GO

WITH A(ID, Column1, Column2)
AS
(
	SELECT 1, REPLICATE('0', 8000), REPLICATE('0', 8000)
	UNION ALL
	SELECT ID + 1, Column1, Column2 FROM A WHERE ID < 30000
)
INSERT INTO HeapTable
SELECT Column1, Column2 FROM A
OPTION(MAXRECURSION 30000)
GO

WITH A(ID, Column1, Column2)
AS
(
	SELECT 1, REPLICATE('0', 8000), REPLICATE('0', 8000)
	UNION ALL
	SELECT ID + 1, Column1, Column2 FROM A WHERE ID < 30000
)
INSERT INTO ClusteredIndexTable
SELECT Column1, Column2 FROM A
OPTION(MAXRECURSION 30000)
GO

SELECT
page_count,
avg_record_size_in_bytes,
avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('HeapTable'), 0, NULL, 'DETAILED');
GO

SELECT *
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('ClusteredIndexTable'), 1, NULL, 'DETAILED');
GO

ALTER TABLE ClusteredIndexTable REBUILD

SELECT *
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('ClusteredIndexTable'), 1, NULL, 'DETAILED');
GO