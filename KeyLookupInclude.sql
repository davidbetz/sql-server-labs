USE master;
GO

IF DATABASEPROPERTYEX('KeyLookupInclude', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE KeyLookupInclude SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE KeyLookupInclude;
END
GO

SET SHOWPLAN_XML OFF
GO

SET STATISTICS IO OFF
GO


CREATE DATABASE KeyLookupInclude;
GO

ALTER DATABASE KeyLookupInclude SET RECOVERY SIMPLE;
GO

USE KeyLookupInclude;
GO

CREATE SEQUENCE N START WITH 10 INCREMENT BY 10;
CREATE SEQUENCE G START WITH 5 INCREMENT BY 10;

CREATE TABLE Department (
Id int PRIMARY KEY IDENTITY,
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

CREATE UNIQUE NONCLUSTERED INDEX NCI_Department ON Department (Name ASC) INCLUDE (GroupName);
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

IF DATABASEPROPERTYEX('KeyLookupInclude', 'Status') IS NOT NULL DROP DATABASE KeyLookupInclude;
GO