USE master;
GO

IF DATABASEPROPERTYEX('FilteredStatisticsExample', 'Status') IS NOT NULL
BEGIN
    ALTER DATABASE FilteredStatisticsExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FilteredStatisticsExample;
END
GO

CREATE DATABASE FilteredStatisticsExample;
GO

USE FilteredStatisticsExample;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE dbo.Articles
(
        ArticleId INT NOT NULL,
        Name NVARCHAR(64) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        Color NVARCHAR(32) NULL,
        Size SMALLINT NULL
);
GO

SELECT ArticleId, Name
FROM dbo.Articles
WHERE Color = 'Red' AND Size = 3
GO

CREATE TABLE dbo.Cars
(
    ID INT NOT NULL IDENTITY(1,1),
    Make VARCHAR(32) NOT NULL,
    Model VARCHAR(32) NOT NULL
);
GO
 
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N4)
,Models(Model)
AS
(
        SELECT Models.Model
        FROM (
                VALUES('Yaris'),('Corolla'),('Matrix'),('Camry')
                        ,('Avalon'),('Sienna'),('Tacoma'),('Tundra')
                        ,('RAV4'),('Venza'),('Highlander'),('FJ Cruiser')
                        ,('4Runner'),('Sequoia'),('Land Cruiser'),('Prius')
        ) Models(Model)
)
INSERT INTO dbo.Cars(Make,Model)
        SELECT 'Toyota', Model
        FROM Models CROSS JOIN IDs;
GO
 
;WITH N1(C) AS (SELECT 0 UNION ALL SELECT 0) -- 2 ROWS
,N2(C) AS (SELECT 0 FROM N1 AS T1 CROSS JOIN N1 AS T2) -- 4 ROWS
,N3(C) AS (SELECT 0 FROM N2 AS T1 CROSS JOIN N2 AS T2) -- 16 ROWS
,N4(C) AS (SELECT 0 FROM N3 AS T1 CROSS JOIN N3 AS T2) -- 256 ROWS
,IDS(ID) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N4)
,Models(Model)
AS
(
        SELECT Models.Model
        FROM (
                VALUES('Accord'),('Civic'),('CR-V'),('Crosstour')
                        ,('CR-Z'),('FCX Clarity'),('Fit'),('Insight')
                        ,('Odyssey'),('Pilot'),('Ridgeline')
        ) Models(Model)
)
INSERT INTO dbo.Cars(Make,Model)
        SELECT 'Honda', Model
        FROM Models CROSS JOIN IDs;
GO

CREATE STATISTICS stat_Cars_Make ON dbo.Cars(Make);
CREATE STATISTICS stat_Cars_Model ON dbo.Cars(Model);
GO

--4096/4096
SELECT COUNT(*) FROM dbo.Cars WHERE Make = 'Toyota';

--256/256
SELECT COUNT(*) FROM dbo.Cars WHERE Model = 'Corolla';
GO

--256/151.704
--The Legacy cardinality estimator assumes the independence of predicates and uses the following formula:
--(Selectivity of first predicate * Selectivity of second predicate) * (Total number of rows in table) = (Estimated number of rows for first predicate * Estimated number of rows for second predicate) / (Total number of rows in the table) = (4096 * 256) / 6912 = 151.704
SELECT COUNT(*) FROM dbo.Cars WHERE Make = 'Toyota' AND Model='Corolla' OPTION (QUERYTRACEON 9481);

--256/197.096
--The new cardinality estimator, introduced in SQL Server 2014, takes a different approach and assumes some correlation between predicates. It uses the following formula:
--(Selectivity of most selective predicate) * SQRT(selectivity of next most selective predicate) = (256 / 6912) * SQRT(4096 / 6912) * 6912 = 256 * SQRT(4096 / 6912) = 197.069
SELECT COUNT(*) FROM dbo.Cars WHERE Make = 'Toyota' AND Model='Corolla'
GO

CREATE STATISTICS stat_Cars_Toyota_Models
ON dbo.Cars(Model)
WHERE Make = 'Toyota'
GO

--256/197.096
SELECT COUNT(*) FROM dbo.Cars WHERE Make = 'Toyota' and Model='Corolla';
GO

--256/256; was 256/151.704
SELECT COUNT(*) FROM dbo.Cars WHERE Make = 'Toyota' and Model='Corolla' OPTION (QUERYTRACEON 9481);
GO