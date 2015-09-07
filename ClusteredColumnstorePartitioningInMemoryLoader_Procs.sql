

--------------------------------------------------------------------------------------

CREATE PROC Partitioning.GenerateDataByDirectIteration
@IterationCount bigint,
@TimeElapsed int OUTPUT
AS
DECLARE @Then datetime2 = CURRENT_TIMESTAMP;
DECLARE @i int = 1;
SET @i = @i + 1;

BEGIN TRANSACTION;

WHILE @i < @IterationCount
BEGIN
	INSERT Partitioning.FactFinance ([State], [Month], [Year], [Value])
    VALUES (
			CAST(1 + RAND() * 50 AS int),
			CAST(1 + RAND() * 12 AS int),
			CAST(2015 - (RAND() * 5) AS int),
			CAST(1 + RAND() * 1000000 AS int)
	);
	SET @i = @i + 1;
END;

COMMIT;

DECLARE @Now datetime2 = CURRENT_TIMESTAMP;

SELECT @TimeElapsed = DATEDIFF(millisecond, @Then, @Now);
RETURN
GO

--------------------------------------------------------------------------------------

CREATE PROC Partitioning.GenerateDataByInMemoryIteration
@IterationCount bigint,
@TimeElapsed int OUTPUT
AS
DECLARE @Model AS Partitioning.FinanceModel;
DECLARE @Then datetime2 = CURRENT_TIMESTAMP;
DECLARE @i int = 1;
SET @i = @i + 1;


WHILE @i < @IterationCount
BEGIN
	INSERT @Model ([ID], [State], [Month], [Year], [Value])
    VALUES (
            @i,
			CAST(1 + RAND() * 50 AS int),
			CAST(1 + RAND() * 12 AS int),
			CAST(2015 - (RAND() * 5) AS int),
			CAST(1 + RAND() * 1000000 AS int)
	);
	SET @i = @i + 1
END

INSERT Partitioning.FactFinance ([State], [Month], [Year], [Value])
SELECT [State], [Month], [Year], Value
FROM @Model;

DECLARE @Now datetime2 = CURRENT_TIMESTAMP;

SELECT @TimeElapsed = DATEDIFF(millisecond, @Then, @Now);
RETURN
GO

--------------------------------------------------------------------------------------

CREATE PROC Partitioning.GenerateDataByDirectCTE
@TimeElapsed int OUTPUT,
@RowCount bigint OUTPUT
AS
DECLARE @Then datetime2 = CURRENT_TIMESTAMP;
DECLARE @i int = 1;
SET @i = @i + 1;

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
[Year],
NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000);
SELECT @RowCount = @@ROWCOUNT;

DECLARE @Now datetime2 = CURRENT_TIMESTAMP;

SELECT @TimeElapsed = DATEDIFF(millisecond, @Then, @Now);
RETURN
GO

--------------------------------------------------------------------------------------

CREATE PROC Partitioning.GenerateDataByInMemoryCTE
@TimeElapsed int OUTPUT,
@RowCount bigint OUTPUT
AS
DECLARE @Model AS Partitioning.FinanceModel;
DECLARE @Then datetime2 = CURRENT_TIMESTAMP;
DECLARE @i int = 1;
SET @i = @i + 1;

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
INSERT @Model ([ID], [State], [Month], [Year], [Value])
SELECT
@i,
ABS(CHECKSUM(NewId())) % 51,
[Month],
[Year],
NumericValue
FROM Years CROSS JOIN Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000);

INSERT Partitioning.FactFinance ([State], [Month], [Year], [Value])
SELECT [State], [Month], [Year], Value
FROM @Model;

SELECT @RowCount = @@ROWCOUNT;

DECLARE @Now datetime2 = CURRENT_TIMESTAMP;

SELECT @TimeElapsed = DATEDIFF(millisecond, @Then, @Now);
RETURN
GO

--------------------------------------------------------------------------------------

CREATE PROC RunBenchmarks
AS
DECLARE @IterationCount bigint;

DECLARE @TimeElapsed1 int;
DECLARE @TimeElapsed2 int;
DECLARE @TimeElapsed3 int;
DECLARE @TimeElapsed4 int;

EXEC Partitioning.GenerateDataByDirectCTE @TimeElapsed1 OUTPUT, @IterationCount OUTPUT
EXEC Partitioning.GenerateDataByInMemoryCTE @TimeElapsed2 OUTPUT, @IterationCount OUTPUT
EXEC Partitioning.GenerateDataByDirectIteration @IterationCount, @TimeElapsed3 OUTPUT
EXEC Partitioning.GenerateDataByInMemoryIteration @IterationCount, @TimeElapsed4 OUTPUT

SELECT @TimeElapsed1 AS 'Times'
UNION ALL
SELECT @TimeElapsed2
UNION ALL
SELECT @TimeElapsed3
UNION ALL
SELECT @TimeElapsed4
GO

--------------------------------------------------------------------------------------

CREATE PROC Partitioning.GenerateDataByInMemoryCTEByYear
@Year int,
@TimeElapsed int OUTPUT,
@RowCount bigint OUTPUT
AS
DECLARE @Model AS Partitioning.FinanceModel;
DECLARE @Then datetime2 = CURRENT_TIMESTAMP;
DECLARE @i int = 1;
SET @i = @i + 1;

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 30000
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
INSERT @Model ([ID], [State], [Month], [Year], [Value])
SELECT
@i,
ABS(CHECKSUM(NewId())) % 51,
[Month],
@Year,
NumericValue
FROM Months CROSS JOIN NumericValue
OPTION (MAXRECURSION 30000);

INSERT Partitioning.FactFinance ([State], [Month], [Year], [Value])
SELECT [State], [Month], [Year], Value
FROM @Model;

SELECT @RowCount = @@ROWCOUNT;

DECLARE @Now datetime2 = CURRENT_TIMESTAMP;

SELECT @TimeElapsed = DATEDIFF(millisecond, @Then, @Now);

SELECT @TimeElapsed as '@TimeElapsed', @RowCount as '@RowCount';
GO

--------------------------------------------------------------------------------------

CREATE PROC Partitioning.GenerateDataByDirectCTEByYear
@Year int,
@TimeElapsed int OUTPUT,
@RowCount bigint OUTPUT
AS
DECLARE @Then datetime2 = CURRENT_TIMESTAMP;
DECLARE @i int = 1;
SET @i = @i + 1;

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
SELECT @RowCount = @@ROWCOUNT;

DECLARE @Now datetime2 = CURRENT_TIMESTAMP;

SELECT @TimeElapsed = DATEDIFF(millisecond, @Then, @Now);
RETURN
GO