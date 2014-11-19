USE master;
GO

IF DATABASEPROPERTYEX('LobStructure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE LobStructure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE LobStructure;
END
GO

CREATE DATABASE LobStructure;
GO

USE LobStructure;
GO

DBCC TRACEON (3604);
GO

CREATE FUNCTION dbo.GetLatestInRowPageID(@name varchar(20))
RETURNS INT
AS
BEGIN
	DECLARE @page_id INT;
	SELECT TOP 1 @page_id = allocated_page_page_id FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID(@name), null, null, 'DETAILED') WHERE page_type = 1 ORDER BY allocated_page_page_id DESC;
	RETURN @page_id;
END
GO

CREATE TABLE DataTable (
	ID INT NOT NULL,
	Column1 CHAR(7000) NOT NULL DEFAULT('Z'),
	Column2 VARCHAR(max) NULL,
	Column3 VARCHAR(max) NULL,
	Column4 VARCHAR(max) NULL
) ON [Primary];
GO

/* IN-ROW */
INSERT INTO DataTable (ID, Column2, Column3, Column4) VALUES (1, REPLICATE('A', 1), REPLICATE('A', 1), REPLICATE('A', 1));
GO

DBCC IND ('LobStructure', 'DataTable', -1)
GO

/* Column2 stayed [BLOB Inline Data]; Column2 stayed [BLOB Inline Data]; Column3 went [BLOB Inline Root], LOB data */
INSERT INTO DataTable (ID, Column2, Column3, Column4) VALUES (1, REPLICATE('A', 1), REPLICATE('A', 1), REPLICATE('A', 5000));
GO

DBCC IND ('LobStructure', 'DataTable', -1)
GO

DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID('DataTable')
DBCC PAGE ('LobStructure', 1, @page_id, 3);
GO

--Column2 = [BLOB Inline Data] Slot 0 Column 3 Offset 0x1b6b Length 1 Length (physical) 1

--Column2 = 0x41                      

--Column3 = [BLOB Inline Data] Slot 0 Column 4 Offset 0x1b6c Length 1 Length (physical) 1

--Column3 = 0x41                      

--Column4 = [BLOB Inline Root] Slot 0 Column 5 Offset 0x1b6d Length 24 Length (physical) 24

--Level = 0                           Unused = 0                          UpdateSeq = 1
--TimeStamp = 1024786432              Type = 4                            
--Link 0

--Size = 5000                         RowId = (1:283:0)                   

/* [BLOB Inline Root] */
INSERT INTO DataTable (ID, Column2, Column3) VALUES (1, REPLICATE('A', 50000000), REPLICATE('A', 50000000));
GO

DBCC IND ('LobStructure', 'DataTable', -1)
GO

DECLARE @page_id INT;
select @page_id = dbo.GetLatestInRowPageID('DataTable')
DBCC PAGE ('LobStructure', 1, @page_id, 3);
GO