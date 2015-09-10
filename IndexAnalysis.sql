USE master;
GO

IF DATABASEPROPERTYEX('IndexAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexAnalysis;
END
GO

CREATE DATABASE IndexAnalysis;
GO

USE IndexAnalysis;
GO

IF OBJECT_ID('Sample', 'U') IS NOT NULL
    DROP TABLE Sample;
GO

CREATE TABLE Sample (
    col1 int NOT NULL IDENTITY,
    col2 int NOT NULL DEFAULT 2,
    col3 char(100) NOT NULL DEFAULT 'c',
    col4 char(7900) NOT NULL DEFAULT 'd'
);
GO

INSERT INTO Sample
    DEFAULT VALUES;
GO 1000

SELECT
    col1,
    col2,
    col3,
    col4 INTO Sample_CI
FROM Sample
GO
CHECKPOINT
GO
SELECT
    col1,
    col2,
    col3,
    col4 INTO Sample_NCIU
FROM Sample
GO
CHECKPOINT
GO
SELECT
    col1,
    col2,
    col3,
    col4 INTO Sample_NCI
FROM Sample
GO
CHECKPOINT
GO
SELECT
    col1,
    col2,
    col3,
    col4 INTO Sample_NCI_Include
FROM Sample
GO
CHECKPOINT
GO
SELECT
    col1,
    col2,
    col3,
    col4 INTO Sample_NCI_Filter
FROM Sample
GO
CHECKPOINT
GO
SELECT
    col1,
    col2,
    col3,
    col4 INTO Sample_NCI_Include_Filter
FROM Sample
GO
CHECKPOINT
GO
CREATE CLUSTERED INDEX CI_Sample ON Sample_CI (col1)
GO
CHECKPOINT
GO
CREATE NONCLUSTERED INDEX NCI_Sample ON Sample_NCI (col1)
GO
CHECKPOINT
GO
CREATE UNIQUE NONCLUSTERED INDEX NCIU_Sample ON Sample_NCIU (col1)
GO
CHECKPOINT
GO
CREATE NONCLUSTERED INDEX NCII_Sample ON Sample_NCI_Include (col1) INCLUDE (col2)
GO
CHECKPOINT
GO
CREATE NONCLUSTERED INDEX NCIF_Sample ON Sample_NCI_Filter (col1) WHERE col2 >= 1000 AND col2 < 2000
GO
CHECKPOINT
GO
CREATE NONCLUSTERED INDEX NCIFI_Sample ON Sample_NCI_Include_Filter (col1) INCLUDE (col2) WHERE col2 >= 1000 AND col2 < 2000
GO
CHECKPOINT
GO

/*
TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
        EXEC ('DBCC IND (IndexAnalysis, Sample, 1)');
GO
SELECT *
FROM sp_tablepages
ORDER BY IndexLevel DESC, PrevPagePID;
go
*/

SELECT
    index_type_desc,
    index_depth,
    index_level,
    record_count,
    page_count,
    avg_page_space_used_in_percent,
    min_record_size_in_bytes,
    max_record_size_in_bytes,
    avg_record_size_in_bytes
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID('IndexAnalysis'), OBJECT_ID('Sample'), NULL, NULL, 'DETAILED');
GO
SELECT
    index_type_desc,
    index_depth,
    index_level,
    record_count,
    page_count,
    avg_page_space_used_in_percent,
    min_record_size_in_bytes,
    max_record_size_in_bytes,
    avg_record_size_in_bytes
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID('IndexAnalysis'), OBJECT_ID('Sample_CI'), NULL, NULL, 'DETAILED');
GO
SELECT
    index_type_desc,
    index_depth,
    index_level,
    record_count,
    page_count,
    avg_page_space_used_in_percent,
    min_record_size_in_bytes,
    max_record_size_in_bytes,
    avg_record_size_in_bytes
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID('IndexAnalysis'), OBJECT_ID('Sample_NCI'), NULL, NULL, 'DETAILED');
GO
SELECT
    index_type_desc,
    index_depth,
    index_level,
    record_count,
    page_count,
    avg_page_space_used_in_percent,
    min_record_size_in_bytes,
    max_record_size_in_bytes,
    avg_record_size_in_bytes
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID('IndexAnalysis'), OBJECT_ID('Sample_NCIU'), NULL, NULL, 'DETAILED');
GO