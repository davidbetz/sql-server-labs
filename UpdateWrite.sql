USE master;
GO

IF DATABASEPROPERTYEX('UpdateWrite', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE UpdateWrite SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE UpdateWrite;
END
GO

CREATE DATABASE UpdateWrite;
GO

USE UpdateWrite;
GO

CREATE TABLE BlogEntry (
ID bigint PRIMARY KEY IDENTITY,
EntryDateTime datetime,
Summary nvarchar(max)
);
GO

INSERT BlogEntry SELECT CURRENT_TIMESTAMP, REPLICATE('A', 10)
INSERT BlogEntry SELECT CURRENT_TIMESTAMP, REPLICATE('B', 10)
INSERT BlogEntry SELECT CURRENT_TIMESTAMP, REPLICATE('C', 10)
INSERT BlogEntry SELECT CURRENT_TIMESTAMP, REPLICATE('D', 10)
GO

-- RUN
SELECT * FROM BlogEntry;
GO

BEGIN TRAN

--+ append to last 3
UPDATE BlogEntry 
SET Summary.WRITE(N' This is in a draft stage', NULL, 0) FROM ( 
		SELECT TOP(3) Id FROM BlogEntry ORDER BY EntryDateTime DESC
	) AS s 
WHERE BlogEntry.Id = s.ID
GO

SELECT * FROM BlogEntry;
GO

ROLLBACK
GO
-- /RUN

-- RUN
SELECT * FROM BlogEntry;
GO

BEGIN TRAN
--+ add a + to rows 2 and 4
UPDATE BlogEntry 
SET Summary.WRITE(N'+', 2, 0)
WHERE BlogEntry.Id % 2 = 0
GO

SELECT * FROM BlogEntry;
GO

ROLLBACK
GO
-- /RUN

USE master;
GO

IF DATABASEPROPERTYEX('UpdateWrite', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE UpdateWrite SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE UpdateWrite;
END
GO