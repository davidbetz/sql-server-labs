USE master;
GO

IF DATABASEPROPERTYEX('WithResultSets', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE WithResultSets SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE WithResultSets;
END
GO

CREATE DATABASE WithResultSets;
GO

ALTER DATABASE WithResultSets SET RECOVERY SIMPLE;
GO

USE WithResultSets;
GO

CREATE TABLE FactTable (
ID int IDENTITY NOT NULL,
CaptureDate datetime2(0) NOT NULL,
EntityID int NOT NULL,
StateID int NOT NULL,
Value int NOT NULL
);
GO

;WITH NumericValue(Tracker)
AS
(
	SELECT 1
	UNION ALL
	SELECT Tracker + 1
	FROM NumericValue
	WHERE Tracker < 20000
)
INSERT FactTable
SELECT DATEADD(day, (ABS(CHECKSUM(NEWID())) % (60)) * -1, CURRENT_TIMESTAMP), RAND(CHECKSUM(NEWID())) * 100, RAND(CHECKSUM(NEWID())) * 20, ABS(CHECKSUM(NEWID()))
FROM NumericValue 
OPTION (MAXRECURSION 20000)
GO

CREATE PROC LoadFactData
AS
SELECT
ID
,CaptureDate
,EntityID
,StateID
,Value
FROM FactTable
GO

EXEC LoadFactData
GO

EXEC LoadFactData
WITH RESULT SETS (
	(
		[LineItemID] int NOT NULL
		,[PurchaseDate] datetime2(0) NOT NULL
		,[ProductID] int NOT NULL
		,StateID int NOT NULL
		,[Price] int NOT NULL
	)
)
GO

USE master;
GO

--BACKUP DATABASE WithResultSets TO DISK='P:\WithResultSets.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
--GO

--ALTER DATABASE WithResultSets SET RECOVERY SIMPLE;
--GO

--RESTORE DATABASE WithResultSets FROM DISK='P:\WithResultSets.bak' WITH STATS = 10;
--GO

IF DATABASEPROPERTYEX('WithResultSets', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE WithResultSets SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE WithResultSets;
END
GO