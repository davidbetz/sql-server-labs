USE master;
GO

IF DATABASEPROPERTYEX('PageSplittingBookActivity', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE PageSplittingBookActivity SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE PageSplittingBookActivity;
END
GO

CREATE DATABASE PageSplittingBookActivity;
GO

ALTER DATABASE PageSplittingBookActivity SET RECOVERY SIMPLE;
GO

USE PageSplittingBookActivity;
GO

CREATE TABLE dbo.TestStructure (
    id int NOT NULL,
    filler1 char(36) NOT NULL,
    filler2 char(216) NOT NULL
);
GO

CREATE SEQUENCE s1 START WITH 1 INCREMENT BY 1;
GO

SELECT
   OBJECT_NAME(object_id) AS table_name,
    name AS index_name,
    type,
    type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.TestStructure', N'U');
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure',
                      @updateusage = TRUE;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON

INSERT INTO dbo.TestStructure (id, filler1, filler2)
    VALUES (NEXT VALUE FOR s1, 'a', 'b');
GO

SET STATISTICS IO OFF
SET STATISTICS TIME OFF

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure',
                      @updateusage = TRUE;
GO

SET STATISTICS IO ON
SET STATISTICS time ON

DECLARE @i AS int = 1;
WHILE @i < 30
BEGIN
    SET @i = @i + 1
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b')
END;
GO

SET STATISTICS IO OFF
SET STATISTICS time OFF

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure',
                      @updateusage = TRUE;
GO

INSERT INTO dbo.TestStructure (id, filler1, filler2)
    VALUES (NEXT VALUE FOR s1, 'a', 'b');
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure',
                      @updateusage = TRUE;
GO

DECLARE @i AS int = 31;
WHILE @i < 240
BEGIN
    SET @i = @i + 1;
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
END;
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure',
                      @updateusage = TRUE;
GO

INSERT INTO dbo.TestStructure (id, filler1, filler2)
    VALUES (NEXT VALUE FOR s1, 'a', 'b');
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure',
                      @updateusage = TRUE;
GO
-- clustered
TRUNCATE TABLE dbo.TestStructure;
GO

CREATE CLUSTERED INDEX idx_cl_id ON dbo.TestStructure (id);
GO

SELECT
    OBJECT_NAME(object_id) AS table_name,
    name AS index_name,
    type,
    type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.TestStructure', N'U');
GO

SET STATISTICS time ON
ALTER SEQUENCE s1 RESTART WITH 1
DECLARE @i AS int = 0;
WHILE @i < 18630
BEGIN
    SET @i = @i + 10;
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (NEXT VALUE FOR s1, 'a', 'b');
    IF @i % 100 = 0
        PRINT @i
END;
GO

SET STATISTICS time OFF
SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');
GO

INSERT INTO dbo.TestStructure (id, filler1, filler2)
    VALUES (18631, 'a', 'b');
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');
GO

TRUNCATE TABLE dbo.TestStructure;
DECLARE @i AS int = 0;
WHILE @i < 8908
BEGIN
    SET @i = @i + 1;
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (@i % 100, 'a', 'b');
END;
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');
GO

INSERT INTO dbo.TestStructure (id, filler1, filler2)
    VALUES (8909 % 100, 'a', 'b');
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');
GO

TRUNCATE TABLE dbo.TestStructure;
DROP INDEX idx_cl_id ON dbo.TestStructure;
CREATE CLUSTERED INDEX idx_cl_filler1 ON dbo.TestStructure (filler1);
DECLARE @i AS int = 0;
WHILE @i < 9000
BEGIN
    SET @i = @i + 1;
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (@i, FORMAT(@i, '0000'), 'b');
END;
GO

SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent,
    avg_fragmentation_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');
GO

TRUNCATE TABLE dbo.TestStructure;
DECLARE @i AS int = 0;
WHILE @i < 9000
BEGIN
    SET @i = @i + 1;
    INSERT INTO dbo.TestStructure (id, filler1, filler2)
        VALUES (@i, CAST(NEWID() AS char(36)), 'b');
END;
SELECT
    index_type_desc,
    page_count,
    record_count,
    avg_page_space_used_in_percent,
    avg_fragmentation_in_percent
FROM sys.DM_DB_INDEX_PHYSICAL_STATS
(DB_ID(N'PageSplittingBookActivity'), OBJECT_ID(N'dbo.TestStructure', N'U'), NULL, NULL, 'DETAILED');
GO

ALTER INDEX idx_cl_filler1 ON dbo.TestStructure REBUILD;
GO