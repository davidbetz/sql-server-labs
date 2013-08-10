USE master;
GO

IF DATABASEPROPERTYEX('FilteredIndex', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE FilteredIndex SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE FilteredIndex;
END
GO

CREATE DATABASE FilteredIndex;
GO

ALTER DATABASE FilteredIndex SET RECOVERY SIMPLE;
GO

USE FilteredIndex;
GO

CREATE TABLE A (Id int identity, B int null);
GO

INSERT INTO A SELECT 1;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT 8;
INSERT INTO A SELECT NULL;
INSERT INTO A SELECT 10;
GO 1000

CREATE NONCLUSTERED INDEX NCI_A ON A (B);
GO

SELECT B FROM A WHERE B  = 8;
GO

SELECT i.name, SUM(page_count * 8)
FROM sys.dm_db_index_physical_stats(DB_ID('FilteredIndex'), OBJECT_ID('A'), -1, NULL, 'DETAILED') as s
INNER JOIN sys.indexes as i on s.object_id = i.object_id and s.index_id = i.index_id
GROUP BY Name
GO

DROP INDEX NCI_A ON A;
GO

CREATE NONCLUSTERED INDEX NCI_A ON A (B) WHERE B IS NOT NULL;
GO

SELECT B FROM A WHERE B  = 8;
GO

-- index is much smaller
SELECT i.name, SUM(page_count * 8)
FROM sys.dm_db_index_physical_stats(DB_ID('FilteredIndex'), OBJECT_ID('A'), -1, NULL, 'DETAILED') as s
INNER JOIN sys.indexes as i on s.object_id = i.object_id and s.index_id = i.index_id
GROUP BY Name
GO

DROP INDEX NCI_A ON A;
GO

CREATE NONCLUSTERED INDEX NCI_A ON A (B) INCLUDE (Id);
GO

SELECT Id, B FROM A WHERE B  = 8;
GO

-- index is much smaller
SELECT i.name, SUM(page_count * 8)
FROM sys.dm_db_index_physical_stats(DB_ID('FilteredIndex'), OBJECT_ID('A'), -1, NULL, 'DETAILED') as s
INNER JOIN sys.indexes as i on s.object_id = i.object_id and s.index_id = i.index_id
GROUP BY Name
GO

DROP INDEX NCI_A ON A;
GO

CREATE NONCLUSTERED INDEX NCI_A ON A (B) INCLUDE (Id) WHERE B IS NOT NULL;
GO

SELECT Id, B FROM A WHERE B  = 8;
GO

-- again, index is much smaller
SELECT i.name, SUM(page_count * 8)
FROM sys.dm_db_index_physical_stats(DB_ID('FilteredIndex'), OBJECT_ID('A'), -1, NULL, 'DETAILED') as s
INNER JOIN sys.indexes as i on s.object_id = i.object_id and s.index_id = i.index_id
GROUP BY Name
GO

USE master;

IF DATABASEPROPERTYEX('FilteredIndex', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE FilteredIndex SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE FilteredIndex;
END
GO