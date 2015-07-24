USE master;
GO

IF DATABASEPROPERTYEX('UpdateOutputExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE UpdateOutputExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE UpdateOutputExample;
END
GO

CREATE DATABASE UpdateOutputExample;
GO

USE UpdateOutputExample;
GO

CREATE TABLE Products (
ID INT PRIMARY KEY IDENTITY NOT NULL,
ProductCode CHAR(4),
Price NUMERIC (7,2) NOT NULL
);

CREATE NONCLUSTERED INDEX NCI_Products_ProductCode ON Products (ProductCode);

CREATE TABLE ProductsPriceLog (
ID INT PRIMARY KEY IDENTITY NOT NULL,
ProductCode CHAR(4),
OldPrice NUMERIC (7,2) NOT NULL,
NewPrice NUMERIC (7,2) NOT NULL
);

CREATE NONCLUSTERED INDEX NCI_ProductsPriceLog ON ProductsPriceLog (ProductCode)
INCLUDE (OldPrice,NewPrice);

INSERT Products VALUES ('A', 1), ('B', 2), ('C', 10), ('D', 20);

SELECT * FROM Products;

UPDATE Products SET Price = Price * 1.05
OUTPUT INSERTED.ProductCode, DELETED.Price, INSERTED.Price
INTO ProductsPriceLog(ProductCode, OldPrice, NewPrice)

SELECT * FROM Products
SELECT * FROM ProductsPriceLog

USE master;
GO

--BACKUP DATABASE UpdateOutputExample TO DISK='P:\UpdateOutputExample.bak' WITH FORMAT, STATS = 10, DESCRIPTION = 'FULL';
--GO

--ALTER DATABASE UpdateOutputExample SET RECOVERY SIMPLE;
--GO

--RESTORE DATABASE UpdateOutputExample FROM DISK='P:\UpdateOutputExample.bak' WITH STATS = 10;
--GO

IF DATABASEPROPERTYEX('UpdateOutputExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE UpdateOutputExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE UpdateOutputExample;
END
GO

