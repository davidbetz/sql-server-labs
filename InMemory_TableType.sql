USE master;
GO

SET NOCOUNT ON
GO

IF DATABASEPROPERTYEX('InMemory_TableType', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE InMemory_TableType SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InMemory_TableType;
END
GO

CREATE DATABASE InMemory_TableType
ON PRIMARY (
    NAME='InMemory_TableType_Data',
    FILENAME='H:\InMemory_TableType.MDF',
    SIZE = 250MB
),
FILEGROUP [INMemory] CONTAINS MEMORY_OPTIMIZED_DATA
	(
	NAME='IM',
	FILENAME='C:\_DATA\InMemory_TableType'
) 
LOG ON (
    NAME = 'InMemory_TableType_Log',
    FILENAME = 'C:\_LOG\InMemory_TableType.LDF',
    SIZE = 10MB,
    FILEGROWTH=20%
);
GO

ALTER DATABASE InMemory_TableType COLLATE Latin1_General_100_BIN2;
GO

USE InMemory_TableType;
GO

CREATE TYPE dbo.AccountModel AS TABLE (
	AccountNumber char(10) COLLATE Latin1_General_100_BIN2 NOT NULL,
	Sales decimal(15,2) NULL,
	Score int NULL,
	FutureEstimate int NULL
	INDEX AccountNumber HASH (AccountNumber) WITH (BUCKET_COUNT = 25000)
) WITH (MEMORY_OPTIMIZED = ON);
GO

CREATE TABLE FactStorage (
AccountNumber char(10) NOT NULL,
Sales decimal(15,2) NULL,
Score int NULL,
FutureEstimate int NULL
)
GO

DECLARE @Model AS dbo.AccountModel;

DECLARE @i int = 1
SET @i = @i + 1
WHILE @i < 300000
BEGIN
	INSERT @Model
	VALUES (
			LEFT(NEWID(), 10),
			1 + RAND() * 100,
			1 + RAND() * 100,
			1 + RAND() * 200
	)
	SET @i = @i + 1
END

INSERT FactStorage
SELECT * FROM @Model
GO

SELECT * FROM FactStorage
GO

IF DATABASEPROPERTYEX('InMemory_TableType', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE InMemory_TableType SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InMemory_TableType;
END
GO