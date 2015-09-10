USE master;
GO

SET NOCOUNT ON
GO

IF DATABASEPROPERTYEX('Huge', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE Huge SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Huge;
END
GO

CREATE DATABASE Huge
ON PRIMARY (
    NAME='HugeData',
    FILENAME='H:\Huge.MDF',
    SIZE = 10MB,
    FILEGROWTH = 10%
)
LOG ON (
    NAME = 'HugeLog',
    FILENAME = 'C:\_LOG\Huge.LDF',
    SIZE = 50MB,
    FILEGROWTH=50MB
);
GO

USE Huge;
GO

DBCC TRACEON (3604);
GO

ALTER DATABASE Huge ADD FILEGROUP YEAR2012;
ALTER DATABASE Huge ADD FILEGROUP YEAR2013;
ALTER DATABASE Huge ADD FILEGROUP YEAR2014;
ALTER DATABASE Huge ADD FILEGROUP CURRENT_FINANCE;
GO

ALTER DATABASE Huge ADD FILE (NAME='YEAR2012', FILENAME='E:\Huge_Year2012.ndf') TO FILEGROUP YEAR2012;
ALTER DATABASE Huge ADD FILE (NAME='YEAR2013', FILENAME='F:\Huge_Year2013.ndf') TO FILEGROUP YEAR2013;
ALTER DATABASE Huge ADD FILE (NAME='YEAR2014', FILENAME='G:\Huge_Year2014.ndf') TO FILEGROUP YEAR2014;
ALTER DATABASE Huge ADD FILE (NAME='CURRENT_FINANCE', FILENAME='H:\_DATA\Huge_Current.ndf') TO FILEGROUP CURRENT_FINANCE;
GO

ALTER DATABASE Huge SET READ_COMMITTED_SNAPSHOT ON
GO

CREATE SCHEMA Partitioning;
GO

CREATE PARTITION FUNCTION FinanceYearPF (int)
AS RANGE LEFT FOR VALUES (2012, 2013, 2014);
GO

CREATE PARTITION SCHEME FinanceYearPS
AS PARTITION FinanceYearPF
TO (YEAR2012, YEAR2013, YEAR2014, CURRENT_FINANCE);
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
ON FinanceYearPS([Year]);
GO

ALTER TABLE Partitioning.FactFinance ADD C1 char(1000) DEFAULT REPLICATE('a', 1000);
ALTER TABLE Partitioning.FactFinance ADD C2 char(1000) DEFAULT REPLICATE('b', 1000);
ALTER TABLE Partitioning.FactFinance ADD C3 char(1000) DEFAULT REPLICATE('c', 1000);
ALTER TABLE Partitioning.FactFinance ADD C4 char(1000) DEFAULT REPLICATE('d', 500);
GO

ALTER TABLE Partitioning.FactFinance SET (LOCK_ESCALATION=AUTO)
GO

CREATE PROC Partitioning.GenerateDataByDirectCTEByYear
@Year int
AS
WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 30000
),
Years([Year])
AS
(
	SELECT Years.[Year]
	FROM
	(
		VALUES (2010), (2011), (2012), (2013), (2014), (2015)
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
INSERT Partitioning.FactFinance ([State], [Month], [Year], [Value])
SELECT
ABS(CHECKSUM(NewId())) % 51,
[Month],
@Year,
NumericValue
FROM Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000);
GO

SELECT PARSENAME(CONVERT(varchar, CAST(COUNT(*) AS money), 1), 2) FROM Partitioning.FactFinance;

--------------------------------------------------------------------------------------

--ALTER TABLE Partitioning.FactFinance REBUILD WITH (DATA_COMPRESSION=PAGE);
--GO

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


SELECT 2009, $partition.FinanceYearPF(2009);
SELECT 2010, $partition.FinanceYearPF(2010);
SELECT 2011, $partition.FinanceYearPF(2011);
SELECT 2012, $partition.FinanceYearPF(2012);
SELECT 2013, $partition.FinanceYearPF(2013);
SELECT 2014, $partition.FinanceYearPF(2014);
SELECT 2015, $partition.FinanceYearPF(2015);
GO

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
