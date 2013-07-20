USE master;
GO

IF DATABASEPROPERTYEX('SubStringLike', 'Status') IS NOT NULL DROP DATABASE SubStringLike;
GO

CREATE DATABASE SubStringLike;
GO

ALTER DATABASE SubStringLike SET RECOVERY SIMPLE;
GO

USE SubStringLike;
GO

CREATE TABLE E (
ID int IDENTITY PRIMARY KEY,
CID int NOT NULL,
JobTitle varchar(100)
);
GO

CREATE INDEX NCI_E on E(JobTitle);
GO

INSERT E SELECT 1, 'DOG CATCHER';
INSERT E SELECT 1, 'DOCTOR';
INSERT E SELECT 1, 'PLUMBER';
INSERT E SELECT 1, 'PILLAGER';
INSERT E SELECT 1, 'PIRATE';
GO

SET STATISTICS IO ON
DBCC FREEPROCCACHE
GO

SELECT ID, JobTitle
FROM E
WHERE SUBSTRING(JobTitle, 1, 1) = 'D'
GO

SELECT ID, JobTitle
FROM E
WHERE JobTitle LIKE 'D%'
GO

USE master;
GO

IF DATABASEPROPERTYEX('SubStringLike', 'Status') IS NOT NULL DROP DATABASE SubStringLike;
GO