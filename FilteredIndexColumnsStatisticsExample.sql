USE master;
GO

IF DATABASEPROPERTYEX('FilteredIndexColumnsStatisticsExample', 'Status') IS NOT NULL
BEGIN
    ALTER DATABASE FilteredIndexColumnsStatisticsExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FilteredIndexColumnsStatisticsExample;
END
GO

CREATE DATABASE FilteredIndexColumnsStatisticsExample;
GO

USE FilteredIndexColumnsStatisticsExample;
GO

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('GetStats') AND type IN ('P', 'PC'))
BEGIN
    DROP PROC dbo.GetStats;
END
GO

CREATE PROC dbo.GetStats
AS
BEGIN
    SELECT
            s.stats_id AS [Stat ID]
            ,sc.name + '.' + t.name AS [Table]
            ,s.name AS [Statistics]
            ,p.last_updated
            ,p.rows
            ,p.rows_sampled
            ,p.modification_counter AS [Mod Count]
    FROM
            sys.stats s join sys.tables t ON s.object_id= t.object_id
            join sys.schemas sc ON t.schema_id= sc.schema_id
            outer apply sys.dm_db_stats_properties(t.object_id,s.stats_id) p
    WHERE
            sc.name = 'dbo' AND t.name = 'Data'
END
GO

DBCC TRACEON (3604);
GO

CREATE TABLE Data (
        RecId int not null,
        Processed bit not null
);
GO
 
CREATE UNIQUE CLUSTERED INDEX IDX_Data_RecId on Data(RecId);
GO

CREATE NONCLUSTERED INDEX IDX_Data_Unprocessed_Filtered
ON Data(RecId)
INCLUDE(Processed)
WHERE Processed = 0;
GO

WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO Data(RecId, Processed)
SELECT ID, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 3
FROM Ids;
GO

--++ DOES NOT USE INDEX; Clustered Index Scan
DECLARE @Processed BIT;
SET @Processed = 0;
SELECT TOP 1000 RecId
FROM Data
WHERE Processed = @Processed
ORDER BY RecId;
GO

DECLARE @Processed BIT;
SET @Processed = 0;
IF @Processed = 0
        --++ DOES USE INDEX; Index Scan, IDX_Data_Unprocessed_Filtered
        SELECT TOP 1000 RecId
        FROM Data
        WHERE Processed = 0
        ORDER BY RecId;
ELSE
        SELECT TOP 1000 RecId
        FROM Data
        WHERE Processed = 1
        ORDER BY RecId;
GO

DROP TABLE Data;
GO

CREATE TABLE Data (
        RecId int not null,
        Processed bit not null
);
GO
 
CREATE UNIQUE CLUSTERED INDEX IDX_Data_RecId on Data(RecId);
GO

CREATE NONCLUSTERED INDEX IDX_Data_Unprocessed_Filtered
ON Data(RecId)
INCLUDE(Processed)
WHERE Processed = 0;
GO

WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT INTO Data(RecId, Processed)
SELECT ID, 0
FROM Ids;
GO

UPDATE STATISTICS Data;
GO

--Stat ID     Table        Statistics                      last_updated                rows                 rows_sampled         Mod Count
------------- ------------ ------------------------------- --------------------------- -------------------- -------------------- --------------------
--1           dbo.Data     IDX_Data_RecId                  2014-11-16 21:28:47.3670000 65536                65536                0
--2           dbo.Data     IDX_Data_Unprocessed_Filtered   2014-11-16 21:28:47.4200000 65536                65536                0
dbo.GetStats
GO

UPDATE Data
SET Processed = 1;
GO

--Stat ID     Table        Statistics                      last_updated                rows                 rows_sampled         Mod Count
------------- ------------ ------------------------------- --------------------------- -------------------- -------------------- --------------------
--1           dbo.Data     IDX_Data_RecId                  2014-11-16 21:28:47.3670000 65536                65536                0
--2           dbo.Data     IDX_Data_Unprocessed_Filtered   2014-11-16 21:28:47.4200000 65536                65536                0
dbo.GetStats
GO

UPDATE STATISTICS Data;
GO

--Stat ID     Table       Statistics                        last_updated               rows                 rows_sampled         Mod Count
------------- ----------- -------------------------------- --------------------------- -------------------- -------------------- --------------------
--1           dbo.Data    IDX_Data_RecId                   2014-11-16 21:30:52.8500000 65536                65536                0
--2           dbo.Data    IDX_Data_Unprocessed_Filtered    NULL                        NULL                 NULL                 NULL
dbo.GetStats
GO
