USE master;
GO

IF DATABASEPROPERTYEX('IndexKeySize', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexKeySize SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexKeySize;
END
GO

CREATE DATABASE IndexKeySize;
GO

USE IndexKeySize;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE DataTable (
	Column1 VARCHAR(500) NULL,
	Column2 VARCHAR(1000) NULL
) ON [Primary];
GO

CREATE NONCLUSTERED INDEX DataTable_Column1_Column2_NCI ON DataTable(Column1, Column2);
--Warning! The maximum key length is 900 bytes. The index 'DataTable_Column1_Column2_NCI' has maximum length of 1500 bytes. For some combination of large values, the insert/update operation will fail.
GO

/* Not a problem */
INSERT INTO DataTable (Column1, Column2) VALUES ('a', 'b');
GO

/* Too big */
INSERT INTO DataTable (Column1, Column2) VALUES (REPLICATE('A', 500), REPLICATE('A', 500));
--Operation failed. The index entry of length 1000 bytes for the index 'DataTable_Column1_Column2_NCI' exceeds the maximum length of 900 bytes.
GO