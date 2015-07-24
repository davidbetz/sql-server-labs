USE master;
GO

IF DATABASEPROPERTYEX('OutputProcedure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE OutputProcedure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE OutputProcedure;
END
GO

CREATE DATABASE OutputProcedure;
GO

USE OutputProcedure;
GO

CREATE PROC SampleProc
@param1 int, @param2 int OUTPUT
AS
SELECT @param2 = @param1 + 10
RETURN
GO

DECLARE @result INT
EXEC SampleProc 1, @result OUTPUT
SELECT @result
GO

USE master;
GO

IF DATABASEPROPERTYEX('OutputProcedure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE OutputProcedure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE OutputProcedure;
END
GO