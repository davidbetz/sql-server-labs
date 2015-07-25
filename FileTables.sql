USE master;
GO

IF DATABASEPROPERTYEX('FileTables', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE FileTables SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE FileTables;
END
GO

EXEC sp_configure filestream_access_level, 2
RECONFIGURE

CREATE DATABASE FileTables
ON PRIMARY (
    NAME='FileTables_Data',
    FILENAME='H:\_DATA\FileTables.MDF',
    SIZE = 250MB
), 
FILEGROUP FSFG CONTAINS FILESTREAM (
    NAME='FileTables_FS',
    FILENAME='H:\_DATA\FileTables_FS.MDF'
) 
LOG ON (
    NAME = 'FileTables_Log',
    FILENAME = 'C:\_LOG\FileTables.LDF',
    SIZE = 10MB,
    FILEGROWTH=20%
)
WITH FILESTREAM (
	NON_TRANSACTED_ACCESS = FULL,
	DIRECTORY_NAME = N'FS'
)
GO

ALTER DATABASE FileTables SET RECOVERY SIMPLE;
GO

USE FileTables;
GO

--SELECT DB_NAME ( database_id ), * FROM sys.database_filestream_options;
--GO

CREATE TABLE DocumentStore as FileTable
WITH (FILETABLE_DIRECTORY = 'taco');
GO


INSERT INTO DocumentStore (name, file_stream)
SELECT 'myfile.pdf', * FROM OPENROWSET (
	BULK 'C:\temp\Test\myfile.pdf', SINGLE_BLOB) As taco;
GO

INSERT INTO DocumentStore (name, file_stream)
SELECT 'myfile2.pdf', * FROM OPENROWSET (
	BULK 'C:\temp\Test\myfile2.pdf', SINGLE_BLOB) As taco;
GO

SELECT [name], FILETABLEROOTPATH() + file_stream.GetFileNamespacePath() [FullPath]
FROM DocumentStore;
GO

SELECT [name] as FileName
FROM DocumentStore
WHERE CONTAINS(PROPERTY(file_stream, 'Title'), 'Data');

SELECT * FROM DocumentStore;
GO

SELECT FILETABLEROOTPATH('DocumentStore');
GO

SELECT file_stream.GetFileNamespacePath() FROM DocumentStore;
GO

USE master;
GO

IF DATABASEPROPERTYEX('FileTables', 'Status') IS NOT NULL DROP DATABASE FileTables;
GO