USE master;
GO

IF DATABASEPROPERTYEX('RowVersionExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RowVersionExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RowVersionExample;
END
GO

CREATE DATABASE RowVersionExample;
GO

ALTER DATABASE RowVersionExample SET RECOVERY SIMPLE;
GO

USE RowVersionExample;
GO

CREATE TABLE Table1
(
ID int identity,
Name varchar(100),
Version rowversion
);
GO

INSERT INTO Table1 (Name)
VALUES ('taco'), ('burger');
GO

SELECT * FROM Table1;
GO

SELECT @@DBTS
GO

UPDATE Table1
SET Name = 'Burrito'
WHERE ID = 1

SELECT * FROM Table1;
GO

SELECT @@DBTS
GO

USE master;
GO

IF DATABASEPROPERTYEX('RowVersionExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RowVersionExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RowVersionExample;
END
GO