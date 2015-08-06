USE master;
GO

IF DATABASEPROPERTYEX('AzureLab', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE AzureLab SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AzureLab;
END
GO

CREATE DATABASE AzureLab;
GO

USE AzureLab;
GO

CREATE SCHEMA Lab;
GO

CREATE TABLE Lab.DimState (
ID tinyint PRIMARY KEY NOT NULL,
Name char(20) NOT NULL
)
GO

INSERT Lab.DimState
VALUES (1, 'Alabama'), (2, 'Alaska'), (3, 'Arizona'), (4, 'Arkansas'), (5, 'California'), (6, 'Colorado'), (7, 'Connecticut'), (8, 'Delaware'), (9, 'Florida'), (10, 'Georgia'), (11, 'Hawaii'), (12, 'Idaho'), (13, 'Illinois'), (14, 'Indiana'), (15, 'Iowa'), (16, 'Kansas'), (17, 'Kentucky'), (18, 'Louisiana'), (19, 'Maine'), (20, 'Maryland'), (21, 'Massachusetts'), (22, 'Michigan'), (23, 'Minnesota'), (24, 'Mississippi'), (25, 'Missouri'), (26, 'Montana'), (27, 'Nebraska'), (28, 'Nevada'), (29, 'NewHampshire'), (30, 'NewJersey'), (31, 'NewMexico'), (32, 'NewYork'), (33, 'NorthCarolina'), (34, 'NorthDakota'), (35, 'Ohio'), (36, 'Oklahoma'), (37, 'Oregon'), (38, 'Pennsylvania'), (39, 'RhodeIsland'), (40, 'SouthCarolina'), (41, 'SouthDakota'), (42, 'Tennessee'), (43, 'Texas'), (44, 'Utah'), (45, 'Vermont'), (46, 'Virginia'), (47, 'Washington'), (48, 'WestVirginia'), (49, 'Wisconsin'), (50, 'Wyoming'), (51, 'District of Columbia')
GO

CREATE TABLE Lab.FactLineItem (
ID int IDENTITY NOT NULL,
StateID tinyint,
EntityID int NOT NULL,
FacilityID int NOT NULL,
CaptureDate datetime2(0) NOT NULL,
Value int NOT NULL
);
GO

WITH NumericValue(Tracker)
AS
(
	SELECT 1
	UNION ALL
	SELECT Tracker + 1
	FROM NumericValue
	WHERE Tracker < 20000
)
INSERT Lab.FactLineItem
SELECT
ABS(CHECKSUM(NEWID())) % 51,
CAST(RAND(CHECKSUM(NEWID())) * 100 AS int),
CAST(RAND(CHECKSUM(NEWID())) * 20 AS int),
DATEADD(day, (ABS(CHECKSUM(NEWID())) % (365*4)) * -1, CURRENT_TIMESTAMP),
ABS(CHECKSUM(NEWID()))
FROM NumericValue 
OPTION (MAXRECURSION 30000)
GO

SELECT TOP 10 * FROM Lab.FactLineItem
GO

SELECT COUNT(*) FROM Lab.FactLineItem
GO

ALTER TABLE Lab.FactLineItem REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

DBCC FREEPROCCACHE
SET STATISTICS IO ON

CREATE CLUSTERED INDEX CI_FactLineItem ON Lab.FactLineItem(ID)
GO

CREATE NONCLUSTERED INDEX NCI_FactLineItem_Segment ON Lab.FactLineItem(CaptureDate) INCLUDE (StateID, EntityID, FacilityID)
GO

select * from Lab.FactLineItem
go

SELECT CaptureDate, StateID
FROM Lab.FactLineItem
WHERE CaptureDate = '2009-11-01'
GO

SELECT CaptureDate
FROM Lab.FactLineItem
WHERE CaptureDate > '2009-11-01'
GO

--CREATE NONCLUSTERED INDEX CI_FactLineItem_Segment ON Lab.FactLineItem(Segment)

SELECT *
FROM sys.stats
WHERE object_id = OBJECT_ID('Lab.FactLineItem')
GO

UPDATE STATISTICS Lab.FactLineItem
GO

CREATE CREDENTIAL AzureStore
WITH IDENTITY = 'mystore',
SECRET = ''
GO

USE master;
GO

BACKUP DATABASE AzureLab
TO URL = 'http://mystore.blob.core.windows.net/backups/AzureLab.bak'
WITH CREDENTIAL = 'AzureStore';
GO

DROP DATABASE AzureLab;
GO

RESTORE FILELISTONLY
FROM URL = 'http://mystore.blob.core.windows.net/backups/AzureLab.bak'
WITH CREDENTIAL = 'AzureStore';
GO

RESTORE DATABASE AzureLab
FROM URL = 'http://mystore.blob.core.windows.net/backups/AzureLab.bak'
WITH CREDENTIAL = 'AzureStore';
GO

CREATE CREDENTIAL [https://mystore.blob.core.windows.net/datafiles]
WITH IDENTITY='SHARED ACCESS SIGNATURE',
SECRET = 'sv=2014-02-14&sr=c&sig=qr9gjBq1cOVYVjmGxWhWz8vPjeKpHdK95wmQqCvdff8%3D&se=2015-08-04T02%3A12%3A30Z&sp=rw'
GO

CREATE DATABASE FancySQLDatabase
ON
(
	Name=FancySQLDatabaseData,
	FILENAME='https://mystore.blob.core.windows.net/datafiles/FancySQLDatabaseData.mdf'
)
LOG ON
(
	Name=FancySQLDatabaseLog,
	FILENAME='https://mystore.blob.core.windows.net/datafiles/FancySQLDatabaseLog.ldf'
)
GO
