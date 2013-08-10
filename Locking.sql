USE master;
GO

IF DATABASEPROPERTYEX('Locking', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE Locking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Locking;
END
GO

CREATE DATABASE Locking;
GO

ALTER DATABASE Locking SET RECOVERY SIMPLE;
GO

USE Locking;
GO

CREATE TABLE dbo.Test1 (C1 INT);
GO

INSERT INTO dbo.Test1 VALUES (1);
GO

BEGIN TRAN;

DELETE dbo.Test1 WHERE C1 = 1;

--rowlock
SELECT dtl.request_session_id,
dtl.resource_database_id,
dtl.resource_associated_entity_id,
dtl.resource_type,
dtl.resource_description,
dtl.request_mode,
dtl.request_status
FROM sys.dm_tran_locks AS dtl
WHERE dtl.resource_type = 'RID';

ROLLBACK;
GO

CREATE CLUSTERED INDEX CI_Test1 ON Test1 (C1);
GO

BEGIN TRAN;

DELETE dbo.Test1 WHERE C1 = 1;

--key-lock
SELECT dtl.request_session_id,
dtl.resource_database_id,
dtl.resource_associated_entity_id,
dtl.resource_type,
dtl.resource_description,
dtl.request_mode,
dtl.request_status
FROM sys.dm_tran_locks AS dtl
WHERE dtl.resource_type = 'KEY';
GO

ROLLBACK;
GO

USE master;
GO

IF DATABASEPROPERTYEX('Locking', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE Locking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Locking;
END
GO