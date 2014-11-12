USE master;
GO

IF DATABASEPROPERTYEX('SalesDB', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE SalesDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE SalesDB;
END
GO

RESTORE DATABASE SalesDB
FROM DISK = 'E:\Drive\Code\SQL Server\Topics\SampleBackup\SalesDBOriginal.bak'
WITH
MOVE 'SalesDBData' TO 'C:\_DATA\SalesDB.mdf',
MOVE 'SalesDBLog' TO 'C:\_LOG\SalesDB.ldf';
GO

USE SalesDB;
GO

SELECT S.*, P.*
FROM Sales S
JOIN Products P ON P.ProductID = S.ProductID
ORDER BY P.Name;
GO

ALTER DATABASE SalesDB SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

UPDATE Sales Set Quantity = 4;
GO
