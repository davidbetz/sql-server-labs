USE master;
GO

IF DATABASEPROPERTYEX('MissingIndexExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE MissingIndexExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE MissingIndexExample;
END
GO

CREATE DATABASE MissingIndexExample;
GO

USE MissingIndexExample;
GO

CREATE PROC dbo.GenerateData(@count int)
AS
WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < @count
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
INSERT FactFinance
SELECT ABS(CHECKSUM(NEWID())) % 51, [Month], [Year], CONVERT(date, CONVERT(VARCHAR(4), [Year]) + RIGHT('0' + CONVERT(VARCHAR(2), [Month]), 2) + '01', 112), NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000)
GO

--++ heap rowstore
CREATE TABLE FactFinance (
ID int PRIMARY KEY IDENTITY NOT NULL,
[State] tinyint NOT NULL,
[Month] tinyint NOT NULL,
[Year] int NOT NULL,
Segment date NOT NULL,
Value int NOT NULL
);
GO

GenerateData 300
GO

SELECT [Year], [Month], SUM(CAST(Value AS bigint))
FROM FactFinance
WHERE [Year] = 2010
GROUP BY YEAR, MONTH
GO

SELECT [Year], [Month], SUM(CAST(Value AS bigint))
FROM FactFinance
WHERE [Year] = 2010 AND [Month] = 8
GROUP BY YEAR, MONTH
GO

SELECT * FROM sys.dm_db_missing_index_details
GO

SELECT * FROM sys.dm_db_missing_index_group_stats
GO