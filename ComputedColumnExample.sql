USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('ComputedColumnExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ComputedColumnExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ComputedColumnExample;
END
GO

CREATE DATABASE ComputedColumnExample;
GO

USE ComputedColumnExample;
GO

DBCC TRACEON (3604);
GO

--++ heap
CREATE TABLE dbo.Data (
ID INT IDENTITY NOT NULL,
[Month] TINYINT NOT NULL,
[Year] INT NOT NULL,
--Segment AS CONVERT(date, CONVERT(VARCHAR(4), [Year]) + RIGHT('0' + CONVERT(VARCHAR(2), [Month]), 2) + '01', 112) PERSISTED NOT NULL,
Value INT NOT NULL
);
GO

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 20000
),
Years([Year])
AS
(
	SELECT Years.[Year]
	FROM
	(
		VALUES (2009), (2010), (2011), (2012), (2013), (2014)
	) Years ([Year])
),
Months ([Month])
AS
(
	SELECT 1
	UNION ALL
	SELECT [Month] + 1
	FROM Months
	WHERE [Month] < 12
)
INSERT dbo.Data
SELECT [Month], [Year], NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 20000)
GO

CREATE FUNCTION dbo.SameWithID(@Month TINYINT, @Year INT)
RETURNS DATE
WITH SCHEMABINDING
AS
BEGIN
	RETURN CONVERT(date, CONVERT(VARCHAR(4), @Year) + RIGHT('0' + CONVERT(VARCHAR(2), @Month), 2) + '01', 112);
END
GO

CREATE TABLE dbo.NonPersistedColumn (
	ID INT NOT NULL,
	[Month] TINYINT NOT NULL,
	[Year] INT NOT NULL,
	Segment AS (dbo.SameWithID([Month], [Year])),
	Value INT NOT NULL
);
GO

CREATE TABLE dbo.PersistedColumn (
	ID INT NOT NULL,
	[Month] TINYINT NOT NULL,
	[Year] INT NOT NULL,
	Segment AS (dbo.SameWithID([Month], [Year])) PERSISTED,
	Value INT NOT NULL
);
GO

SET STATISTICS TIME ON

PRINT '++++++++++++++++++NonPersistedColumn'
--CPU time = 3047 ms,  elapsed time = 6985 ms.
INSERT dbo.NonPersistedColumn
SELECT * FROM dbo.Data;
GO

PRINT '++++++++++++++++++PersistedColumn'
--CPU time = 9766 ms,  elapsed time = 11353 ms.
INSERT dbo.PersistedColumn
SELECT * FROM dbo.Data;
GO

PRINT '++++++++++++++++++NonPersistedColumn'
--CPU time = 4828 ms,  elapsed time = 5083 ms.
SELECT COUNT(*)
FROM dbo.NonPersistedColumn
WHERE Segment = '2010-10-01';
GO

PRINT '++++++++++++++++++PersistedColumn'
--CPU time = 110 ms,  elapsed time = 116 ms.
SELECT COUNT(*)
FROM dbo.PersistedColumn
WHERE Segment = '2010-10-01';
GO

PRINT '++++++++++++++++++NonPersistedColumn'
SELECT COUNT(*)
FROM dbo.NonPersistedColumn
OPTION (QUERYTRACEON 8649)
GO

PRINT '++++++++++++++++++NonPersistedColumn'
SELECT COUNT(*)
FROM dbo.PersistedColumn
OPTION (QUERYTRACEON 8649)
GO

PRINT '++++++++++++++++++Data'
SELECT COUNT(*)
FROM dbo.Data
OPTION (QUERYTRACEON 8649)
GO


CREATE NONCLUSTERED INDEX IDX_NonPersistedColumn
ON dbo.NonPersistedColumn(Segment)
GO

CREATE NONCLUSTERED INDEX IDX_PersistedColumn
ON dbo.PersistedColumn(Segment)
GO

DBCC FREEPROCCACHE
GO

PRINT '++++++++++++++++++NonPersistedColumn'
--CPU time = 0 ms,  elapsed time = 0 ms.
SELECT COUNT(*)
FROM dbo.NonPersistedColumn
WHERE Segment = '2010-10-01';
GO

PRINT '++++++++++++++++++PersistedColumn'
--CPU time = 125 ms,  elapsed time = 280 ms.
SELECT COUNT(*)
FROM dbo.PersistedColumn
WHERE Segment = '2010-10-01';
GO

SET STATISTICS TIME OFF