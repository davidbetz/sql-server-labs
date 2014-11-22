USE master;
GO

SET NOCOUNT ON
SET STATISTICS TIME OFF

IF DATABASEPROPERTYEX('MCM2008', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE MCM2008 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE MCM2008;
END
GO

CREATE DATABASE MCM2008;
GO

USE MCM2008;
GO

DBCC TRACEON (3604);
GO

/*
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'fill factor', 100;
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO
*/

SET NOCOUNT ON;
GO

-- 1000 row c2

CREATE TABLE BigRows (c1 INT, c2 CHAR(1000));
GO

CREATE CLUSTERED INDEX CI_BigRows ON BigRows (c1);
GO

INSERT INTO BIGROWS VALUES (1, 'A'),
                           (2, 'A'),
                           (3, 'A'),
                           (4, 'A'),
                           (5, 'A'),
                           (6, 'A'),
                           (7, 'A');

BEGIN TRAN
INSERT INTO BIGROWS VALUES (8, 'A');

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID()

COMMIT TRAN
GO

BEGIN TRAN
INSERT INTO BigRows VALUES (5, 'a');

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID()

COMMIT TRAN
GO

DBCC IND('MCM2008', 'BigRows', -1)
GO

DBCC TRACEON(3604);
GO

DBCC PAGE ('MCM2008', 1, 297, 3);
GO

-- 100 char c2

DROP TABLE BigRows;
GO

CREATE TABLE BigRows (c1 INT, c2 CHAR(100));
GO

CREATE CLUSTERED INDEX CI_BigRows ON BigRows (c1);
GO


INSERT INTO BigRows VALUES (1, 'a'), (2, 'b');
GO

INSERT INTO BigRows VALUES (4, 'c');
GO 64

BEGIN TRAN
INSERT INTO BigRows VALUES (5, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID()

COMMIT TRAN
GO

BEGIN TRAN
INSERT INTO BigRows VALUES (3, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID()

COMMIT TRAN
GO

-- 10 char c2

DROP TABLE BigRows;
GO

CREATE TABLE BigRows (c1 INT, c2 CHAR(10));
GO

CREATE CLUSTERED INDEX CI_BigRows ON BigRows (c1);
GO

INSERT INTO BigRows VALUES (1, 'a');
GO 6

-- most likely skewed page split, moving all these to another page; thus more logging
INSERT INTO BigRows VALUES (3, 'c');
GO 254

BEGIN TRAN
INSERT INTO BigRows VALUES (2, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID()

COMMIT TRAN
GO

BEGIN TRAN
INSERT INTO BigRows VALUES (3, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID()

COMMIT TRAN
GO

DBCC IND('MCM2008', 'BigRows', -1)
GO

DBCC TRACEON(3604);
GO

-- pminlen = 18                        m_slotCnt = 131                     m_freeCnt = 4059
DBCC PAGE ('MCM2008', 1, 286, 3);
GO

-- pminlen = 18                        m_slotCnt = 131                     m_freeCnt = 4035
DBCC PAGE ('MCM2008', 1, 297, 3);
GO