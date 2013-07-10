USE master;
GO

IF DATABASEPROPERTYEX('CompensationRecordsInRollback', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE CompensationRecordsInRollback SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CompensationRecordsInRollback;
END
GO

CREATE DATABASE CompensationRecordsInRollback;
GO

ALTER DATABASE CompensationRecordsInRollback SET RECOVERY SIMPLE;
GO

USE CompensationRecordsInRollback;
GO

ALTER DATABASE SAMPLE SET RECOVERY SIMPLE;
ALTER DATABASE SAMPLE SET AUTO_CREATE_STATISTICS OFF;
go

CREATE TABLE T (
ID int IDENTITY,
Code int,
Name char(4)
);
GO

SELECT * FROM fn_dblog(null,null);
go

CHECKPOINT
GO

INSERT T VALUES (1, 'a'), (2, 'b'), (3, 'c');
go

SELECT * FROM fn_dblog(NULL,NULL);
GO

CHECKPOINT
GO

CREATE CLUSTERED INDEX CI_T ON T (ID)
GO

SELECT * FROM fn_dblog(NULL,NULL);
GO

CHECKPOINT
GO

CREATE NONCLUSTERED INDEX NCI_T ON T (Code)
GO

SELECT * FROM fn_dblog(NULL,NULL);
GO

CHECKPOINT
GO

SELECT * FROM fn_dblog(NULL,NULL);
GO

BEGIN TRAN
INSERT T VALUES (RAND()*100, 'A')
GO 10

SELECT * FROM fn_dblog(NULL,NULL);
GO

ROLLBACK

SELECT * FROM fn_dblog(NULL,NULL);
GO

USE master;
GO

IF DATABASEPROPERTYEX('CompensationRecordsInRollback', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE CompensationRecordsInRollback SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CompensationRecordsInRollback;
END
GO