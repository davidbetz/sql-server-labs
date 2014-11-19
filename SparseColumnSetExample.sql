USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('SparseColumnSetExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE SparseColumnSetExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE SparseColumnSetExample;
END
GO

CREATE DATABASE SparseColumnSetExample;
GO

USE SparseColumnSetExample;
GO

DBCC TRACEON (3604);
GO

CREATE FUNCTION dbo.GetLatestInRowPageID(@name varchar(20))
RETURNS INT
AS
BEGIN
	DECLARE @page_id INT;
	SELECT TOP 1 @page_id = allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID(@name), null, null, 'DETAILED') WHERE page_type = 1 ORDER BY allocated_page_page_id DESC;
	RETURN @page_id;
END
GO

CREATE TABLE SparseDemo
(
ID INT NOT NULL,
Col1 INT SPARSE,
Col2 VARCHAR(32) SPARSE,
Col3 INT SPARSE
);
GO

create table ColumnSetDemo
(
ID INT NOT NULL,
Col1 INT SPARSE,
Col2 VARCHAR(32) SPARSE,
Col3 INT SPARSE,
SparseColumns XML COLUMN_SET FOR ALL_SPARSE_COLUMNS
);
GO


INSERT INTO SparseDemo(ID, Col1) VALUES (1, 1);
INSERT INTO SparseDemo(ID, Col3) VALUES (2, 2);
INSERT INTO SparseDemo(ID, Col1, Col2) VALUES (3, 3, 'Col2');
GO

INSERT INTO ColumnSetDemo(ID,Col1,Col2,Col3)
SELECT ID, Col1, Col2, Col3 FROM SparseDemo;
GO

SELECT 'SparseDemo' AS [Table], * FROM SparseDemo;
SELECT 'ColumnSetDemo' AS [Table], * FROM ColumnSetDemo;
GO

INSERT INTO dbo.ColumnSetDemo(ID, SparseColumns)
	VALUES(4, '<col1>4</col1><col2>Insert data through column_set</col2>');
GO

SELECT 'INSERTED, SparseDemo' AS [Table], * FROM SparseDemo;
SELECT 'INSERTED, ColumnSetDemo' AS [Table], * FROM ColumnSetDemo;
GO

UPDATE dbo.ColumnSetDemo
SET SparseColumns = '<col2>Update data through column_set</col2>'
WHERE ID = 3;
GO

SELECT 'UPDATED, SparseDemo' AS [Table], * FROM SparseDemo;
SELECT 'UPDATED, ColumnSetDemo' AS [Table], * FROM ColumnSetDemo;
GO

SELECT ID, Col1, Col2, Col3 FROM dbo.ColumnSetDemo WHERE ID in (3,4);
GO