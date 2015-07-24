USE master;
GO

IF DATABASEPROPERTYEX('TableVariableRowEstimates', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TableVariableRowEstimates SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TableVariableRowEstimates;
END
GO

CREATE DATABASE TableVariableRowEstimates;
GO

USE TableVariableRowEstimates;
GO

CREATE TABLE DataTable(ID int IDENTITY, Value tinyint);
GO

WITH NumericValue(Tracker, NumericValue)
AS
(
	SELECT 1, ABS(CHECKSUM(NEWID()))
	UNION ALL
	SELECT Tracker + 1, ABS(CHECKSUM(NEWID()))
	FROM NumericValue
	WHERE Tracker < 200
)
INSERT DATATABLE
SELECT ABS(CHECKSUM(NEWID())) % 51
FROM NumericValue
OPTION (MAXRECURSION 3000)

DECLARE @DataTable table(ID int IDENTITY, Value tinyint);

INSERT @DataTable
SELECT Value
FROM DataTable

DBCC FREEPROCCACHE
SELECT COUNT(*) FROM DataTable
SELECT COUNT(*) FROM @DataTable
SELECT COUNT(*) FROM @DataTable WHERE ID > 20
SELECT COUNT(*) FROM DataTable OPTION (RECOMPILE)

USE master;
GO

IF DATABASEPROPERTYEX('TableVariableRowEstimates', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TableVariableRowEstimates SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TableVariableRowEstimates;
END
GO