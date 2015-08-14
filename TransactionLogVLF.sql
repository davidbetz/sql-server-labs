USE master;
GO

IF DATABASEPROPERTYEX('XLog', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE XLog SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE XLog;
END
GO

CREATE DATABASE XLog;
GO

USE XLog;
GO

CREATE TABLE FactTable (
ID int IDENTITY NOT NULL,
Filler char(7000) NOT NULL
);
GO

-- start a translation to prevent checkpoint
--BEGIN TRAN
;WITH NumericValue(Tracker)
AS
(
	SELECT 1
	UNION ALL
	SELECT Tracker + 1
	FROM NumericValue
	WHERE Tracker < 1700
)
INSERT FactTable
SELECT ''
FROM NumericValue 
OPTION (MAXRECURSION 1700)
GO

DBCC SQLPERF(LOGSPACE)
GO

DBCC LOGINFO;
GO

SELECT * FROM
sys.databases WHERE name = 'XLog';
GO

SELECT *
FROM sys.database_files;
GO

--SELECT *
--FROM fn_dblog(null, null)
--GO

--DBCC SHRINKFILE(2, 1)
--GO

DECLARE @FileLocation nvarchar(200);
SELECT @FileLocation = SUBSTRING(physical_name, 0, len(physical_name) - 9) FROM sys.master_files WHERE database_id = 1 AND file_id = 1;
DECLARE @LogLocation nvarchar(200) = @FileLocation + 'XLog.bak'

EXECUTE sp_executesql N'BACKUP DATABASE XLog TO DISK= ''@location'' WITH FORMAT, STATS = 10, DESCRIPTION = ''FULL'';', N'@location nvarchar(200)', @location=@LogLocation;
EXECUTE sp_executesql N'BACKUP LOG XLog TO DISK = ''@location'' WITH STATS = 10, DESCRIPTION = ''LOG''', N'@location nvarchar(200)', @location=@LogLocation;
EXECUTE sp_executesql N'RESTORE FILELISTONLY FROM DISK = ''@location''', N'@location nvarchar(200)', @location=@LogLocation;
EXECUTE sp_executesql N'RESTORE HEADERONLY FROM DISK = ''@location''', N'@location nvarchar(200)', @location=@LogLocation;
GO

DBCC SQLPERF(LOGSPACE)
GO

DBCC LOGINFO;
GO

DBCC OPENTRAN;
GO

SELECT * FROM
sys.databases WHERE name = 'XLog';
GO

SELECT *
FROM sys.database_files;
GO