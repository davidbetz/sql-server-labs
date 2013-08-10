USE master;
GO

IF DATABASEPROPERTYEX('MultiTransaction', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE MultiTransaction SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE MultiTransaction;
END
GO

CREATE DATABASE MultiTransaction;
GO

ALTER DATABASE MultiTransaction SET RECOVERY SIMPLE;
GO

USE MultiTransaction;
GO

CREATE TABLE A (C1 char(1));
GO

BEGIN TRAN;

INSERT INTO A VALUES ('a');

BEGIN TRAN;

INSERT INTO A VALUES ('b');

COMMIT TRAN;

INSERT INTO A VALUES ('c');

ROLLBACK TRAN;

-- 0, only the first begin tran begins the transaction
SELECT COUNT(*) FROM A;

USE master;
GO

IF DATABASEPROPERTYEX('MultiTransaction', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE MultiTransaction SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE MultiTransaction;
END
GO