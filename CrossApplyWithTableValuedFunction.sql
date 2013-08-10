USE master;
GO

IF DATABASEPROPERTYEX('CrossApplyWithTableValuedFunction', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE CrossApplyWithTableValuedFunction SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CrossApplyWithTableValuedFunction;
END
GO

CREATE DATABASE CrossApplyWithTableValuedFunction;
GO

ALTER DATABASE CrossApplyWithTableValuedFunction SET RECOVERY SIMPLE;
GO

USE CrossApplyWithTableValuedFunction;
GO

CREATE TABLE A (Id int identity, C1 char(1));
GO

INSERT INTO A VALUES ('A'), ('B'), ('C'), ('D');
GO

CREATE FUNCTION dbo.udf1(@id int)
RETURNS TABLE
AS
RETURN
	WITH X (C2)
	AS (
		SELECT 10 as C2
		UNION ALL
		SELECT 20 as C2
		UNION ALL
		SELECT 30 as C2
		UNION ALL
		SELECT 40 as C2
	)
	SELECT C2 FROM X WHERE C2 != @id * 10;
GO

SELECT A.C1, U.C2
FROM A CROSS APPLY dbo.udf1(A.Id) as U;
GO

USE master;
GO

IF DATABASEPROPERTYEX('CrossApplyWithTableValuedFunction', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE CrossApplyWithTableValuedFunction SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CrossApplyWithTableValuedFunction;
END
GO