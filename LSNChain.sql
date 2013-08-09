USE master;
GO

IF DATABASEPROPERTYEX('LSNChain', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE LSNChain SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE LSNChain;
END
GO

CREATE DATABASE LSNChain
GO

ALTER DATABASE LSNChain SET RECOVERY FULL;
GO

USE LSNChain;
GO

CREATE TABLE A (Id int identity, C1 char(4) DEFAULT 'a', C2 char(4) DEFAULT 'b');
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

INSERT INTO A DEFAULT VALUES;
GO 100

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

BACKUP DATABASE LSNChain TO DISK = 'P:\LSNChain.bak' WITH INIT, STATS=10;
GO

SELECT 1 as [FULL];
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

INSERT INTO A DEFAULT VALUES;
GO 100

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

BACKUP DATABASE LSNChain TO DISK = 'P:\LSNChain.bak' WITH DIFFERENTIAL, STATS=10;
GO

SELECT 1 as [DIFFERENTIAL];
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

INSERT INTO A DEFAULT VALUES;
GO 100

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

BACKUP LOG LSNChain TO DISK = 'P:\LSNChain.bak' WITH STATS=10;
GO

SELECT 1 as [XLOG];
GO

SELECT MIN([Current LSN]), MAX([Current LSN]) FROM fn_dblog(null, null)
GO

RESTORE HEADERONLY FROM DISK = 'P:\LSNChain.BAK';
GO

USE master;
GO

IF DATABASEPROPERTYEX('LSNChain', 'Status') IS NOT NULL DROP DATABASE LSNChain;
GO