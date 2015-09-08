USE master;
GO

IF DATABASEPROPERTYEX('AlwaysOn', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE AlwaysOn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AlwaysOn;
END
GO

CREATE DATABASE AlwaysOn
ON PRIMARY (
    NAME='AlwaysOn_Data',
    FILENAME='H:\_DATA\AlwaysOn.MDF',
    SIZE = 250MB
)
LOG ON (
    NAME = 'AlwaysOn_Log',
    FILENAME = 'C:\_LOG\AlwaysOn.LDF',
    SIZE = 10MB,
    FILEGROWTH=10%
);
GO

USE AlwaysOn;
GO

CREATE TABLE FactTable (
ID int IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Value int NOT NULL,
CONSTRAINT chk_Month CHECK ([Month] > 0 AND [Month] < 13),
CONSTRAINT chk_Year CHECK ([Year] > 2009 AND [Year] < 2016)
);
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
INSERT FactTable ([State], [Month], [Year], [Value])
SELECT
ABS(CHECKSUM(NewId())) % 51,
[Month],
[Year],
NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000);
GO

CREATE CLUSTERED INDEX CI_FactTable_ID
ON FactTable(ID)
WITH (
    DATA_COMPRESSION = ROW
)
GO

USE master;
GO

--BACKUP DATABASE AlwaysOn TO DISK='P:\AlwaysOn.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
--GO

--ALTER DATABASE AlwaysOn SET RECOVERY SIMPLE;
--GO

--RESTORE DATABASE AlwaysOn FROM DISK='P:\AlwaysOn.bak' WITH STATS = 10;
--GO

IF DATABASEPROPERTYEX('AlwaysOn', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE AlwaysOn SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AlwaysOn;
END
GO