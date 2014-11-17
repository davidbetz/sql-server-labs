--BACKUP DATABASE Finance TO DISK = 'f:\_data\Finance.bak' WITH INIT;
USE master;
GO

ALTER DATABASE Finance SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE Finance
FROM DISK = 'F:_DATA\Finance.bak'
WITH
MOVE 'Finance' TO 'H:\_DATA\Finance.mdf',
MOVE 'Finance_log' TO 'C:\_LOG\Finance.ldf',
REPLACE,
STATS=10;
GO

ALTER DATABASE Finance ADD FILEGROUP YEAR2011;
GO

ALTER DATABASE Finance ADD FILEGROUP YEAR2012;
GO

ALTER DATABASE Finance ADD FILEGROUP YEAR2013;
GO

ALTER DATABASE Finance ADD FILE (
NAME='YEAR2011',
FILENAME='f:\_data\Finance_Year2011.ndf'
)
TO FILEGROUP YEAR2011;
GO

ALTER DATABASE Finance ADD FILE (
NAME='YEAR2012',
FILENAME='f:\_data\Finance_Year2012.ndf'
)
TO FILEGROUP YEAR2012;
GO

ALTER DATABASE Finance ADD FILE (
NAME='YEAR2013',
FILENAME='f:\_data\Finance_Year2013.ndf'
)
TO FILEGROUP YEAR2013;
GO

USE Finance;
GO

sp_estimate_data_compression_savings 'dbo', 'Payment', NULL, NULL, 'Row'
GO
sp_estimate_data_compression_savings 'dbo', 'Payment', NULL, NULL, 'Page'
GO

ALTER TABLE Payment REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

/*
SELECT o.name, i.name, f.*
FROM sys.indexes i
INNER JOIN sys.filegroups f ON i.data_space_id = f.data_space_id
INNER JOIN sys.objects o ON i.object_id = o.object_id
WHERE f.name like 'DW%' OR f.name like 'YEAR%'
*/
GO

/*
-- LEFT
CREATE PARTITION FUNCTION PaymentYearPF (date)
AS RANGE LEFT FOR VALUES ('20120101', '20130101');
GO

CREATE PARTITION SCHEME PaymentYearPS
AS PARTITION PaymentYearPF
TO (YEAR2011, YEAR2012, YEAR2013);
GO

-- this means: YEAR2011, 20120101, YEAR2012, 20130101, YEAR2013
*/

/*
--RIGHT
CREATE PARTITION FUNCTION PaymentYearPF (date)
AS RANGE RIGHT FOR VALUES ('20110101', '20120101', '20130101');
GO

CREATE PARTITION SCHEME PaymentYearPS
AS PARTITION PaymentYearPF
TO ([PRIMARY], YEAR2011, YEAR2012, YEAR2013);
GO

-- this means: [PRIMARY], 20110101, YEAR2011, 20120101, YEAR2012, 20130101, YEAR2013

*/

CREATE CLUSTERED INDEX CI_Payment
ON Payment (date DESC)
WITH (DROP_EXISTING=ON)
ON PaymentYearPS(date);
GO

ALTER DATABASE Finance MODIFY FILEGROUP YEAR2011 READ_ONLY;
GO

ALTER DATABASE Finance MODIFY FILEGROUP YEAR2012 READ_ONLY;
GO

SELECT $partition.PaymentYearPF('20100101');
SELECT $partition.PaymentYearPF('20110101');
SELECT $partition.PaymentYearPF('20120101');
SELECT $partition.PaymentYearPF('20130101');
SELECT $partition.PaymentYearPF('20140101');
GO

sp_help Payment

-- a better verify is to try to add somethign to 2011 or 2012 when the YEAR2011
-- and YEAR2012 filegroups are READ_ONLY
SELECT
$partition.PaymentYearPF(Date), Date, Name
FROM Payment
ORDER BY Date, Time
GO

INSERT Payment
SELECT 'a', '2011-01-02', '12:00', 'b', 12.00, '', '', 'c';
GO

SELECT *
FROM Payment
WHERE date >= '20110101' and date < '20120101';
GO

SET STATISTICS IO ON
GO

ShowXByDay
GO

ShowDailySpending
GO

SpendingByMonth
GO

SET STATISTICS IO OFF

-- ImportLog 'H:\Downloads\Download (3).txt'

-- UpdateDebit