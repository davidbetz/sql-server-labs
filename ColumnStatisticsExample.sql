USE master;
GO

IF DATABASEPROPERTYEX('ColumnStatisticsExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ColumnStatisticsExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ColumnStatisticsExample;
END
GO

CREATE DATABASE ColumnStatisticsExample;
GO

USE ColumnStatisticsExample;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE dbo.Customer
(
CustomerId INT nOT NULL IDENTITY(1,1),
FirstName NVARCHAR(64) NOT NULL,
LastName NVARCHAR(128) NOT NULL,
Phone VARCHAR(32) NULL,
Placeholder CHAR(200) NULL
);
GO

CREATE UNIQUE CLUSTERED INDEX IDX_Customer_CustomerId
ON dbo.Customer(CustomerId)
GO

-- Inserting cross-joined data for all first and last names 50 times
-- using GO 50 command in Management Studio

WITH FirstNames(FirstName)
AS
(
	SELECT Names.Name
	FROM
	(
		VALUES ('Andrew'),('Andy'),('Anton'),('Ashley'),('Boris'),
		('Brian'),('Cristopher'),('Cathy'),('Daniel'),('Donny'),
		('Edward'),('Eddy'),('Emy'),('Frank'),('George'),('Harry'),
		('Henry'),('Ida'),('John'),('Jimmy'),('Jenny'),('Jack'),
		('Kathy'),('Kim'),('Larry'),('Mary'),('Max'),('Nancy'),
		('Olivia'),('Olga'),('Peter'),('Patrick'),('Robert'),
		('Ron'),('Steve'),('Shawn'),('Tom'),('Timothy'),
		('Uri'),('Vincent')
	) Names (Name)
)
,LastNames(LastName)
AS
(
	SELECT Names.Name
	FROM
	(
		VALUES ('Smith'),('Johnson'),('Williams'),('Jones'),('Brown'),
		('Davis'),('Miller'),('Wilson'),('Moore'),('Taylor'),
		('Anderson'),('Jackson'),('White'),('Harris')
	) Names(Name)
)
INSERT INTO dbo.Customer(LastName, FirstName)
SELECT LastName, FirstName
FROM FirstNames CROSS JOIN LastNames
GO 50

INSERT INTO dbo.Customer(LastName, FirstName) values('Isakov','Victor')
GO

CREATE NONCLUSTERED INDEX IDX_Customer_LastName_FirstName
ON dbo.Customer(LastName, FirstName);
GO

SELECT CustomerId, FirstName, LastName, Phone
FROM dbo.Customer
WHERE FirstName = 'Brian';
GO

SELECT CustomerId, FirstName, LastName, Phone
FROM dbo.Customer
WHERE FirstName = 'Victor';
GO

DECLARE @name VARCHAR(50)
SELECT @name = name
FROM sys.stats
WHERE object_id = OBJECT_ID(N'dbo.Customer')

DBCC SHOW_STATISTICS ('dbo.Customer', @name)
GO

--Name                                                                                                                             Updated              Rows                 Rows Sampled         Steps  Density       Average key length String Index Filter Expression                                                                                                                                                                                                                                                Unfiltered Rows
---------------------------------------------------------------------------------------------------------------------------------- -------------------- -------------------- -------------------- ------ ------------- ------------------ ------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------
--_WA_Sys_00000002_0EA330E9                                                                                                        Nov 15 2014 10:33PM  28001                28001                41     0             9.900075           YES          NULL                                                                                                                                                                                                                                                             28001

--All density   Average Length Columns
--------------- -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--0.02439024    9.900075       FirstName

--RANGE_HI_KEY                                                     RANGE_ROWS    EQ_ROWS       DISTINCT_RANGE_ROWS  AVG_RANGE_ROWS
------------------------------------------------------------------ ------------- ------------- -------------------- --------------
--Andrew                                                           0             700           0                    1
--Andy                                                             0             700           0                    1
--Anton                                                            0             700           0                    1
--Ashley                                                           0             700           0                    1
--Boris                                                            0             700           0                    1
--Brian                                                            0             700           0                    1
--Victor                                                           0             1             0                    1
--Vincent                                                          0             700           0                    1

