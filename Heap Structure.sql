USE master;
GO

IF DATABASEPROPERTYEX('HeapStructure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE HeapStructure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HeapStructure;
END
GO

CREATE DATABASE HeapStructure;
GO

USE HeapStructure;
GO

SET NOCOUNT ON;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE DataTable (
	Column1 VARCHAR(8000)
) ON [Primary];
GO

WITH A(ID, Column1)
AS
(
	SELECT 1, REPLICATE('0', 4089)
	UNION ALL
	SELECT ID + 1, Column1 FROM A WHERE ID < 20
)
INSERT INTO DataTable
SELECT Column1 FROM A;
GO

SELECT
page_count,
avg_record_size_in_bytes,
avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), 0, NULL, 'DETAILED');
GO

--page_count           avg_record_size_in_bytes avg_page_space_used_in_percent
---------------------- ------------------------ ------------------------------
--20                   4100                     50.6548060291574

INSERT INTO DataTable(Column1) VALUES (REPLICATE('1', 100));
GO

SELECT
page_count,
avg_record_size_in_bytes,
avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), 0, NULL, 'DETAILED');
GO

--page_count           avg_record_size_in_bytes avg_page_space_used_in_percent
---------------------- ------------------------ ------------------------------
--20                   3910.047                 50.7246108228317

INSERT INTO DataTable(Column1) VALUES (REPLICATE('2', 2000));
GO

SELECT
page_count,
avg_record_size_in_bytes,
avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), 0, NULL, 'DETAILED');
GO

--page_count           avg_record_size_in_bytes avg_page_space_used_in_percent
---------------------- ------------------------ ------------------------------
--21                   3823.727                 49.4922782307882

USE master;
GO

IF DATABASEPROPERTYEX('HeapStructure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE HeapStructure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HeapStructure;
END
GO