USE master;
GO

IF DATABASEPROPERTYEX('RowStructure', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE RowStructure SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE RowStructure;
END
GO

CREATE DATABASE RowStructure;
GO

USE RowStructure;
GO

CREATE TABLE DataTable (
	ID INT NOT NULL,
	Column1 VARCHAR(255) NULL,
	Column2 VARCHAR(255) NULL,
	Column3 VARCHAR(255) NULL,
) ON [Primary];
GO

INSERT INTO DataTable (ID, Column1, Column3) VALUES (1, REPLICATE('A', 255), REPLICATE('A', 255));
GO

INSERT INTO DataTable (ID, Column2) VALUES (2, REPLICATE('B', 255));
GO

DBCC IND ('RowStructure', 'DataTable', -1)
GO

/*
SELECT
allocated_page_file_id,
allocated_page_page_id,
allocated_page_iam_file_id,
allocated_page_iam_page_id,
object_id,
index_id,
partition_id,
rowset_id,
allocation_unit_type_desc,
page_type,
'NOT FOUND' as index_level,
next_page_file_id,
next_page_page_id,
previous_page_file_id,
previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID('RowStructure'), OBJECT_ID('DataTable'), null, null, 'DETAILED')
*/
	/* DBID: required */
	/* Table ID: optional */
	/* IndexID: optional */
	/* PartitionID: optional */
	/* Mode: required: DETAILED or LIMITED */

--PageFID PagePID     IAMFID IAMPID      ObjectID    IndexID     PartitionNumber PartitionID          iam_chain_type       PageType IndexLevel NextPageFID NextPagePID PrevPageFID PrevPagePID
--------- ----------- ------ ----------- ----------- ----------- --------------- -------------------- -------------------- -------- ---------- ----------- ----------- ----------- -----------
--1       282         NULL   NULL        245575913   0           1               72057594040549376    In-row data          10       NULL       0           0           0           0
--1       281         1      282         245575913   0           1               72057594040549376    In-row data          1        0          0           0           0           0

DBCC TRACEON (3604);
GO

DBCC PAGE ('RowStructure', 1 /* File ID */, 281, 1);
GO

--Slot 0 Offset 0x60 Length 529

--Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
--Record Size = 529                   
--Memory Dump @0x0000000006B5A060

--0000000000000000:   30000800 01000000 04000403 00120112 01110241  0..................A
--                    AABBOOOO DDDDDDDD NNNNBBVV VV111122 223333--
--Status Bits A
--Status Bits B
--Offset to number of columns
--ID
--Number of Columns
--Null Bitmap
--Number of variable-length columns
--Offset where Column1 ends
--Offset where Column2 ends
--Offset where Column3 ends
--Column1 data