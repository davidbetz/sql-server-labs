USE master;
GO

IF DATABASEPROPERTYEX('RowOffsetStructure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RowOffsetStructure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RowOffsetStructure;
END
GO

CREATE DATABASE RowOffsetStructure;
GO

USE RowOffsetStructure;
GO

DBCC TRACEON (3604);
GO

CREATE FUNCTION dbo.GetLatestInRowPageID()
RETURNS INT
AS
BEGIN
	DECLARE @page_id INT;
	SELECT TOP 1 @page_id = allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('DataTableMax'), null, null, 'DETAILED') WHERE page_type = 1 ORDER BY allocated_page_page_id DESC;
	RETURN @page_id;
END
GO

CREATE TABLE DataTable (
	ID INT NOT NULL,
	Column1 CHAR(2000) NOT NULL DEFAULT(''),
	Column2 VARCHAR(8000) NULL,
	Column3 VARCHAR(8000) NULL
) ON [Primary];
GO

/* FITS IN-ROW (Column2) */
INSERT INTO DataTable (ID, Column2) VALUES (1, REPLICATE('A', 6000));
GO

DBCC IND ('RowOffsetStructure', 'DataTable', -1)
GO

/* ALSO FITS IN-ROW (Column3) */
INSERT INTO DataTable (ID, Column3) VALUES (1, REPLICATE('A', 6000));
GO

DBCC IND ('RowOffsetStructure', 'DataTable', -1)
GO

/* Column2 stays; Column3 goes to [BLOB Inline Root], Row-overflow data */
INSERT INTO DataTable (ID, Column2, Column3) VALUES (1, REPLICATE('A', 6000), REPLICATE('A', 6000));
GO

DBCC IND ('RowOffsetStructure', 'DataTable', -1)
GO

DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID()
DBCC PAGE ('RowOffsetStructure', 1, @page_id, 3);
GO

--Column3 = [BLOB Inline Root] Slot 0 Column 4 Offset 0x1f51 Length 24 Length (physical) 24

--Level = 0                           Unused = 0                          UpdateSeq = 1
--TimeStamp = 1011089408              Type = 2                            
--Link 0

--Size = 6000                         RowId = (1:284:0)                   


-- Both Column2 and Column3 go to [BLOB Inline Root], Row-overflow data */
INSERT INTO DataTable (ID, Column2, Column3) VALUES (1, REPLICATE('A', 8000), REPLICATE('A', 8000));
GO

DBCC IND ('RowOffsetStructure', 'DataTable', -1)
GO

DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID()
DBCC PAGE ('RowOffsetStructure', 1, @page_id, 3);
GO