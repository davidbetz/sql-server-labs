USE master;
GO

IF DATABASEPROPERTYEX('ParitioningSimple', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ParitioningSimple SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ParitioningSimple;
END
GO

CREATE DATABASE ParitioningSimple
ON PRIMARY (
    NAME='ParitioningSimple_Data',
    FILENAME='C:\_DATA\ParitioningSimple.MDF',
    SIZE = 250MB
)
LOG ON (
    NAME = 'ParitioningSimple_Log',
    FILENAME = 'C:\_LOG\ParitioningSimple.LDF',
    SIZE = 10MB,
    FILEGROWTH=10%
);
GO

ALTER DATABASE ParitioningSimple ADD FILEGROUP SEGMENT_01;
ALTER DATABASE ParitioningSimple ADD FILEGROUP SEGMENT_02;
ALTER DATABASE ParitioningSimple ADD FILEGROUP SEGMENT_03;
ALTER DATABASE ParitioningSimple ADD FILEGROUP SEGMENT_04;
ALTER DATABASE ParitioningSimple ADD FILE (NAME='SEGMENT_01', FILENAME='E:\_DATA\ParitioningSimple_SEGMENT_01.ndf') TO FILEGROUP SEGMENT_01;
ALTER DATABASE ParitioningSimple ADD FILE (NAME='SEGMENT_02', FILENAME='E:\_DATA\ParitioningSimple_SEGMENT_02.ndf') TO FILEGROUP SEGMENT_02;
ALTER DATABASE ParitioningSimple ADD FILE (NAME='SEGMENT_03', FILENAME='E:\_DATA\ParitioningSimple_SEGMENT_03.ndf') TO FILEGROUP SEGMENT_03;
ALTER DATABASE ParitioningSimple ADD FILE (NAME='SEGMENT_04', FILENAME='H:\_DATA\ParitioningSimple_SEGMENT_04.ndf') TO FILEGROUP SEGMENT_04;
GO

USE ParitioningSimple;
GO

CREATE SCHEMA P;
GO

CREATE TABLE P.FactFinance (
ID int IDENTITY NOT NULL,
MemberID int NOT NULL,
Value int NOT NULL
);
GO

WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT P.FactFinance
SELECT ID % 7, ID % 715
FROM IDS
WHERE ID <= 40000;
GO

--CREATE PARTITION FUNCTION FactFinancePF (int) AS RANGE LEFT FOR VALUES (1, 10000, 20000);
CREATE PARTITION FUNCTION FactFinancePF (int) AS RANGE RIGHT FOR VALUES (1, 10001, 20001);
GO

CREATE PARTITION SCHEME FactFinancePS
AS PARTITION FactFinancePF
TO (SEGMENT_01, SEGMENT_02, SEGMENT_03, SEGMENT_04);
GO

CREATE UNIQUE CLUSTERED INDEX CI_FaceFinance_ID
ON P.FactFinance(ID)
WITH (
	DATA_COMPRESSION = ROW ON PARTITIONS(4),
	DATA_COMPRESSION = PAGE ON PARTITIONS(1,2,3)
)
ON FactFinancePS(ID);
GO

--LEFT		RIGHT
--1			0
--10000		10000
--10000		10000
--19999		20000
SELECT * FROM sys.partitions WHERE OBJECT_ID = OBJECT_ID('P.FactFinance') ORDER BY partition_number
GO

CREATE PROC CreateNewPartitionIfNeeded
	@Execute bit = 0
AS
	DECLARE @MaxPartitionNumber int;
	SELECT @MaxPartitionNumber = MAX(partition_number) FROM sys.partitions WHERE OBJECT_ID = OBJECT_ID('P.FactFinance')
	IF (	SELECT rows
			FROM sys.partitions
			WHERE 1=1
			AND OBJECT_ID = OBJECT_ID('P.FactFinance')
			AND partition_number = @MaxPartitionNumber
		) > 10000
	BEGIN
		PRINT 'REPARTITION REQUIRED'
		PRINT '--------------------'
		
		DECLARE @NewPartitionNumber int = @MaxPartitionNumber + 1;

		DECLARE @SegmentName char(10) = FORMAT(@NewPartitionNumber, 'SEGMENT_0#');
		DECLARE @SqlText nvarchar(3000);

		SELECT @SqlText = N'ALTER DATABASE ParitioningSimple ADD FILEGROUP ' + @SegmentName + ';';
		PRINT @SqlText;
		IF @Execute = 1 EXEC sp_executesql @SqlText;

		SELECT @SqlText = N'ALTER DATABASE ParitioningSimple ADD FILE (NAME=''' + @SegmentName + ''', FILENAME=''E:\_DATA\ParitioningSimple_' + @SegmentName + '.ndf'') TO FILEGROUP ' + @SegmentName + ';';
		PRINT @SqlText;
		IF @Execute = 1 EXEC sp_executesql @SqlText;

		SELECT @SqlText = N'ALTER PARTITION SCHEME FactFinancePS NEXT USED ' + @SegmentName + ';';
		PRINT @SqlText;
		IF @Execute = 1 EXEC sp_executesql @SqlText;

		DECLARE @PreviousPartitionRangeValue int;
		
		SELECT
		TOP 1
		@PreviousPartitionRangeValue = CAST(value AS int)
		FROM sys.partition_range_values prv
		INNER JOIN sys.partition_schemes ps on prv.function_id = ps.function_id
		WHERE ps.name = 'FactFinancePS'
		ORDER BY value desc
		
		DECLARE @NewPartitionRangeValue int = @PreviousPartitionRangeValue + 10000;
		
		SELECT @SqlText = N'ALTER PARTITION FUNCTION FactFinancePF () SPLIT RANGE (' + CONVERT(varchar, @NewPartitionRangeValue) + ');';
		PRINT @SqlText;
		IF @Execute = 1 EXEC sp_executesql @SqlText;

		SELECT @SqlText = N'ALTER INDEX CI_FaceFinance_ID ON P.FactFinance REBUILD PARTITION = ' + CONVERT(varchar, @MaxPartitionNumber) + ' WITH (DATA_COMPRESSION=PAGE);'
		PRINT @SqlText;
		IF @Execute = 1 EXEC sp_executesql @SqlText;
	END
	ELSE
	BEGIN
		PRINT 'REPARTITION NOT REQUIRED'
	END
GO

--+ add a few more and check rows per partition again
WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,N5(C) AS (SELECT 0 FROM N4 AS T1 CROSS JOIN N4 AS T2) -- 65,536 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N5)
INSERT P.FactFinance
SELECT ID % 7, ID % 715
FROM IDS
WHERE ID <= 15000;
GO

SELECT * FROM sys.partitions WHERE OBJECT_ID = OBJECT_ID('P.FactFinance') ORDER BY partition_number
GO

SELECT * FROM sys.partition_range_values;
GO

SELECT * FROM sys.partition_functions;
GO

SELECT * FROM sys.partition_schemes;
GO

SELECT * FROM sys.partition_parameters;
GO

select * from sys.database_files

/*

USE master;
GO

IF DATABASEPROPERTYEX('ParitioningSimple', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ParitioningSimple SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ParitioningSimple;
END
GO

*/