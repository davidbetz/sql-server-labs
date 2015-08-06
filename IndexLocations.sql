USE master;
GO

IF DATABASEPROPERTYEX('IndexModification', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexModification SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexModification;
END
GO

CREATE DATABASE IndexModification
ON PRIMARY (
    NAME='IndexModificationData',
    FILENAME='H:\_DATA\IndexModification.MDF',
    SIZE = 250MB
),
FILEGROUP FG01
(
	NAME='FG01',
    FILENAME='H:\_DATA\FG01.MDF',
	SIZE=250MB
),
FILEGROUP FG02 (
	NAME='FG02',
    FILENAME='G:\_DATA\FG02.MDF',
	SIZE=250MB
),
FILEGROUP FG03 (
	NAME='FG03',
    FILENAME='G:\_DATA\FG03.MDF',
	SIZE=250MB
),
FILEGROUP FG04 (
	NAME='FG04',
    FILENAME='G:\_DATA\FG04.MDF',
	SIZE=250MB
),
FILEGROUP FG05 (
	NAME='FG05',
    FILENAME='G:\_DATA\FG05.MDF',
	SIZE=250MB
)
LOG ON (
    NAME = 'IndexModificationLog',
    FILENAME = 'C:\_LOG\IndexModification.LDF',
    SIZE = 200MB,
    FILEGROWTH=100MB
);
GO

USE IndexModification;
GO

DBCC TRACEON (3604);
GO

CREATE PROC ViewFactTableIndexes
AS
SELECT t.name AS [Table Name], i.name AS [Index Name], i.type_desc, i.data_space_id, f.name AS [Filegroup Name], fill_factor
FROM sys.indexes AS i
JOIN sys.filegroups AS f ON i.data_space_id = f.data_space_id
JOIN sys.tables as t ON i.object_id = t.object_id AND i.object_id = OBJECT_ID(N'FactTable','U');
GO

CREATE TABLE FactTable (
ID INT IDENTITY NOT NULL,
CaptureDate datetime2(0) NOT NULL,
EntityID INT NOT NULL,
StateID INT NOT NULL,
Value INT NOT NULL
)
ON FG01;
GO

;WITH NumericValue(Tracker)
AS
(
	SELECT 1
	UNION ALL
	SELECT Tracker + 1
	FROM NumericValue
	WHERE Tracker < 20000
)
INSERT FactTable
SELECT DATEADD(day, (ABS(CHECKSUM(NEWID())) % (60)) * -1, CURRENT_TIMESTAMP), RAND(CHECKSUM(NEWID())) * 100, RAND(CHECKSUM(NEWID())) * 20, ABS(CHECKSUM(NEWID()))
FROM NumericValue 
OPTION (MAXRECURSION 20000)
GO

-- on FG01 (same as heap)
CREATE NONCLUSTERED INDEX NCI_FactTable_CaptureDate_EntityID
ON FactTable(CaptureDate, EntityID);
GO

CREATE UNIQUE CLUSTERED INDEX CI_FactTable_ID
ON FactTable(ID)
ON FG02;
GO

-- on FG02 (same as clustered index)
CREATE NONCLUSTERED INDEX NCI_FactTable_EntityID_StateID_Value
ON FactTable(EntityID, StateID, Value);
GO

ViewFactTableIndexes
GO

ALTER INDEX CI_FactTable_ID ON FactTable
REBUILD WITH (
	FILLFACTOR = 80,
	SORT_IN_TEMPDB = ON,
	ONLINE = ON (
		WAIT_AT_LOW_PRIORITY (
			MAX_DURATION = 4 MINUTES,
			ABORT_AFTER_WAIT = BLOCKERS
		)
	),
	DATA_COMPRESSION = PAGE
)
GO

ViewFactTableIndexes
GO

CREATE UNIQUE CLUSTERED INDEX CI_FactTable_ID
ON FactTable(ID)
WITH (
	DROP_EXISTING=ON,
	FILLFACTOR = 70,
	SORT_IN_TEMPDB = ON,
	ONLINE = ON,
	DATA_COMPRESSION = PAGE
)
ON FG03;
GO

ViewFactTableIndexes
GO

DROP INDEX CI_FactTable_ID
ON FactTable
WITH (
	MOVE TO FG04
)
GO

ViewFactTableIndexes
GO

CREATE NONCLUSTERED INDEX NCI_FactTable_EntityID_StateID_Value
ON FactTable(ID)
WITH (
	DROP_EXISTING=ON,
	FILLFACTOR = 75,
	SORT_IN_TEMPDB = ON,
	ONLINE = ON,
	DATA_COMPRESSION = ROW
)
ON FG05;
GO

ViewFactTableIndexes
GO

--ALTER INDEX NCI_FactTable_EntityID_StateID_Value ON FactTable
--SET (
--	STATISTICS_NORECOMPUTE = ON,
--	IGNORE_DUP_KEY = ON,
--	ALLOW_PAGE_LOCKS = ON
--);
--GO

--DBCC SHOW_STATISTICS('FactTable', 'CI_FactTable_ID') WITH HISTOGRAM
DBCC SHOW_STATISTICS('FactTable', 'NCI_FactTable_CaptureDate_EntityID') WITH HISTOGRAM
DBCC SHOW_STATISTICS('FactTable', 'NCI_FactTable_EntityID_StateID_Value') WITH HISTOGRAM
GO

UPDATE STATISTICS FactTable CI_FactTable_ID WITH FULLSCAN
GO

UPDATE STATISTICS FactTable NCI_FactTable_CaptureDate_EntityID WITH FULLSCAN
GO

UPDATE STATISTICS FactTable NCI_FactTable_EntityID_StateID_Value WITH FULLSCAN
GO

USE master;
GO

IF DATABASEPROPERTYEX('IndexModification', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE IndexModification SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndexModification;
END
GO