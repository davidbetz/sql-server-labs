# SQL Server 2012 / 2014+ Lab Files

Here are are files I created over years of polishing my SQL Server skills for certification exams (MCSE at the time; though most content goes deep into the now-cancelled MCSM program as well).

For the most part, each file is a different topic. Some are tiny and simple, some are huge and elaborate.

I'll add more labs as I continue to use SQL Server (and polish files I find randomly laying around my hard drives).

Most files are based on the following template:	
	
	USE master;
	GO
	
	IF DATABASEPROPERTYEX('XXXXX', 'Status') IS NOT NULL
	BEGIN
		ALTER DATABASE XXXXX SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE XXXXX;
	END
	GO
	
	CREATE DATABASE XXXXX
	--ON PRIMARY (
	--    NAME='XXXXX_Data',
	--    FILENAME='H:\_DATA\XXXXX.MDF',
	--    SIZE = 250MB
	--)
	--LOG ON (
	--    NAME = 'XXXXX_Log',
	--    FILENAME = 'C:\_LOG\XXXXX.LDF',
	--    SIZE = 10MB,
	--    FILEGROWTH=10%
	--)
	GO
	
	--ALTER DATABASE XXXXX SET RECOVERY SIMPLE;
	--GO
	
	USE XXXXX;
	GO
	
	CREATE TABLE FactTable (
	ID INT IDENTITY NOT NULL,
	CaptureDate datetime2(0) NOT NULL,
	EntityID INT NOT NULL,
	StateID INT NOT NULL,
	Value INT NOT NULL
	);
	GO
	
	;WITH NumericValue(Tracker)
	AS
	(
		SELECT 1
		UNION ALL
		SELECT Tracker + 1
		FROM NumericValue
		WHERE Tracker < 20000
	)
	INSERT FactTable
	SELECT DATEADD(day, (ABS(CHECKSUM(NEWID())) % (60)) * -1, CURRENT_TIMESTAMP), RAND(CHECKSUM(NEWID())) * 100, RAND(CHECKSUM(NEWID())) * 20, ABS(CHECKSUM(NEWID()))
	FROM NumericValue 
	OPTION (MAXRECURSION 20000)
	GO
	
	--CREATE CLUSTERED INDEX CI_FactTable_ID ON FactTable(ID)
	--GO
	
	--ALTER TABLE FactTable REBUILD WITH (DATA_COMPRESSION=ROW);
	--GO
	
	WITH
	A([Year])
	AS (
		SELECT DATEPART(year, CaptureDate) FROM FactTable
	)
	SELECT [Year]
	FROM A
	GROUP BY [Year]
	ORDER BY [Year] DESC
	GO
	
	USE master;
	GO
	
	--BACKUP DATABASE XXXXX TO DISK='P:\XXXXX.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
	--GO
	
	--ALTER DATABASE XXXXX SET RECOVERY SIMPLE;
	--GO
	
	--RESTORE DATABASE XXXXX FROM DISK='P:\XXXXX.bak' WITH STATS = 10;
	--GO
	
	IF DATABASEPROPERTYEX('XXXXX', 'Status') IS NOT NULL
	BEGIN
		ALTER DATABASE XXXXX SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE XXXXX;
	END
	GO