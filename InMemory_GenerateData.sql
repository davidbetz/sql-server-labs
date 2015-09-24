USE master;
GO

IF DATABASEPROPERTYEX('InMemory_Generate', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE InMemory_Generate SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InMemory_Generate;
END
GO

CREATE DATABASE InMemory_Generate
ON PRIMARY (
    NAME='InMemory_Generate_Data',
    FILENAME='H:\_DATA\InMemory_Generate.MDF',
    SIZE = 250MB
),
FILEGROUP [INMemory] CONTAINS MEMORY_OPTIMIZED_DATA
	(
	NAME='IM',
	FILENAME='C:\_DATA\InMemory_Generate'
) 
LOG ON (
    NAME = 'InMemory_Generate_Log',
    FILENAME = 'C:\_LOG\InMemory_Generate.LDF',
    SIZE = 10MB,
    FILEGROWTH=20%
);
GO

ALTER DATABASE InMemory_Generate COLLATE Latin1_General_100_BIN2;
GO

USE InMemory_Generate;
GO

CREATE TABLE dbo.GeneratedData (
Segment int NOT NULL IDENTITY PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 100000000),
Month int NOT NULL,
Year int NOT NULL,
ProductID int NOT NULL,
Quantity int NOT NULL,
Discount int NOT NULL,
Value int NOT NULL,
INDEX IX_C1_C2 NONCLUSTERED (Month, Year) -- RANGE INDEX
) WITH (MEMORY_OPTIMIZED = ON);
GO

CREATE PROC GenerateData(@count int)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH(TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE=N'english')
	DECLARE @i int = 1
	SET @i = @i + 1
	WHILE @i < @count
	BEGIN
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		INSERT dbo.GeneratedData VALUES (1 + RAND() * 11, 2010 + RAND() * 4, RAND() *100, RAND() * 10, 2010 + RAND() * 100, RAND() * 4000)
		SET @i = @i + 1
	END
END
GO

GenerateData 10000
GO 1000000

/*
BACKUP DATABASE [InMemory] TO DISK = N'H:\_DATA\CkptDemo_data.bak'
WITH NOFORMAT, INIT, NAME = N'In Memory', SKIP,
NOREWIND, NOUNLOAD, STATS = 10;
GO

RESTORE DATABASE [InMemory] FROM DISK = N'H:\_DATA\CkptDemo_data.bak'
GO
*/

IF DATABASEPROPERTYEX('ColumnStoreArchive', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ColumnStoreArchive SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ColumnStoreArchive;
END
GO

CREATE DATABASE ColumnStoreArchive
ON PRIMARY (
    NAME='ColumnStoreArchive',
    FILENAME='H:\_DATA\ColumnStoreArchive.MDF',
    SIZE = 10MB,
    FILEGROWTH=20%
)
LOG ON (
    NAME = 'ClusteredColumnstoreExampleLog',
    FILENAME = 'C:\_LOG\ColumnStoreArchive.LDF',
    SIZE = 10MB,
    FILEGROWTH=20%
);
GO

use ColumnStoreArchive;
GO

--+ 
CREATE TABLE ColumnStoreData (
Segment int NOT NULL,
Month int NOT NULL,
Year int NOT NULL,
ProductID int NOT NULL,
Quantity int NOT NULL,
Discount int NOT NULL,
Value int NOT NULL
);
GO

INSERT INTO ColumnStoreArchive.dbo.ColumnStoreData
SELECT * FROM InMemory_Generate.dbo.GeneratedData
GO

SELECT count(*) FROM ColumnStoreData WITH (NOLOCK)
GO

DROP PROC dbo.GenerateData
GO

DROP TABLE dbo.GeneratedData
GO

ALTER TABLE ColumnStoreData REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

--++ then create CCSI
CREATE CLUSTERED COLUMNSTORE INDEX CCI_ColumnStoreData
ON ColumnStoreData
WITH (DATA_COMPRESSION=COLUMNSTORE_ARCHIVE)
GO

SELECT * FROM sys.column_store_row_groups
SELECT * FROM sys.column_store_segments
SELECT * FROM sys.column_store_dictionaries
GO

DBCC FREEPROCCACHE
SET STATISTICS IO ON

SELECT *
FROM sys.stats
WHERE object_id = OBJECT_ID('ColumnStoreData')
GO

select month, year
from ColumnStoreData
group by month, year
order by count(*) desc
GO

select top 10 Segment, count(*) from ColumnStoreData group by Segment
select top 10 Month, count(*) from ColumnStoreData group by Month
select top 10 Year, count(*) from ColumnStoreData group by Year
select top 10 Quantity, count(*) from ColumnStoreData group by Quantity
select top 10 Discount, count(*) from ColumnStoreData group by Discount
select top 10 Value, count(*) from ColumnStoreData group by Value

DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000001_108B795B') WITH HISTOGRAM
DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000002_108B795B') WITH HISTOGRAM
DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000003_108B795B') WITH HISTOGRAM
DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000004_108B795B') WITH HISTOGRAM
DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000005_108B795B') WITH HISTOGRAM
DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000006_108B795B') WITH HISTOGRAM
DBCC SHOW_STATISTICS('ColumnStoreData', '_WA_Sys_00000007_108B795B') WITH HISTOGRAM
GO

UPDATE STATISTICS ColumnStoreData
GO

IF DATABASEPROPERTYEX('InMemory_Generate', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE InMemory_Generate SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InMemory_Generate;
END
GO