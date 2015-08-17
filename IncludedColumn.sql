USE master;
GO

IF DATABASEPROPERTYEX('IncludedColumn', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IncludedColumn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IncludedColumn;
END
GO

CREATE DATABASE IncludedColumn;
GO

--ALTER DATABASE IncludedColumn SET RECOVERY SIMPLE;
--GO

USE IncludedColumn;
GO

CREATE TABLE FactTable (
ID INT IDENTITY NOT NULL,
CaptureDate datetime2(0) NOT NULL,
EntityID INT NOT NULL,
StateID INT NOT NULL,
Value INT NOT NULL
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

CREATE CLUSTERED INDEX CI_FactTable_ID
ON FactTable(ID)
GO

--+ select == predicate
CREATE NONCLUSTERED INDEX NCI_FactTable
ON FactTable (EntityID);
GO

--+ don't use index
SELECT EntityID
FROM FactTable WITH (INDEX(0))
WHERE EntityID = 12;
GO

SELECT EntityID
FROM FactTable
WHERE EntityID = 12;
GO

--+ select != predicate
CREATE NONCLUSTERED INDEX NCI_FactTable
ON FactTable (EntityID)
INCLUDE (StateID)
WITH DROP_EXISTING;
GO

SELECT StateID
FROM FactTable WITH (INDEX(0))
WHERE EntityID = 12;
GO

SELECT StateID
FROM FactTable
WHERE EntityID = 12;
GO

--+ select != predicate
CREATE NONCLUSTERED INDEX NCI_FactTable
ON FactTable (EntityID)
INCLUDE (StateID, CaptureDate)
WITH DROP_EXISTING;
GO

SELECT StateID, CaptureDate
FROM FactTable WITH (INDEX(0))
WHERE EntityID = 12;
GO

SELECT StateID, CaptureDate
FROM FactTable
WHERE EntityID = 12;
GO

--Run;
--GO

--DROP INDEX NCI_SalesOrderHeader ON SalesOrderHeader;
--GO

--CREATE CLUSTERED INDEX CI_FactTable_ID ON FactTable(ID)
--GO

--ALTER TABLE FactTable REBUILD WITH (DATA_COMPRESSION=ROW);
--GO

WITH
A([Year])
AS (
	SELECT DATEPART(year, CaptureDate) FROM FactTable
)
SELECT [Year]
FROM A
GROUP BY [Year]
ORDER BY [Year] DESC
GO

USE master;
GO

--BACKUP DATABASE IncludedColumn TO DISK='P:\IncludedColumn.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
--GO

--ALTER DATABASE IncludedColumn SET RECOVERY SIMPLE;
--GO

--RESTORE DATABASE IncludedColumn FROM DISK='P:\IncludedColumn.bak' WITH STATS = 10;
--GO

IF DATABASEPROPERTYEX('IncludedColumn', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IncludedColumn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IncludedColumn;
END
GO

--USE master;
--GO

--IF DATABASEPROPERTYEX('IncludedColumn', 'Status') IS NOT NULL
--BEGIN
--	ALTER DATABASE IncludedColumn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--	DROP DATABASE IncludedColumn;
--END
--GO

--CREATE DATABASE IncludedColumn
--ON PRIMARY (
--    NAME='IncludedColumn_Data',
--    FILENAME='H:\_DATA\IncludedColumn.MDF',
--    SIZE = 250MB
--)
--LOG ON (
--    NAME = 'IncludedColumn_Log',
--    FILENAME = 'C:\_LOG\IncludedColumn.LDF',
--    SIZE = 10MB,
--    FILEGROWTH=20%
--);
--GO

--ALTER DATABASE IncludedColumn SET RECOVERY SIMPLE;
--GO

--USE IncludedColumn;
--GO

--CREATE TABLE Contact (Id int primary key identity, FirstName char(10) DEFAULT 'F', LastName char(10) DEFAULT 'L', EmailAddress char(10) DEFAULT 'E');
--CREATE TABLE Employee (Id int primary key identity, Title char(10) DEFAULT 'T', ContactId int);
--CREATE TABLE SalesOrderHeader (SalesPersonId int primary key identity, SubTotal numeric(7,2) DEFAULT 100.24, OrderDate datetime DEFAULT CURRENT_TIMESTAMP);
--GO

--INSERT INTO Contact DEFAULT VALUES;
--INSERT INTO Employee DEFAULT VALUES;
--INSERT INTO SalesOrderHeader DEFAULT VALUES;
--GO

--CREATE PROC Run
--AS
--SELECT soh.SalesPersonId,
--c.FirstName + ' ' + c.LastName as FullName,
--c.EmailAddress,
--e.Title,
--soh.SubTotal,
--YEAR(soh.OrderDate) as Year
--FROM SalesOrderHeader soh
--INNER JOIN Employee e on soh.SalesPersonId = e.Id
--INNER JOIN Contact c on e.ContactId = c.Id
--WHERE soh.OrderDate >= '1/1/2012';
--GO

--Run;
--GO

--CREATE NONCLUSTERED INDEX NCI_SalesOrderHeader ON SalesOrderHeader (OrderDate) INCLUDE (SubTotal, SalesPersonId);
--GO

--Run;
--GO

--DROP INDEX NCI_SalesOrderHeader ON SalesOrderHeader;
--GO

--USE master;
--GO

--IF DATABASEPROPERTYEX('IncludedColumn', 'Status') IS NOT NULL DROP DATABASE IncludedColumn;
--GO