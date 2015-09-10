USE master;
GO

SET NOCOUNT ON
GO

IF DATABASEPROPERTYEX('ClusteredColumnstorePartitioningInMemoryLoader', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ClusteredColumnstorePartitioningInMemoryLoader;
END
GO

CREATE DATABASE ClusteredColumnstorePartitioningInMemoryLoader
ON PRIMARY (
    NAME='ClusteredColumnstorePartitioningInMemoryLoaderData',
    FILENAME='H:\ClusteredColumnstorePartitioningInMemoryLoader.MDF',
    SIZE = 10MB,
    FILEGROWTH = 10%
)
LOG ON (
    NAME = 'ClusteredColumnstorePartitioningInMemoryLoaderLog',
    FILENAME = 'C:\_LOG\ClusteredColumnstorePartitioningInMemoryLoader.LDF',
    SIZE = 500MB,
    FILEGROWTH=500MB
);
GO

USE ClusteredColumnstorePartitioningInMemoryLoader;
GO

DBCC TRACEON (3604);
GO

--ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2010;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2011;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2012;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2013;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2014;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP CURRENT_FINANCE;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader COLLATE Latin1_General_100_BIN2;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader
ADD FILEGROUP MD CONTAINS MEMORY_OPTIMIZED_DATA;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader
ADD FILE (NAME='MD', FILENAME='G:\ClusteredColumnstorePartitioningInMemoryLoader_InMemory') TO FILEGROUP MD;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2010', FILENAME='E:\ClusteredColumnstorePartitioningInMemoryLoader_Year2010.ndf')
TO FILEGROUP YEAR2010;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2011', FILENAME='G:\ClusteredColumnstorePartitioningInMemoryLoader_Year2011.ndf')
TO FILEGROUP YEAR2011;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2012', FILENAME='F:\ClusteredColumnstorePartitioningInMemoryLoader_Year2012.ndf')
TO FILEGROUP YEAR2012;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2013', FILENAME='H:\ClusteredColumnstorePartitioningInMemoryLoader_Year2013.ndf')
TO FILEGROUP YEAR2013;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2014', FILENAME='H:\ClusteredColumnstorePartitioningInMemoryLoader_YEAR2014.ndf')
TO FILEGROUP YEAR2014;
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='CURRENT_FINANCE', FILENAME='C:\_DATA\ClusteredColumnstorePartitioningInMemoryLoader_Current.ndf')
TO FILEGROUP CURRENT_FINANCE;
GO

CREATE SCHEMA Partitioning;
GO

--++ heap rowstore
CREATE TABLE Partitioning.FactFinance (
ID int IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Value int NOT NULL,
CONSTRAINT chk_Month CHECK ([Month] > 0 AND [Month] < 13),
CONSTRAINT chk_Year CHECK ([Year] > 2009 AND [Year] < 2016)
)
--ON FinanceYearPS([Year]);
GO

CREATE TYPE Partitioning.FinanceModel AS TABLE (
	ID int NOT NULL,
	[State] tinyint NOT NULL,
	[Month] tinyint NOT NULL,
	[Year] int NOT NULL,
	Value int NOT NULL
	INDEX ID HASH (ID) WITH (BUCKET_COUNT = 300000)
) WITH (MEMORY_OPTIMIZED = ON);
GO

SELECT PARSENAME(CONVERT(varchar, CAST(COUNT(*) AS money), 1), 2) FROM Partitioning.FactFinance;

--------------------------------------------------------------------------------------

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader SET ALLOW_SNAPSHOT_ISOLATION ON
GO

--ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader SET READ_COMMITTED_SNAPSHOT ON
--GO

ALTER TABLE Partitioning.FactFinance REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

CREATE PARTITION FUNCTION FinanceYearPF (int)
AS RANGE LEFT FOR VALUES (2010, 2011, 2012, 2013, 2014);
GO

CREATE PARTITION SCHEME FinanceYearPS
AS PARTITION FinanceYearPF
TO (YEAR2010, YEAR2011, YEAR2012, YEAR2013, YEAR2014, CURRENT_FINANCE);
GO

--++ create CI first (CI is required when partitioning; go straight to CCSI when not using partitioning)
CREATE CLUSTERED INDEX CI_FactFinance
ON Partitioning.FactFinance ([Year]))
ON FinanceYearPS([Year]); -- must equal partition column
GO

--++ then create CCSI
CREATE CLUSTERED COLUMNSTORE INDEX CI_FactFinance
ON Partitioning.FactFinance
WITH (DROP_EXISTING=ON)
ON FinanceYearPS ([Year]); -- must equal partition column
GO

SELECT PARSENAME(CONVERT(varchar, CAST(COUNT(*) AS money), 1), 2) FROM Partitioning.FactFinance (NOLOCK)
GO

SELECT 2009, $partition.FinanceYearPF(2009);
SELECT 2010, $partition.FinanceYearPF(2010);
SELECT 2011, $partition.FinanceYearPF(2011);
SELECT 2012, $partition.FinanceYearPF(2012);
SELECT 2013, $partition.FinanceYearPF(2013);
SELECT 2014, $partition.FinanceYearPF(2014);
SELECT 2015, $partition.FinanceYearPF(2015);
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2009;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2009', FILENAME='H:\ClusteredColumnstorePartitioningInMemoryLoader_YEAR2009.ndf') TO FILEGROUP YEAR2009;
ALTER PARTITION SCHEME FinanceYearPS NEXT USED YEAR2009
ALTER PARTITION FUNCTION FinanceYearPF () SPLIT RANGE (2009);
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2008;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2008', FILENAME='H:\ClusteredColumnstorePartitioningInMemoryLoader_YEAR2008.ndf') TO FILEGROUP YEAR2008;
ALTER PARTITION SCHEME FinanceYearPS NEXT USED YEAR2008
ALTER PARTITION FUNCTION FinanceYearPF () SPLIT RANGE (2008);
GO

ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILEGROUP YEAR2007;
ALTER DATABASE ClusteredColumnstorePartitioningInMemoryLoader ADD FILE (NAME='YEAR2007', FILENAME='H:\ClusteredColumnstorePartitioningInMemoryLoader_YEAR2007.ndf') TO FILEGROUP YEAR2007;
ALTER PARTITION SCHEME FinanceYearPS NEXT USED YEAR2007
ALTER PARTITION FUNCTION FinanceYearPF () SPLIT RANGE (2007);
GO

--++ columnstore is used
SELECT TOP 100 $partition.FinanceYearPF([Year]), [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE [Year] = 2014
GO

--++ 240000
SELECT COUNT(*)
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF([Year]) = 6
GO

UPDATE STATISTICS Partitioning.FactFinance
GO

CREATE NONCLUSTERED INDEX NCI_FactFinance_Month_Year_State
ON Partitioning.FactFinance ([Year])
INCLUDE ([State])
GO


select ds.name, ips.*
from sys.dm_db_index_physical_stats(DB_ID('ClusteredColumnstorePartitioningInMemoryLoader'), OBJECT_ID('Partitioning.FactFinance'), 1, 9, 'LIMITED') ips
inner join sys.destination_data_spaces dds on ips.partition_number = dds.destination_id
inner join sys.data_spaces ds on dds.data_space_id = ds.data_space_id

DECLARE @Year int = 2015;
DECLARE @TimeElapsed int;
DECLARE @RowCount bigint;
EXEC Partitioning.GenerateDataByDirectCTEByYear @Year, @TimeElapsed OUTPUT, @RowCount OUTPUT
EXEC Partitioning.GenerateDataByDirectCTEByYear @Year, @TimeElapsed OUTPUT, @RowCount OUTPUT
EXEC Partitioning.GenerateDataByDirectCTEByYear @Year, @TimeElapsed OUTPUT, @RowCount OUTPUT
EXEC Partitioning.GenerateDataByDirectCTEByYear @Year, @TimeElapsed OUTPUT, @RowCount OUTPUT
EXEC Partitioning.GenerateDataByDirectCTEByYear @Year, @TimeElapsed OUTPUT, @RowCount OUTPUT

select ds.name, ips.*
from sys.dm_db_index_physical_stats(DB_ID('ClusteredColumnstorePartitioningInMemoryLoader'), OBJECT_ID('Partitioning.FactFinance'), 1, 9, 'LIMITED') ips
inner join sys.destination_data_spaces dds on ips.partition_number = dds.destination_id
inner join sys.data_spaces ds on dds.data_space_id = ds.data_space_id


ALTER INDEX CI_FactFinance
ON Partitioning.FactFinance
REBUILD Partition = 9
WITH (
    ONLINE=ON (
        WAIT_AT_LOW_PRIORITY (
            MAX_DURATION = 10 minutes,
            ABORT_AFTER_WAIT = SELF
        )
    )
)

select * from sys.dm_tran_locks

SELECT [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO

SELECT [Year], [Month]
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO

--++ FASTEST
SELECT Segment
FROM Partitioning.FactFinance
WHERE Segment = '2009-11-01'
GO

SELECT [Year], [Month], State
FROM Partitioning.FactFinance
WHERE [Year] = 2010 AND [Month] = 8
GO

SELECT * FROM sys.column_store_segments
SELECT * FROM sys.column_store_dictionaries

SELECT * FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('ClusteredColumnstorePartitioningInMemoryLoader'), NULL, NULL, 'DETAILED')



select * from sys.destination_data_spaces dds
inner join sys.data_spaces ds on dds.data_space_id = ds.data_space_id
inner join sys.partition_schemes ps on dds.partition_scheme_id = ps.data_space_id
inner join sys.partition_functions pf on ps.function_id = pf.function_id
left join sys.partition_range_values rv on pf.function_id = rv.function_id and dds.destination_id = case pf.boundary_value_on_right when 0 then rv.boundary_id else rv.boundary_id + 1 end
left join sys.indexes i on dds.partition_scheme_id = i.data_space_id
left join sys.partitions p on i.object_id = p.object_id and i.index_id = p.index_id and dds.destination_id = p.partition_number
left join sys.dm_db_partition_stats dbps on p.object_id = dbps.object_id and p.partition_id = dbps.partition_id



select * from sys.partitions p
inner join sys.objects o on p.object_id = o.object_id and o.is_ms_shipped = 0
left join sys.dm_db_partition_stats dbps on p.object_id = dbps.object_id and p.partition_id = dbps.partition_id
inner join sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id
inner join sys.data_spaces mappedto on i.data_space_id = mappedto.data_space_id
left join sys.destination_data_spaces dds on i.data_space_id = dds.partition_scheme_id and p.partition_number = dds.destination_id
left join sys.data_spaces partitionds on dds.data_space_id = partitionds.data_space_id
left join sys.partition_schemes ps on dds.partition_scheme_id = ps.data_space_id
left join sys.partition_functions pf on ps.function_id = pf.function_id
left join sys.partition_range_values rv on pf.function_id = rv.function_id and dds.destination_id = case pf.boundary_value_on_right when 0 then rv.boundary_id else rv.boundary_id + 1 end
