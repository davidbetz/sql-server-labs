SET NOCOUNT ON
USE master;
GO

IF DATABASEPROPERTYEX('Big_TransactionLog', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE Big_TransactionLog SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Big_TransactionLog;
END
GO

CREATE DATABASE Big_TransactionLog;
GO

ALTER DATABASE Big_TransactionLog SET RECOVERY SIMPLE;
GO

USE Big_TransactionLog;
GO

-- status 2 = active, status 0 = inactive, there is no 1

CREATE TABLE BigRows (
c1 int IDENTITY,
c2 char (8000) default 'a'
)

INSERT INTO bigrows DEFAULT VALUES
GO 3000

DBCC LOGINFO

BEGIN TRAN
INSERT INTO bigrows DEFAULT VALUES

--will clear VLFs without transaction lock
CHECKPOINT

INSERT INTO bigrows DEFAULT VALUES
go 3000

CHECKPOINT

DBCC LOGINFO
DBCC SQLPERF (LOGSPACE)

ROLLBACK

SELECT * FROM sys.database_recovery_status WHERE database_id = db_id('big')
SELECT name, database_id, suser_sname(owner_sid) AS owner, state_desc, recovery_model_desc FROM sys.databases