USE master;
GO

IF DATABASEPROPERTYEX('ShrinkUnderInitial', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ShrinkUnderInitial SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ShrinkUnderInitial;
END
GO

CREATE DATABASE ShrinkUnderInitial;
GO

USE ShrinkUnderInitial;
GO

DBCC SQLPERF(LOGSPACE)
GO

DBCC LOGINFO;
GO

sp_spaceused
GO

--+ check physical file size before and after
DBCC SHRINKFILE(ShrinkUnderInitial_Log, 10)
GO

DBCC SQLPERF(LOGSPACE)
GO

DBCC LOGINFO;
GO

sp_spaceused
GO

SELECT * FROM
sys.databases WHERE name = 'ShrinkUnderInitial';
GO

SELECT *
FROM sys.database_files;
GO

--SELECT *
--FROM fn_dblog(null, null)
--GO

--DBCC SHRINKFILE(2, 1)
--GO

--BACKUP DATABASE ShrinkUnderInitial TO DISK='C:\_LOG\ShrinkUnderInitial.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
GO

BACKUP LOG ShrinkUnderInitial TO DISK='C:\_LOG\ShrinkUnderInitial.bak' WITH STATS = 10, DESCRIPTION = 'LOG';
GO

RESTORE FILELISTONLY FROM DISK = 'C:\_LOG\ShrinkUnderInitial.bak'
GO

RESTORE HEADERONLY FROM DISK = 'C:\_LOG\ShrinkUnderInitial.bak'
GO

DBCC SQLPERF(LOGSPACE)
GO

DBCC LOGINFO;
GO

DBCC OPENTRAN (DATABASE);
GO

SELECT * FROM
sys.databases WHERE name = 'ShrinkUnderInitial';
GO

SELECT *
FROM sys.database_files;
GO

--ALTER DATABASE ShrinkUnderInitial SET RECOVERY SIMPLE;
--GO

--RESTORE DATABASE ShrinkUnderInitial FROM DISK='P:\ShrinkUnderInitial.bak' WITH STATS = 10;
--GO

IF DATABASEPROPERTYEX('ShrinkUnderInitial', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ShrinkUnderInitial SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ShrinkUnderInitial;
END
GO