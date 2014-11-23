USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('UniquifierExample', 'Status') IS NOT NULL
BEGIN
ALTER DATABASE UniquifierExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE UniquifierExample;
END
GO

CREATE DATABASE UniquifierExample;
GO

--ALTER DATABASE UniquifierExample SET COMPATIBILITY_LEVEL = 100;
--GO

USE UniquifierExample;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE UniqueCI ( 
KeyValue INT NOT NULL, 
id INT NOT NULL, 
data CHAR(986) NULL, 
vardata VARCHAR(32) NOT NULL CONSTRAINT def_UniqueCI_vardata DEFAULT 'Data' 
); 
GO

CREATE UNIQUE CLUSTERED INDEX idx_UniqueCI_KeyValue 
ON UniqueCI(KeyValue); 
GO

CREATE TABLE NonUniqueCINoDups ( 
KeyValue INT NOT NULL, 
id INT NOT NULL, 
data CHAR(986) NULL, 
vardata VARCHAR(32) NOT NULL CONSTRAINT def_NonUniqueCINoDups_vardata DEFAULT 'Data' 
); 
GO

CREATE CLUSTERED INDEX idx_NonUniqueCINoDups_KeyValue
ON NonUniqueCINoDups(KeyValue); 
GO

CREATE TABLE NonUniqueCIDups ( 
KeyValue INT NOT NULL, 
id INT NOT NULL, 
data CHAR(986) NULL, 
vardata VARCHAR(32) NOT NULL CONSTRAINT def_NonUniqueCIDups_vardata DEFAULT 'Data' 
); 
GO

CREATE CLUSTERED INDEX idx_NonUniqueCIDups_KeyValue 
ON NonUniqueCIDups(KeyValue); 
GO

;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO UniqueCI (KeyValue, id) 
SELECT id, id 
FROM ids; 
GO

INSERT INTO NonUniqueCINoDups (KeyValue, id) 
SELECT KeyValue, id 
FROM UniqueCI; 
GO

INSERT INTO NonUniqueCIDups (KeyValue, id) 
SELECT KeyValue % 10, id 
FROM UniqueCI; 
GO

SELECT
index_level, 
page_count, 
min_record_size_in_bytes AS [min row size], 
max_record_size_in_bytes AS [max row size], 
avg_record_size_in_bytes AS [avg row size] 
FROM sys.Dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'UniqueCI'), 1, NULL, 'DETAILED') 
GO

SELECT
index_level, 
page_count, 
min_record_size_in_bytes AS [min row size], 
max_record_size_in_bytes AS [max row size], 
avg_record_size_in_bytes AS [avg row size] 
FROM sys.Dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'NonUniqueCINoDups'), 1, NULL, 'DETAILED') 
GO

SELECT
index_level, 
page_count, 
min_record_size_in_bytes AS [min row size], 
max_record_size_in_bytes AS [max row size], 
avg_record_size_in_bytes AS [avg row size] 
FROM sys.Dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'NonUniqueCIDups'), 1, NULL, 'DETAILED')
GO

CREATE NONCLUSTERED INDEX IDX_UniqueCI_ID
on UniqueCI(ID);
GO

CREATE NONCLUSTERED INDEX IDX_NonUniqueCINoDups_ID
on NonUniqueCINoDups(ID);
GO

CREATE NONCLUSTERED INDEX IDX_NonUniqueCIDups_ID
ON NonUniqueCIDups(ID);
GO

SELECT
index_level, page_count, min_record_size_in_bytes as [min row size]
,max_record_size_in_bytes as [max row size]
,avg_record_size_in_bytes as [avg row size]
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'UniqueCI'), 2, null , 'DETAILED')
GO

SELECT
index_level, page_count, min_record_size_in_bytes as [min row size]
,max_record_size_in_bytes as [max row size]
,avg_record_size_in_bytes as [avg row size]
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'NonUniqueCINoDups'), 2, null , 'DETAILED')
GO

SELECT
index_level, page_count, min_record_size_in_bytes as [min row size]
,max_record_size_in_bytes as [max row size]
,avg_record_size_in_bytes as [avg row size]
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'NonUniqueCIDups'), 2, null , 'DETAILED')
GO
