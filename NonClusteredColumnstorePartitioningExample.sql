USE master;
GO

IF DATABASEPROPERTYEX('NonClusteredColumnstorePartitioningExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE NonClusteredColumnstorePartitioningExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE NonClusteredColumnstorePartitioningExample;
END
GO

CREATE DATABASE NonClusteredColumnstorePartitioningExample
ON PRIMARY (
    NAME='NonClusteredColumnstorePartitioningExampleData',
    FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample.MDF',
    SIZE = 250MB
)
LOG ON (
    NAME = 'NonClusteredColumnstorePartitioningExampleLog',
    FILENAME = 'C:\_LOG\NonClusteredColumnstorePartitioningExample.LDF',
    SIZE = 400MB,
    FILEGROWTH=100MB
);
GO

USE NonClusteredColumnstorePartitioningExample;
GO

DBCC TRACEON (3604);
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2009;
ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2010;
ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2011;
ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2012;
ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2013;
ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP CURRENT_FINANCE;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2009', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Year2009.ndf')
TO FILEGROUP YEAR2009;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2010', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Year2010.ndf')
TO FILEGROUP YEAR2010;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2011', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Year2011.ndf')
TO FILEGROUP YEAR2011;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2012', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Year2012.ndf')
TO FILEGROUP YEAR2012;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2013', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Year2013.ndf')
TO FILEGROUP YEAR2013;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='CURRENT_FINANCE', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Current.ndf')
TO FILEGROUP CURRENT_FINANCE;
GO

CREATE SCHEMA Partitioning;
GO

--++ heap rowstore
CREATE TABLE Partitioning.FactFinance (
ID int IDENTITY NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Segment date NOT NULL,
Value int NOT NULL
);
GO

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 20000
),
Years([Year])
AS
(
	SELECT Years.[Year]
	FROM
	(
		VALUES (2009), (2010), (2011), (2012), (2013), (2014), (2015)
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
INSERT Partitioning.FactFinance
SELECT [Month], [Year], CONVERT(date, CONVERT(VARCHAR(4), [Year]) + RIGHT('0' + CONVERT(VARCHAR(2), [Month]), 2) + '01', 112), NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 20000)
GO

ALTER TABLE Partitioning.FactFinance REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

CREATE PARTITION FUNCTION FinanceYearPF (date)
AS RANGE LEFT FOR VALUES ('2009-12-31', '2010-12-31', '2011-12-31', '2012-12-31', '2013-12-31');
GO

CREATE PARTITION SCHEME FinanceYearPS
AS PARTITION FinanceYearPF
TO (YEAR2009, YEAR2010, YEAR2011, YEAR2012, YEAR2013, CURRENT_FINANCE);
GO

CREATE CLUSTERED INDEX CI_Date
ON Partitioning.FactFinance (Segment DESC)
ON FinanceYearPS(Segment);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CSI_FactFinance
ON Partitioning.FactFinance ([Year], [Month], Value)
ON FinanceYearPS (Segment);
GO

SELECT 2009, $partition.FinanceYearPF('20090101');
SELECT 2010, $partition.FinanceYearPF('20100101');
SELECT 2011, $partition.FinanceYearPF('20110101');
SELECT 2012, $partition.FinanceYearPF('20120101');
SELECT 2013, $partition.FinanceYearPF('20130101');
SELECT 2014, $partition.FinanceYearPF('20140101');
SELECT 2015, $partition.FinanceYearPF('20150101');
GO

SELECT TOP 100 [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF('20090101') = 1

--++ partition 5 == CURRENT_FINANCE; 2013 is in 5
SELECT
TOP 10
$partition.FinanceYearPF(Segment) as PartitionNumber, Year, Month, Value
FROM Partitioning.FactFinance
WHERE Year = 2013
ORDER BY Year, Month
GO

--++ 480000
SELECT COUNT(*)
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF(Segment) = 5
GO

SELECT *
FROM sys.partition_functions
WHERE name = 'FinanceYearPF'
GO

SELECT P.*
FROM sys.partition_parameters P
INNER JOIN sys.partition_functions F on P.function_id = F.function_id
WHERE F.name = 'FinanceYearPF'
GO

SELECT V.*, P.*
FROM sys.partition_range_values V
INNER JOIN sys.partition_parameters P on V.parameter_id = P.parameter_id
INNER JOIN sys.partition_functions F on V.function_id = F.function_id
WHERE F.name = 'FinanceYearPF'
GO

--CREATE CLUSTERED COLUMNSTORE INDEX CSI_FactFinance ON Partitioning.FactFinance
--ON FinanceYearPS (Segment);

--ALTER DATABASE NonClusteredColumnstorePartitioningExample MODIFY FILEGROUP YEAR2009 READ_ONLY;
--ALTER DATABASE NonClusteredColumnstorePartitioningExample MODIFY FILEGROUP YEAR2010 READ_ONLY;
--ALTER DATABASE NonClusteredColumnstorePartitioningExample MODIFY FILEGROUP YEAR2011 READ_ONLY;
--ALTER DATABASE NonClusteredColumnstorePartitioningExample MODIFY FILEGROUP YEAR2012 READ_ONLY;
--GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILEGROUP YEAR2014;
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample ADD FILE (NAME='YEAR2014', FILENAME='H:\_DATA\NonClusteredColumnstorePartitioningExample_Year2014.ndf')
TO FILEGROUP YEAR2014
GO

ALTER PARTITION SCHEME FinanceYearPS NEXT USED YEAR2014
GO

ALTER INDEX CSI_FactFinance ON Partitioning.FactFinance DISABLE
GO

ALTER PARTITION FUNCTION FinanceYearPF ()
SPLIT RANGE ('2014-12-31');
GO

--++ columnstore still disabled
SELECT TOP 100 [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF('20090101') = 1
GO

ALTER INDEX CSI_FactFinance on Partitioning.FactFinance REBUILD
GO

--++ columnstore is used
SELECT TOP 100 [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF('20090101') = 1
GO

ALTER DATABASE NonClusteredColumnstorePartitioningExample SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO

SELECT 2009, $partition.FinanceYearPF('20090101');
SELECT 2010, $partition.FinanceYearPF('20100101');
SELECT 2011, $partition.FinanceYearPF('20110101');
SELECT 2012, $partition.FinanceYearPF('20120101');
SELECT 2013, $partition.FinanceYearPF('20130101');
SELECT 2014, $partition.FinanceYearPF('20140101');
SELECT 2015, $partition.FinanceYearPF('20150101');
GO

--++ 240000
SELECT COUNT(*)
FROM Partitioning.FactFinance
WHERE $partition.FinanceYearPF(Segment) = 6
GO

UPDATE STATISTICS Partitioning.FactFinance
GO

SELECT [Year], [Month], Value
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO

SELECT [Year], [Month]
FROM Partitioning.FactFinance
WHERE YEAR = 2010 AND MONTH = 8
GO
