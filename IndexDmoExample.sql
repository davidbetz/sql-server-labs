USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('IndexDmoExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexDmoExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexDmoExample;
END
GO

CREATE DATABASE IndexDmoExample;
GO

--ALTER DATABASE IndexDmoExample SET COMPATIBILITY_LEVEL = 100;
--GO

USE IndexDmoExample;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE dbo.UsageDemo
(
ID INT NOT NULL,
Col1 INT NOT NULL,
Col2 INT NOT NULL,
Placeholder CHAR(8000) NULL
);
GO

CREATE UNIQUE CLUSTERED INDEX IDX_CI
ON dbo.UsageDemo(ID);
GO

CREATE UNIQUE NONCLUSTERED INDEX IDX_NCI1
ON dbo.UsageDemo(Col1);
GO

CREATE UNIQUE NONCLUSTERED INDEX IDX_NCI2
ON dbo.UsageDemo(Col2);
GO

;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N3)
INSERT INTO dbo.UsageDemo(ID, Col1, Col2)
SELECT ID, ID, ID
FROM IDs;
GO

SELECT
s.Name + N'.' + t.name AS [Table]
,i.name AS [Index]
,ius.user_seeks AS [Seeks], ius.user_scans AS [Scans]
,ius.user_lookups AS [Lookups]
,ius.user_seeks + ius.user_scans + ius.user_lookups AS [Reads]
,ius.user_updates AS [Updates], ius.last_user_seek AS [Last Seek]
,ius.last_user_scan AS [Last Scan], ius.last_user_lookup AS [Last Lookup]
,ius.last_user_update AS [Last Update]
from
sys.tables t
join sys.indexes i on t.object_id = i.object_id join sys.schemas s ON t.schema_id = s.schema_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON ius.database_id = db_id() AND ius.object_id = i.object_id AND ius.index_id = i.index_id
WHERE s.name = N'dbo' AND t.name = N'UsageDemo'
ORDER BY s.name, t.name, i.index_id

-- Query 1: CI Seek (Singleton lookup)
SELECT Placeholder FROM dbo.UsageDemo WHERE ID = 5;

-- Query 2: CI Seek (Range Scan)
SELECT count(*)
FROM dbo.UsageDemo WITH (INDEX=IDX_CI)
WHERE ID between 2 and 6;

-- Query 3: CI Scan
SELECT count(*) FROM dbo.UsageDemo WITH (INDEX=IDX_CI);

-- Query 4: NCI Seek (Singleton lookup + Key Lookup)
SELECT Placeholder FROM dbo.UsageDemo WHERE Col1 = 5;

-- Query 5: NCI Seek (Range Scan - all data from the table)
SELECT COUNT(*) FROM dbo.UsageDemo WHERE Col1 > -1;

-- Query 6: NCI Seek (Range Scan + Key Lookup)
SELECT SUM(Col2)
FROM dbo.UsageDemo WITH (INDEX = IDX_NCI1)
WHERE Col1 BETWEEN 1 AND 5;

-- Queries 7-8: Updates
UPDATE dbo.UsageDemo SET Col2 = -3 WHERE Col1 = 3
UPDATE dbo.UsageDemo SET Col2 = -4 WHERE Col1 = 4
