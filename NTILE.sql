USE master;
GO

IF DATABASEPROPERTYEX('NTILE', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE NTILE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE NTILE;
END
GO

CREATE DATABASE NTILE;
GO

ALTER DATABASE NTILE SET RECOVERY SIMPLE;
GO

USE NTILE;
GO

SET NOCOUNT ON
GO

CREATE TABLE DataTable
(
	Duration int DEFAULT ABS(CHECKSUM(NEWID())) % 180,
	[Time] datetime2(0) DEFAULT DATEADD(minute, (ABS(CHECKSUM(NEWID())) % (180)), CURRENT_TIMESTAMP)
);
GO

INSERT INTO DataTable DEFAULT VALUES;
GO 5000

;WITH
TransformData(Duration, Minute)
AS
(
	SELECT Duration, LEFT(CONVERT(VARCHAR, [Time], 108), 5) FROM DataTable
),
AverageData(DurationAverage, Minute)
AS
(
	SELECT AVG(Duration) as DurationAverage, Minute
	FROM TransformData
	GROUP BY Minute
),
NTileData(NT, DurationAverage, Minute)
AS
(
	SELECT NTILE(20) OVER (ORDER BY DurationAverage), DurationAverage, Minute
	FROM AverageData
)
SELECT DurationAverage, Minute
FROM NTileData
WHERE NT = 20
ORDER BY NT DESC, DurationAverage DESC;
GO

USE master;
GO

--BACKUP DATABASE NTILE TO DISK='P:\NTILE.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
--GO

--ALTER DATABASE NTILE SET RECOVERY SIMPLE;
--GO

--RESTORE DATABASE NTILE FROM DISK='P:\NTILE.bak' WITH STATS = 10;
--GO

IF DATABASEPROPERTYEX('NTILE', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE NTILE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE NTILE;
END
GO