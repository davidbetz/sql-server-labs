--from Pro SQL Server Internals, p. 32

USE master;
GO

IF DATABASEPROPERTYEX('ForwardingPointers', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ForwardingPointers SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ForwardingPointers;
END
GO

CREATE DATABASE ForwardingPointers;
GO

USE ForwardingPointers;
GO

SET NOCOUNT ON;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE DataTable (
	ID INT NOT NULL,
	Column1 VARCHAR(8000)
) ON [Primary];
GO

INSERT INTO DataTable (ID, Column1) VALUES (1, NULL), (2, REPLICATE('2', 7800)), (3, NULL);
GO

--page_count           avg_record_size_in_bytes avg_page_space_used_in_percent forwarded_record_count
---------------------- ------------------------ ------------------------------ ----------------------
--1                    2612.333                 96.8742278230788               0
SELECT
page_count,
avg_record_size_in_bytes,
avg_page_space_used_in_percent,
forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), 0, NULL, 'DETAILED');
GO

--Table 'DataTable'. Scan count 1, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
SET STATISTICS IO ON
SELECT COUNT(*) FROM DataTable;
SET STATISTICS IO OFF
GO

UPDATE DataTable
SET Column1 = REPLICATE('1', 5000)
WHERE ID = 1;

UPDATE DataTable
SET Column1 = REPLICATE('3', 5000)
WHERE ID = 3;
GO

--page_count           avg_record_size_in_bytes avg_page_space_used_in_percent forwarded_record_count
---------------------- ------------------------ ------------------------------ ----------------------
--3                    3577.4                   73.6800963676798               2
SELECT
page_count,
avg_record_size_in_bytes,
avg_page_space_used_in_percent,
forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), 0, NULL, 'DETAILED');
GO

--Table 'DataTable'. Scan count 1, logical reads 5, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
SET STATISTICS IO ON
SELECT COUNT(*) FROM DataTable;
SET STATISTICS IO OFF
GO

ALTER TABLE DataTable REBUILD
GO

-- no forwarded rows
--page_count           avg_record_size_in_bytes avg_page_space_used_in_percent forwarded_record_count
---------------------- ------------------------ ------------------------------ ----------------------
--3                    5948.333                 73.4906597479615               0
select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent, forwarded_record_count
from sys.dm_db_index_physical_stats(db_id(),object_id(N'DataTable'),0,null,'DETAILED');

USE master;
GO