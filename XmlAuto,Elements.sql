SET NOCOUNT ON
USE master;
GO

IF DATABASEPROPERTYEX('XmlAutoElements', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE XmlAutoElements SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE XmlAutoElements;
END
GO

CREATE DATABASE XmlAutoElements;
GO

USE XmlAutoElements;
GO

CREATE TABLE Customers (
CustomerId int PRIMARY KEY NOT NULL IDENTITY,
Name varchar(100),
Country varchar(200)
);

CREATE TABLE Orders (
OrderId int,
CustomerId int FOREIGN KEY REFERENCES Customers(CustomerId),
OrderDate datetime,
Amount decimal(7,2)
);
GO

CREATE NONCLUSTERED INDEX NCI_Orders_CustomerId ON Orders (CustomerId);
GO

INSERT INTO Customers SELECT 'Customer A', 'Austrailia';
GO

INSERT INTO Orders (OrderId,CustomerId,OrderDate,Amount)
VALUES  (1, 1, '01-01-2000', 3400.00), (2, 1, '01-01-2001', 4300.00);
GO

SELECT Name, Country, OrderId, OrderDate, Amount
FROM Orders
INNER JOIN Customers ON Orders.CustomerId = Customers.CustomerId
WHERE Customers.CustomerId= 1
FOR XML PATH ('Customers');
GO

SELECT OrderId, OrderDate, Amount, Name, Country
FROM Orders INNER JOIN Customers ON Orders.CustomerId = Customers.CustomerId
WHERE Customers.CustomerId= 1
FOR XML AUTO, ELEMENTS;
GO

SELECT OrderId, OrderDate, Amount, Name, Country
FROM Orders INNER JOIN Customers ON Orders.CustomerId = Customers.CustomerId
WHERE Customers.CustomerId= 1
FOR XML AUTO;
GO

SELECT OrderId, OrderDate, Amount, Name, Country
FROM Orders INNER JOIN Customers ON Orders.CustomerId = Customers.CustomerId
WHERE Customers.CustomerId= 1
FOR XML RAW;
GO

SELECT OrderId, OrderDate, Amount, Name, Country
FROM Orders INNER JOIN Customers ON Orders.CustomerId = Customers.CustomerId
WHERE Customers.CustomerId= 1
FOR XML RAW, ELEMENTS;
GO

USE master;
GO

IF DATABASEPROPERTYEX('XmlAutoElements', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE XmlAutoElements SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE XmlAutoElements;
END
GO
