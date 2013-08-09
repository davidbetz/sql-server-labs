USE master;
GO

IF DATABASEPROPERTYEX('FakeBackup', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE FakeBackup SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE FakeBackup;
END
GO

CREATE DATABASE FakeBackup;
GO

ALTER DATABASE FakeBackup SET RECOVERY FULL;
GO

USE FakeBackup;
GO

CREATE TABLE A (Id int identity, C1 char(4) DEFAULT 'a', C2 char(4) DEFAULT 'b');
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

INSERT INTO A DEFAULT VALUES;
GO 100

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

-- completely valid, completely fake backup
BACKUP DATABASE FakeBackup TO DISK='NUL:';
GO

SELECT 1 as [FULL];
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

INSERT INTO A DEFAULT VALUES;
GO 100

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

-- also fake
BACKUP LOG FakeBackup TO DISK='NUL:';
GO

SELECT 1 as [XLOG];
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO


USE master;
GO

IF DATABASEPROPERTYEX('FakeBackup', 'Status') IS NOT NULL DROP DATABASE FakeBackup;
GO