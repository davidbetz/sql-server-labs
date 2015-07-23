USE master;
GO

IF DATABASEPROPERTYEX('ManyColumnRowSizePageAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ManyColumnRowSizePageAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ManyColumnRowSizePageAnalysis;
END
GO

CREATE DATABASE ManyColumnRowSizePageAnalysis;
GO

USE ManyColumnRowSizePageAnalysis;
GO

CREATE TABLE DataTable (ID INT IDENTITY NOT NULL);
GO

DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
	exec('ALTER TABLE DataTable ADD Column' +  @i + ' VARCHAR(8000) NULL DEFAULT(''N'');')
SET @i = @i + 1
END
GO

INSERT DataTable DEFAULT VALUES
GO

SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM DataTable
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('DataTable'), NULL, NULL, 'DETAILED')
GO

DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
	exec('UPDATE DataTable SET Column' +  @i + '=REPLICATE(''Z'', 6000)')
SET @i = @i + 1
END
GO

SELECT sys.fn_PhysLocFormatter (%%physloc%%), * FROM DataTable
SELECT allocation_unit_type, allocation_unit_type_desc, page_type, page_type_desc, allocated_page_iam_page_id, allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('DataTable'), NULL, NULL, 'DETAILED')
GO

DBCC TRACEON (3604)
GO

DBCC PAGE ('ManyColumnRowSizePageAnalysis', 1, 281, 3);
GO

USE master;
GO

IF DATABASEPROPERTYEX('ManyColumnRowSizePageAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ManyColumnRowSizePageAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ManyColumnRowSizePageAnalysis;
END
GO