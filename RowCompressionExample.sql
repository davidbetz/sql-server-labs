USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('RowCompressionExample', 'Status') IS NOT NULL
BEGIN
    ALTER DATABASE RowCompressionExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RowCompressionExample;
END
GO

CREATE DATABASE RowCompressionExample;
GO

USE RowCompressionExample;
GO

DBCC TRACEON (3604);
GO

CREATE FUNCTION GetLatestInRowPageID(@name varchar(20))
RETURNS INT
AS
BEGIN
    DECLARE @page_id INT;
    SELECT TOP 1 @page_id = allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID(@name), null, null, 'DETAILED') WHERE page_type = 1 ORDER BY allocated_page_page_id DESC;
    RETURN @page_id;
END
GO

CREATE TABLE DataTable (
    Int1 INT,
    Int2 INT,
    Int3 INT,
    VarChaR1 VARCHAR(1000),
    VarChaR2 VARCHAR(1000),
    Bit1 BIT,
    Bit2 BIT,
    Char1 CHAR(1000),
    Char2 CHAR(1000),
    Char3 CHAR(1000)
)
GO

INSERT INTO DataTable
VALUES (0, 2147483647, null, 'aaa', REPLICATE('b',1000), 0, 1, null, REPLICATE('c',1000), 'dddddddddd');

DBCC IND ('RowCompressionExample', 'DataTable', -1)
GO

DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID('DataTable')
DBCC PAGE ('RowCompressionExample', 1, @page_id, 3);
GO

CREATE TABLE DataTableCompressed (
    Int1 INT,
    Int2 INT,
    Int3 INT,
    VarChaR1 VARCHAR(1000),
    VarChaR2 VARCHAR(1000),
    Bit1 BIT,
    Bit2 BIT,
    Char1 CHAR(1000),
    Char2 CHAR(1000),
    Char3 CHAR(1000)
)
WITH (DATA_COMPRESSION=ROW);
GO

INSERT INTO DataTableCompressed
VALUES (0, 2147483647, null, 'aaa', REPLICATE('b',1000), 0, 1, null, REPLICATE('c',1000), 'dddddddddd');
GO

DBCC IND ('RowCompressionExample', 'DataTableCompressed', -1)
GO

DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID('DataTableCompressed')
DBCC PAGE ('RowCompressionExample', 1, @page_id, 3);
GO