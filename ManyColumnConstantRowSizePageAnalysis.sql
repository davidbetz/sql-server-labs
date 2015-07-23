USE master;
GO

IF DATABASEPROPERTYEX('ManyColumnConstantRowSizePageAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ManyColumnConstantRowSizePageAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ManyColumnConstantRowSizePageAnalysis;
END
GO

CREATE DATABASE ManyColumnConstantRowSizePageAnalysis;
GO

USE ManyColumnConstantRowSizePageAnalysis;
GO

CREATE TABLE DataTableChar80 (ID INT IDENTITY NOT NULL);
GO

DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
	exec('ALTER TABLE DataTableChar80 ADD Column' +  @i + ' CHAR(80) NULL DEFAULT(''N'');')
SET @i = @i + 1
END
GO

-- one row per page, but IN_ROW_DATA
INSERT DataTableChar80 DEFAULT VALUES
SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM DataTableChar80
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('DataTableChar80'), NULL, NULL, 'DETAILED')
GO

USE master;
GO

IF DATABASEPROPERTYEX('ManyColumnConstantRowSizePageAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ManyColumnConstantRowSizePageAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ManyColumnConstantRowSizePageAnalysis;
END
GO