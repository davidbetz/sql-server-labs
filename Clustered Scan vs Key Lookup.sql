--from Pro SQL Server Internals, p. 49

USE master;
GO

IF DATABASEPROPERTYEX('ClusteredScanVsKeyLookup', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ClusteredScanVsKeyLookup SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ClusteredScanVsKeyLookup;
END
GO

CREATE DATABASE ClusteredScanVsKeyLookup;
GO

USE ClusteredScanVsKeyLookup;
GO

SET NOCOUNT ON;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE dbo.Books
(
BookId int identity(1,1) not null,
Title nvarchar(256) not null,
-- International Standard Book Number
ISBN char(14) not null,
Placeholder char(150) null
);
GO

CREATE UNIQUE CLUSTERED INDEX IDX_Books_BookId on dbo.Books(BookId);
GO

-- 1,252,000 rows
;WITH Prefix(Prefix)
AS
(
SELECT 100
UNION ALL
SELECT Prefix + 1
FROM Prefix
WHERE Prefix < 600
)
,Postfix(Postfix)
as
(
SELECT 100000001
UNION ALL
SELECT Postfix + 1
FROM Postfix
WHERE Postfix < 100002500
)
INSERT INTO dbo.Books(ISBN, Title)
SELECT
CONVERT(char(3), Prefix) + '-0' + CONVERT(char(9),Postfix)
,'Title for ISBN' + CONVERT(char(3), Prefix) + '-0' + CONVERT(char(9),Postfix)
FROM Prefix CROSS JOIN Postfix
OPTION (MAXRECURSION 0);
GO

CREATE NONCLUSTERED INDEX IDX_Books_ISBN ON dbo.Books(ISBN);
GO

-- nonclustered seek + key lookup (11%)
SELECT * FROM dbo.Books WHERE ISBN like '210%'
GO

-- clustered scan (40%)
SELECT * FROM dbo.Books WHERE ISBN like '21[0-4]%'
GO

-- nonclustered seek + key lookup (49%)
SELECT * FROM dbo.Books WITH (INDEX = IDX_BOOKS_ISBN) WHERE ISBN like '21[0-4]%'
GO