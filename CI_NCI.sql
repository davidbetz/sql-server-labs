USE master;
GO

IF DATABASEPROPERTYEX('IndexKeySize', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexKeySize SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexKeySize;
END
GO

CREATE DATABASE IndexKeySize;
GO

USE IndexKeySize;
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
	BookID INT IDENTITY(1, 1) NOT NULL,
	Title NVARCHAR(256) NOT NULL,
	ISBN CHAR(14) NOT NULL,
	PlaceHolder CHAR(50) NULL
) ON [Primary];
GO

CREATE UNIQUE CLUSTERED INDEX IDX_DataTable_BookID ON DataTable(BookID);
GO

SET STATISTICS IO ON
GO

WITH Prefix(Prefix)
AS
(
	SELECT 100
	UNION ALL
	SELECT Prefix + 1
	FROM Prefix
	WHERE Prefix < 600
),
Postfix(Postfix)
AS
(
	SELECT 100000001
	UNION ALL
	SELECT Postfix + 1
	FROM Postfix
	WHERe Postfix < 100002500
)
INSERT INTO DataTable(ISBN, Title)
SELECT
CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9), Postfix),
'Title for ISBN' + CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9), Postfix)
FROM Prefix CROSS JOIN Postfix
OPTION(MAXRECURSION 0)
GO

CREATE NONCLUSTERED INDEX DataTable_ISBN_NCI ON DataTable(ISBN);
GO

SELECT * FROM DataTable
WHERE ISBN like '210%'
--Table 'DataTable'. Scan count 1, logical reads 7676, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
GO

SELECT * FROM DataTable
WHERE ISBN LIKE '21[0-4]%'
--Table 'DataTable'. Scan count 7, logical reads 21619, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
GO

SELECT * FROM DataTable
WITH (INDEX = DataTable_ISBN_NCI)
WHERE ISBN LIKE '21[0-4]%'
--Table 'DataTable'. Scan count 1, logical reads 38331, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
GO