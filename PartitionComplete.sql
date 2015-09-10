USE master;
GO

SET NOCOUNT ON
GO

IF DATABASEPROPERTYEX('PartitionComplete', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE PartitionComplete SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE PartitionComplete;
END
GO

CREATE DATABASE PartitionComplete;
ON PRIMARY (
    NAME='PartitionCompleteData',
    FILENAME='H:\PartitionComplete.MDF',
    SIZE = 10MB,
    FILEGROWTH = 10%
)
LOG ON (
    NAME = 'PartitionCompleteLog',
    FILENAME = 'C:\_LOG\PartitionComplete.LDF',
    SIZE = 50MB,
    FILEGROWTH=50MB
);
GO

USE PartitionComplete;
GO

DBCC TRACEON (3604);
GO

ALTER DATABASE PartitionComplete ADD FILEGROUP YEAR2009;
ALTER DATABASE PartitionComplete ADD FILEGROUP YEAR2010;
ALTER DATABASE PartitionComplete ADD FILEGROUP YEAR2011;
ALTER DATABASE PartitionComplete ADD FILEGROUP YEAR2012;
ALTER DATABASE PartitionComplete ADD FILEGROUP YEAR2013;
ALTER DATABASE PartitionComplete ADD FILEGROUP CURRENT_FINANCE;
GO

ALTER DATABASE PartitionComplete ADD FILE (NAME='YEAR2009', FILENAME='E:\PartitionComplete_Year2009.ndf') TO FILEGROUP YEAR2009;
ALTER DATABASE PartitionComplete ADD FILE (NAME='YEAR2010', FILENAME='E:\PartitionComplete_Year2010.ndf') TO FILEGROUP YEAR2010;
ALTER DATABASE PartitionComplete ADD FILE (NAME='YEAR2011', FILENAME='G:\PartitionComplete_Year2011.ndf') TO FILEGROUP YEAR2011;
ALTER DATABASE PartitionComplete ADD FILE (NAME='YEAR2012', FILENAME='F:\PartitionComplete_Year2012.ndf') TO FILEGROUP YEAR2012;
ALTER DATABASE PartitionComplete ADD FILE (NAME='YEAR2013', FILENAME='H:\PartitionComplete_Year2013.ndf') TO FILEGROUP YEAR2013;
ALTER DATABASE PartitionComplete ADD FILE (NAME='CURRENT_FINANCE', FILENAME='H:\PartitionComplete_Current.ndf') TO FILEGROUP CURRENT_FINANCE;
GO

--ALTER DATABASE PartitionComplete SET ALLOW_SNAPSHOT_ISOLATION ON
--GO

ALTER DATABASE PartitionComplete SET READ_COMMITTED_SNAPSHOT ON
GO

CREATE SCHEMA DW;
GO

--++ heap rowstore
CREATE TABLE DW.FactFinance (
SurrogateKey int IDENTITY NOT NULL,
[Key] uniqueidentifier NOT NULL DEFAULT(NEWSEQUENTIALID()),
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Value int NOT NULL,
CONSTRAINT chk_Month CHECK ([Month] > 0 AND [Month] < 13),
CONSTRAINT chk_Year CHECK ([Year] > 2008 AND [Year] < 2016)
);
GO

ALTER TABLE DW.FactFinance SET (LOCK_ESCALATION = AUTO);
GO

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 300
),
Years([Year])
AS
(
	SELECT Years.[Year]
	FROM
	(
		VALUES (2009), (2010), (2011), (2012), (2013), (2014)
	) Years ([Year])
),
Months ([Month])
AS
(
	SELECT 1
	UNION ALL
	SELECT [Month] + 1
	FROM Months
	WHERE [Month] < 12
)
INSERT DW.FactFinance ([State], [Month], [Year], [Value])
SELECT
ABS(CHECKSUM(NEWID())) % 51,
[Month],
[Year],
NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 300);
GO

SELECT PARSENAME(CONVERT(varchar, CAST(COUNT(*) AS money), 1), 2) FROM DW.FactFinance;
GO

CREATE PARTITION FUNCTION FinanceYearPF (int)
AS RANGE LEFT FOR VALUES (2009, 2010, 2011, 2012, 2013);
GO

CREATE PARTITION SCHEME FinanceYearPS
AS PARTITION FinanceYearPF
TO (YEAR2009, YEAR2010, YEAR2011, YEAR2012, YEAR2013, CURRENT_FINANCE);
GO

CREATE CLUSTERED INDEX CI_FactFinance
ON DW.FactFinance ([Year])
ON FinanceYearPS([Year])
GO


sp_estimate_data_compression_savings 'DW', 'FactFinance', NULL, NULL, 'Row'
GO

sp_estimate_data_compression_savings 'DW', 'FactFinance', NULL, NULL, 'Page'
GO

ALTER INDEX CI_FactFinance
ON DW.FactFinance
REBUILD PARTITION=ALL
WITH (
    DATA_COMPRESSION = PAGE ON PARTITIONS (1),
    DATA_COMPRESSION = ROW ON PARTITIONS (2 TO 6)
)
GO

SELECT
p.partition_number,
p.data_compression_desc
FROM
sys.partitions p
INNER JOIN sys.tables t ON p.object_id = t.object_id
WHERE t.name = 'FactFinance';
GO

-------------------------------------------------------------------------

SELECT $partition.FinanceYearPF(2009) AS '2009',
$partition.FinanceYearPF(2010) AS '2010',
$partition.FinanceYearPF(2011) AS '2011',
$partition.FinanceYearPF(2012) AS '2012',
$partition.FinanceYearPF(2013) AS '2013',
$partition.FinanceYearPF(2014) AS '2014',
$partition.FinanceYearPF(2015) AS '2015';
GO

-------------------------------------------------------------------------

--+ 2009 kill
ALTER PARTITION FUNCTION FinanceYearPF () MERGE RANGE (2009);
GO

ALTER DATABASE PartitionComplete REMOVE FILE YEAR2009
ALTER DATABASE PartitionComplete REMOVE FILEGROUP YEAR2009
GO

--+ 2014 create
ALTER DATABASE PartitionComplete ADD FILEGROUP YEAR2014;
ALTER DATABASE PartitionComplete ADD FILE (NAME='YEAR2014', FILENAME='H:\PartitionComplete_YEAR2014.ndf') TO FILEGROUP YEAR2014;
ALTER PARTITION SCHEME FinanceYearPS NEXT USED YEAR2014
GO

ALTER PARTITION FUNCTION FinanceYearPF () SPLIT RANGE (2014);
GO

-------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX NCI_FactFinance_Month_Year_State
ON DW.FactFinance ([Year], [Month])
INCLUDE ([State]);
GO

SELECT [State]
FROM DW.FactFinance
WHERE [Year] = 2015 AND [Month] = 5
GO

-------------------------------------------------------------------------

--+ switch in
CREATE SCHEMA Staging;
GO

CREATE TABLE Staging.FactFinance (
ID int IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Value int NOT NULL,
CONSTRAINT chk_Month CHECK ([Month] > 0 AND [Month] < 13),
CONSTRAINT chk_Year CHECK ([Year] = 2015),
INDEX CI_FactFinance CLUSTERED ([Year])
)
ON CURRENT_FINANCE
WITH (
    DATA_COMPRESSION = ROW
)
GO

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 300
),
Months ([Month])
AS
(
	SELECT 1
	UNION ALL
	SELECT [Month] + 1
	FROM Months
	WHERE [Month] < 12
)
INSERT Staging.FactFinance ([State], [Month], [Year], [Value])
SELECT
ABS(CHECKSUM(NEWID())) % 51,
[Month],
2015,
NumericValue
FROM  Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 300);
GO

CREATE NONCLUSTERED INDEX NCI_FactFinance_Month_Year_State
ON Staging.FactFinance ([Year], [Month])
INCLUDE ([State]);
GO

ALTER TABLE Staging.FactFinance
SWITCH TO DW.FactFinance
PARTITION 6
GO

-------------------------------------------------------------------------

--+ switch out
CREATE SCHEMA Archive;
GO

CREATE TABLE Archive.FactFinance (
ID int IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Value int NOT NULL,
--CONSTRAINT chk_Month CHECK ([Month] > 0 AND [Month] < 13),
INDEX CI_FactFinance CLUSTERED ([Year])
)
ON YEAR2010
WITH (
    DATA_COMPRESSION = ROW
)
GO

ALTER TABLE DW.FactFinance
SWITCH PARTITION 1
TO Archive.FactFinance
GO

ALTER PARTITION FUNCTION FinanceYearPF () MERGE RANGE (2010);
GO

ALTER DATABASE PartitionComplete ADD FILEGROUP Archive;
ALTER DATABASE PartitionComplete ADD FILE (NAME='Archive', FILENAME='H:\PartitionComplete_Archive.ndf') TO FILEGROUP Archive;
GO

CREATE CLUSTERED COLUMNSTORE INDEX CI_FactFinance
ON Archive.FactFinance
WITH(
    DROP_EXISTING=ON,
    DATA_COMPRESSION=COLUMNSTORE_ARCHIVE
)
ON Archive;
GO

ALTER DATABASE PartitionComplete REMOVE FILE YEAR2010
GO

ALTER DATABASE PartitionComplete REMOVE FILEGROUP YEAR2010
GO

SELECT [State], COUNT([Month])
FROM Archive.FactFinance
WHERE [Year] = 2009
GROUP BY [State]
ORDER BY COUNT([Month]) DESC
GO

-------------------------------------------------------------------------

ALTER INDEX CI_FactFinance
ON DW.FactFinance
REBUILD Partition = 1
WITH (
    DATA_COMPRESSION=PAGE,
    ONLINE=ON (
        WAIT_AT_LOW_PRIORITY (
            MAX_DURATION = 10 minutes,
            ABORT_AFTER_WAIT = SELF
        )
    )
);
GO

-------------------------------------------------------------------------

select p.partition_number, * from sys.destination_data_spaces dds
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

