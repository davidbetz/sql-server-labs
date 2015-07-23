USE master;
GO

IF DATABASEPROPERTYEX('RowSizePageAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RowSizePageAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RowSizePageAnalysis;
END
GO

CREATE DATABASE RowSizePageAnalysis;
GO

USE RowSizePageAnalysis;
GO

CREATE TABLE RowOK_8000_8000 (ID INT NOT NULL, Column1 VARCHAR(8000) NULL, Column2 VARCHAR(8000) NULL);
GO

INSERT RowOK_8000_8000
SELECT 1, 'A', 'B'
GO

--1	IN_ROW_DATA	10	IAM_PAGE	NULL	282
--1	IN_ROW_DATA	1	DATA_PAGE	282	281
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM RowOK_8000_8000
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('RowOK_8000_8000'), NULL, NULL, 'DETAILED')
GO

DROP TABLE RowOK_8000_8000;
CREATE TABLE RowOK_8000_8000 (ID INT NOT NULL, Column1 VARCHAR(8000) NULL, Column2 VARCHAR(8000) NULL);
GO

INSERT RowOK_8000_8000
SELECT 1, REPLICATE('M', 6000), REPLICATE('N', 6000)
GO

--1	IN_ROW_DATA	10	IAM_PAGE	NULL	284
--1	IN_ROW_DATA	1	DATA_PAGE	284	283
--3	ROW_OVERFLOW_DATA	10	IAM_PAGE	NULL	282
--3	ROW_OVERFLOW_DATA	3	TEXT_MIX_PAGE	282	281
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM RowOK_8000_8000
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('RowOK_8000_8000'), NULL, NULL, 'DETAILED')
GO

DROP TABLE RowOK_8000_8000;
CREATE TABLE RowOK_8000_8000 (ID INT NOT NULL, Column1 VARCHAR(8000) NULL, Column2 VARCHAR(8000) NULL);
GO

INSERT RowOK_8000_8000
SELECT 1, REPLICATE('Y', 8000), REPLICATE('Z', 8000)
GO

--1	IN_ROW_DATA	10	IAM_PAGE	NULL	284
--1	IN_ROW_DATA	1	DATA_PAGE	284	283
--3	ROW_OVERFLOW_DATA	10	IAM_PAGE	NULL	282
--3	ROW_OVERFLOW_DATA	3	TEXT_MIX_PAGE	282	281
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM RowOK_8000_8000
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('RowOK_8000_8000'), NULL, NULL, 'DETAILED')
GO

DROP TABLE RowOK_8000_8000;
GO

CREATE TABLE RowOK_8000_8000_max (ID INT NOT NULL, Column0 CHAR(4), Column1 VARCHAR(8000) NULL, Column2 VARCHAR(8000) NULL, Column3 VARCHAR(max) NULL);
GO

INSERT RowOK_8000_8000_max
SELECT 1, 'FOUR', 'A', 'B', 'C'
GO

--1	IN_ROW_DATA	10	IAM_PAGE	NULL	282
--1	IN_ROW_DATA	1	DATA_PAGE	282	281
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM RowOK_8000_8000_max
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('RowOK_8000_8000_max'), NULL, NULL, 'DETAILED')
GO

DROP TABLE RowOK_8000_8000_max;
CREATE TABLE RowOK_8000_8000_max (ID INT NOT NULL, Column0 CHAR(4), Column1 VARCHAR(8000) NULL, Column2 VARCHAR(8000) NULL, Column3 VARCHAR(max) NULL);
GO

INSERT RowOK_8000_8000_max
SELECT 1, 'FOUR', REPLICATE('M', 6000), REPLICATE('N', 6000), REPLICATE('O', 10000)
GO

--1	IN_ROW_DATA	10	IAM_PAGE	NULL	286
--1	IN_ROW_DATA	1	DATA_PAGE	286	285
--2	LOB_DATA	10	IAM_PAGE	NULL	284
--2	LOB_DATA	3	TEXT_MIX_PAGE	284	283
--3	ROW_OVERFLOW_DATA	10	IAM_PAGE	NULL	282
--3	ROW_OVERFLOW_DATA	3	TEXT_MIX_PAGE	282	281
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM RowOK_8000_8000_max
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('RowOK_8000_8000_max'), NULL, NULL, 'DETAILED')
GO

DROP TABLE RowOK_8000_8000_max;
CREATE TABLE RowOK_8000_8000_max (ID INT NOT NULL, Column0 CHAR(4), Column1 VARCHAR(8000) NULL, Column2 VARCHAR(8000) NULL, Column3 VARCHAR(max) NULL);
GO

INSERT RowOK_8000_8000_max
SELECT 1, 'FOUR', REPLICATE('X', 8000), REPLICATE('Y', 8000), REPLICATE('Z', 10000)
GO

--1	IN_ROW_DATA	10	IAM_PAGE	NULL	287
--1	IN_ROW_DATA	1	DATA_PAGE	287	286
--2	LOB_DATA	10	IAM_PAGE	NULL	285
--2	LOB_DATA	3	TEXT_MIX_PAGE	285	284
--3	ROW_OVERFLOW_DATA	10	IAM_PAGE	NULL	282
--3	ROW_OVERFLOW_DATA	3	TEXT_MIX_PAGE	282	281
--3	ROW_OVERFLOW_DATA	3	TEXT_MIX_PAGE	282	283
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM RowOK_8000_8000_max
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('RowOK_8000_8000_max'), NULL, NULL, 'DETAILED')
GO

DBCC TRACEON (3604)
GO

DBCC PAGE ('RowSizePageAnalysis', 1, 286, 3);
GO

USE master;
GO

IF DATABASEPROPERTYEX('RowSizePageAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RowSizePageAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RowSizePageAnalysis;
END
GO