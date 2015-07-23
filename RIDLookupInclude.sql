USE master;
GO

IF DATABASEPROPERTYEX('RIDLookupInclude', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RIDLookupInclude SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RIDLookupInclude;
END
GO

CREATE DATABASE RIDLookupInclude;
GO

ALTER DATABASE RIDLookupInclude SET RECOVERY SIMPLE;
GO

USE RIDLookupInclude;
GO

CREATE SEQUENCE N START WITH 10 INCREMENT BY 10;
CREATE SEQUENCE G START WITH 5 INCREMENT BY 10;

-- NO PK; SO, NO CLUSTERED INDEX
CREATE TABLE Department (
Id int IDENTITY,
Name int,
GroupName int
);
GO

INSERT INTO Department VALUES (NEXT VALUE FOR N, NEXT VALUE FOR G);
GO 100

SELECT 1 AS [CI on Id];
GO

SET SHOWPLAN_XML ON
GO

SET STATISTICS IO ON
GO

SELECT Id, Name, GroupName
FROM Department
WHERE Name = 1000;
GO

CREATE UNIQUE NONCLUSTERED INDEX NCI_Department ON Department (Name ASC);
GO

SELECT 1 AS [NCI on Name];
GO

SELECT Id, Name, GroupName
FROM Department
WHERE Name = 1000;
GO

DROP INDEX NCI_Department ON Department;
GO

-- Have to add Id to this one, because the Id is no longer the clustered index key
CREATE UNIQUE NONCLUSTERED INDEX NCI_Department ON Department (Name ASC) INCLUDE (Id, GroupName);
GO

SELECT 1 AS [NCI on Name, INCLUDE GroupName];
GO

SELECT Id, Name, GroupName
FROM Department
WHERE Name = 1000;
GO

SET STATISTICS IO OFF
GO

SET SHOWPLAN_XML OFF
GO

USE master;
GO

IF DATABASEPROPERTYEX('RIDLookupInclude', 'Status') IS NOT NULL DROP DATABASE RIDLookupInclude;
GO