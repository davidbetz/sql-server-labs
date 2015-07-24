USE master;
GO

IF DATABASEPROPERTYEX('HintNOLOCK', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE HintNOLOCK SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HintNOLOCK;
END
GO

CREATE DATABASE HintNOLOCK;
GO

USE HintNOLOCK;
GO

CREATE TABLE Taco (ID INT IDENTITY PRIMARY KEY, Code CHAR(2));
GO

INSERT Taco VALUES ('A'), ('B'), ('C'), ('D') ;
GO

BEGIN TRAN;
INSERT Taco VALUES ('E');
GO

----> IN ANOTHER WINDOW

	USE HintNOLOCK;
	GO

	-- this sits there forever
	SELECT * FROM Taco;

	-- returns dirty data
	SELECT * FROM Taco WITH (NOLOCK);

	-- this ignores the locked record, returning everything else
	SELECT * FROM Taco WITH (READPAST);
	
	USE master;
	GO

ROLLBACK
GO

USE master;
GO

IF DATABASEPROPERTYEX('HintNOLOCK', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE HintNOLOCK SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HintNOLOCK;
END
GO
