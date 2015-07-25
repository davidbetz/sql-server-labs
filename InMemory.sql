USE master;
GO

IF DATABASEPROPERTYEX('InMemory', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE InMemory SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InMemory;
END
GO

CREATE DATABASE InMemory
ON PRIMARY (
    NAME='InMemory_Data',
    FILENAME='C:\_DATA\InMemory.MDF',
    SIZE = 250MB
)
LOG ON (
    NAME = 'InMemory_Log',
    FILENAME = 'C:\_DATA\InMemory.LDF',
    SIZE = 10MB,
    FILEGROWTH=20%
);
GO

ALTER DATABASE InMemory SET RECOVERY SIMPLE;
GO

ALTER DATABASE InMemory COLLATE Latin1_General_100_BIN2;
GO

ALTER DATABASE InMemory
ADD FILEGROUP MD CONTAINS MEMORY_OPTIMIZED_DATA;
GO

--+ needed, else you get this:
--Msg 41337, Level 16, State 0, Line 44
--Cannot create memory optimized tables in a database that does not have an online and non-empty MEMORY_OPTIMIZED_DATA filegroup.
ALTER DATABASE InMemory
ADD FILE (NAME='MD', FILENAME='C:\_DATA\InMemory') TO FILEGROUP MD;
GO

USE InMemory;
GO

-- ERROR: SCHEMA_AND_DATA requires primary key
CREATE TABLE A (
C1 int NOT NULL,
C2 int NOT NULL,
INDEX IX_C1_C2 NONCLUSTERED (C1, C2)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

-- ERROR: clustered is default for primary key; clustered is not supported
CREATE TABLE A (
C1 int NOT NULL PRIMARY KEY,
C2 int NOT NULL,
INDEX IX_C1_C2 NONCLUSTERED (C1, C2)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE TABLE A (
C1 int NOT NULL PRIMARY KEY NONCLUSTERED,
C2 int NOT NULL,
INDEX IX_C1_C2 NONCLUSTERED (C1, C2)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE TABLE B (
C1 int NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 100000),
C2 int NOT NULL,
INDEX IX_C1_C2 NONCLUSTERED (C1, C2) -- RANGE INDEX
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY);
GO

WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT B
SELECT ID, ID % 4
FROM IDS;
GO

-- SEEK
SELECT * FROM B
WHERE C1 = 26034
GO

-- SCAN AND FILTER
SELECT * FROM B
WHERE C2 = 2
GO

-- SEEK AND FILTER
SELECT * FROM B
WHERE C1 = 26034 AND C2 = 2
GO

--ERROR: * is not allowed in schema-bound objects (native procs must be schema-bound)
CREATE PROC MyProc(@id int)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH(TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE=N'english')
	SELECT * FROM B
	WHERE C1 = @id AND C2 = 2
END
GO

-- ERROR: table must be two-part
CREATE PROC MyProc(@id int)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH(TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE=N'english')
	SELECT C1, C2 FROM B
	WHERE C1 = @id AND C2 = 2
END
GO

IF EXISTS (SELECT 1 FROM sys.objects where type = 'P' and name = 'MyProc')
BEGIN
	DROP PROC MyProc;
END
GO

CREATE PROC MyProc(@id int)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH(TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE=N'english')
	SELECT C1, C2 FROM dbo.B
	WHERE C1 = @id AND C2 = 2
END
GO

MyProc 2
GO

SELECT
DISTINCT
t.name,
t.durability,
t.durability_desc,
i.name,
i.type,
i.type_desc
FROM sys.tables t
INNER JOIN sys.indexes i on t.object_id = i.object_id
WHERE t.is_memory_optimized = 1

SELECT * FROM sys.hash_indexes;

SELECT OBJECTPROPERTY(OBJECT_ID('InMemory'), 'TableIsMemoryOptimized')

SELECT * FROM sys.dm_db_xtp_checkpoint_stats
SELECT * FROM sys.dm_db_xtp_checkpoint_files
SELECT * FROM sys.dm_db_xtp_merge_requests
SELECT * FROM sys.dm_xtp_gc_stats
SELECT * FROM sys.dm_xtp_gc_queue_stats
SELECT * FROM sys.dm_db_xtp_gc_cycle_stats
SELECT * FROM sys.dm_db_xtp_hash_index_stats
SELECT * FROM sys.dm_db_xtp_nonclustered_index_stats
SELECT * FROM sys.dm_db_xtp_index_stats
SELECT * FROM sys.dm_db_xtp_object_stats
SELECT * FROM sys.dm_xtp_system_memory_consumers
SELECT * FROM sys.dm_db_xtp_table_memory_stats
SELECT * FROM sys.dm_db_xtp_memory_consumers
SELECT * FROM sys.dm_xtp_transaction_stats
SELECT * FROM sys.dm_db_xtp_transactions
SELECT * FROM sys.dm_xtp_threads
SELECT * FROM sys.dm_xtp_transaction_recent_rows

USE master;
GO

IF DATABASEPROPERTYEX('InMemory', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE InMemory SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InMemory;
END
GO