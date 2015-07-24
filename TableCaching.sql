USE master;
GO

IF DATABASEPROPERTYEX('TableCaching', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TableCaching SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TableCaching;
END
GO

CREATE DATABASE TableCaching
ON PRIMARY (
    NAME='TableCaching_Data',
    FILENAME='H:\_DATA\TableCaching.MDF',
    SIZE = 250MB
)
LOG ON (
    NAME = 'TableCaching_Log',
    FILENAME = 'C:\_LOG\TableCaching.LDF',
    SIZE = 10MB,
    FILEGROWTH=10%
);
GO

ALTER DATABASE TableCaching SET RECOVERY SIMPLE;
GO

USE TableCaching;
GO

IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp;
GO

DBCC TRACEON (3604);
GO

SELECT
ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as RowNumber,
Operation,
Context,
AllocUnitName,
[Transaction Name],
[Description]
FROM sys.fn_dblog(null, null)
GO

CREATE PROC CreateAndDelete
AS
	CREATE TABLE #Temp (ID int IDENTITY, Value CHAR(1) DEFAULT ('A'));
	DROP TABLE #Temp;

CHECKPOINT
GO

CreateAndDelete

SELECT
ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as RowNumber,
Operation,
Context,
AllocUnitName,
[Transaction Name],
[Description]
FROM sys.fn_dblog(null, null)

DROP TABLE #Temp;
GO

USE master;
GO

IF DATABASEPROPERTYEX('TableCaching', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TableCaching SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TableCaching;
END
GO