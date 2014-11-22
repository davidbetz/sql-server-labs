USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('MoveIndexExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE MoveIndexExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE MoveIndexExample;
END
GO

CREATE DATABASE MoveIndexExample
ON PRIMARY (
    NAME='MoveIndexExampleData', 
    FILENAME='H:\_DATA\MoveIndexExample.MDF', 
    SIZE = 150MB
),
FILEGROUP Data1
(
    NAME='MoveIndexExampleData1', 
    FILENAME='H:\_DATA\MoveIndexExample1.NDF', 
    SIZE = 150MB
) LOG ON (
    NAME = 'MoveIndexExampleLog', 
    FILENAME = 'C:\_LOG\MoveIndexExample.LDF', 
    SIZE = 100MB, 
    FILEGROWTH=50MB
);
GO

--ALTER DATABASE MoveIndexExample SET COMPATIBILITY_LEVEL = 100;
--GO

USE MoveIndexExample;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE DataTable (
ID INT NOT NULL, 
K uniqueidentifier NOT NULL,
Data VARCHAR(8000) NULL
)
ON Data1;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_DataTable_ID
ON DataTable(K)
-- creates different structure on filegroup
GO

;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
, N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
, N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
, N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
, N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N2 AS T2) -- 1, 024 ROWS
, IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO DataTable(ID, K)
SELECT ID * 2, NEWID()
FROM Ids
WHERE ID <= 6200
GO

--page_count           avg_page_space_used_in_percent fragment_count
---------------------- ------------------------------ --------------------
--1                    99.5552260934025               1
SELECT page_count, avg_page_space_used_in_percent, fragment_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N'DataTable'), 1, NULL, 'DETAILED');
GO

INSERT INTO DataTable(ID, K, Data) VALUES(101, NEWID(), replicate('a', 8000));
INSERT INTO DataTable(ID, K, Data) VALUES(103, NEWID(), replicate('a', 8000));
INSERT INTO DataTable(ID, K, Data) VALUES(105, NEWID(), replicate('a', 8000));
INSERT INTO DataTable(ID, K, Data) VALUES(107, NEWID(), replicate('a', 8000));
GO

--page_count           avg_page_space_used_in_percent fragment_count
---------------------- ------------------------------ --------------------
--3                    66.1848282678527               3
--1                    0.457128737336299              1
SELECT page_count, avg_page_space_used_in_percent, fragment_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N'DataTable'), 1, NULL, 'DETAILED');
GO

--object_id   index_type_desc                                              alloc_unit_type_desc                                         index_level avg_fragment_size_in_pages record_count         database_id object_id   index_id    partition_number index_type_desc                                              alloc_unit_type_desc                                         index_depth index_level avg_fragmentation_in_percent fragment_count       avg_fragment_size_in_pages page_count           avg_page_space_used_in_percent record_count         ghost_record_count   version_ghost_record_count min_record_size_in_bytes max_record_size_in_bytes avg_record_size_in_bytes forwarded_record_count compressed_page_count
------------- ------------------------------------------------------------ ------------------------------------------------------------ ----------- -------------------------- -------------------- ----------- ----------- ----------- ---------------- ------------------------------------------------------------ ------------------------------------------------------------ ----------- ----------- ---------------------------- -------------------- -------------------------- -------------------- ------------------------------ -------------------- -------------------- -------------------------- ------------------------ ------------------------ ------------------------ ---------------------- ---------------------
--261575970   CLUSTERED INDEX                                              IN_ROW_DATA                                                  0           1                          621                  14          261575970   1           1                CLUSTERED INDEX                                              IN_ROW_DATA                                                  2           0           66.6666666666667             3                    1                          3                    66.1848282678527               621                  0                    0                          11                       8015                     23.888                   NULL                   0
--261575970   CLUSTERED INDEX                                              IN_ROW_DATA                                                  1           1                          3                    14          261575970   1           1                CLUSTERED INDEX                                              IN_ROW_DATA                                                  2           1           0                            1                    1                          1                    0.457128737336299              3                    0                    0                          11                       11                       11                       NULL                   0
SELECT
object_id,
index_type_desc,
alloc_unit_type_desc,
index_level,
avg_fragment_size_in_pages,
record_count,*
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), -1, 0, 'DETAILED')

--name                         type_desc    name           type_desc
------------------------------ ------------ -------------- --------------------
--IDX_DataTable_ID         CLUSTERED    PRIMARY        ROWS_FILEGROUP
SELECT
i.name,
i.type_desc,
f.name,
f.type_desc
FROM sys.indexes i
INNER JOIN sys.filegroups f ON i.data_space_id = f.data_space_id
INNER JOIN sys.all_objects o ON i.object_id = o.object_id
WHERE o.type = 'U'
GO

ALTER DATABASE MoveIndexExample
ADD FILEGROUP Data2;
GO

ALTER DATABASE MoveIndexExample
ADD FILE (
    NAME='MoveIndexExampleData2', 
    FILENAME='H:\_DATA\MoveIndexExample2.NDF', 
    SIZE = 150MB
)
TO FILEGROUP Data2
GO

CREATE UNIQUE CLUSTERED INDEX IDX_DataTable_ID
ON DataTable(ID)
WITH (DROP_EXISTING = ON)
ON Data2;
GO

SELECT page_count, avg_page_space_used_in_percent, fragment_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N'DataTable'), 1, NULL, 'DETAILED');
GO

--object_id   index_type_desc                                              alloc_unit_type_desc                                         index_level avg_fragment_size_in_pages record_count         database_id object_id   index_id    partition_number index_type_desc                                              alloc_unit_type_desc                                         index_depth index_level avg_fragmentation_in_percent fragment_count       avg_fragment_size_in_pages page_count           avg_page_space_used_in_percent record_count         ghost_record_count   version_ghost_record_count min_record_size_in_bytes max_record_size_in_bytes avg_record_size_in_bytes forwarded_record_count compressed_page_count
------------- ------------------------------------------------------------ ------------------------------------------------------------ ----------- -------------------------- -------------------- ----------- ----------- ----------- ---------------- ------------------------------------------------------------ ------------------------------------------------------------ ----------- ----------- ---------------------------- -------------------- -------------------------- -------------------- ------------------------------ -------------------- -------------------- -------------------------- ------------------------ ------------------------ ------------------------ ---------------------- ---------------------
--261575970   CLUSTERED INDEX                                              IN_ROW_DATA                                                  0           3                          621                  14          261575970   1           1                CLUSTERED INDEX                                              IN_ROW_DATA                                                  2           0           0                            1                    3                          3                    66.1848282678527               621                  0                    0                          11                       8015                     23.888                   NULL                   0
--261575970   CLUSTERED INDEX                                              IN_ROW_DATA                                                  1           1                          3                    14          261575970   1           1                CLUSTERED INDEX                                              IN_ROW_DATA                                                  2           1           0                            1                    1                          1                    0.457128737336299              3                    0                    0                          11                       11                       11                       NULL                   0

SELECT
object_id,
index_type_desc,
alloc_unit_type_desc,
index_level,
avg_fragment_size_in_pages,
record_count,*
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataTable'), -1, 0, 'DETAILED')

--name                         type_desc    name           type_desc
------------------------------ ------------ -------------- --------------------
--IDX_DataTable_ID         CLUSTERED    Data2          ROWS_FILEGROUP
SELECT
i.name,
i.type_desc,
f.name,
f.type_desc
FROM sys.indexes i
INNER JOIN sys.filegroups f ON i.data_space_id = f.data_space_id
INNER JOIN sys.all_objects o ON i.object_id = o.object_id
WHERE o.type = 'U'
GO

-- CANNOT DELETE; LOB DATA NOT MOVED
ALTER DATABASE MoveIndexExample
REMOVE FILE MoveIndexExampleData1;
GO

ALTER DATABASE MoveIndexExample
REMOVE FILEGROUP Data1;
GO