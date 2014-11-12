USE master;
GO

IF DATABASEPROPERTYEX('PageExamination', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE PageExamination SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE PageExamination;
END
GO

CREATE DATABASE PageExamination;
GO

USE PageExamination;
GO

CREATE TABLE DbccPageTest (
IntCol1 INT IDENTITY,
IntCol2 INT,
VCharCol VARCHAR(8000),
LogCol VARCHAR(max)
);
GO

INSERT INTO DbccPageTest VALUES (1, REPLICATE ('Row1', 600), REPLICATE('Row1Lob', 1000));
INSERT INTO DbccPageTest VALUES (2, REPLICATE ('Row2', 600), REPLICATE('Row2Lob', 1000));
INSERT INTO DbccPageTest VALUES (3, REPLICATE ('Row3', 600), REPLICATE('Row3Lob', 1000));
INSERT INTO DbccPageTest VALUES (4, REPLICATE ('Row4', 600), REPLICATE('Row4Lob', 1000));
GO

DBCC IND (PageExamination, DbccPageTest, -1)
GO

DBCC TRACEON (3604);
GO

DBCC PAGE ('PageExamination', 1, 289, 3);
GO

--DBCC PAGE ('DBNAME', FILEID, PAGEID, DUMP_STYLE);
--DUMP_STYLE: 1== record
--DUMP_STYLE: 1== page
--DUMP_STYLE: 1== each record fully
-- IAMFID == NULL => This is an IAM page
-- PageType == 10 => This is an IAM page
--
-- there are two IAM pages, one for hobt (1) and for lob (3)
-- m_pageId = (1:287)                  m_headerVersion = 1                 m_type = 1
-- m_typeFlagBits = 0x0                m_level = 0                         m_flagBits = 0x8000
-- m_objId (AllocUnitId.idObj) = 120   m_indexId (AllocUnitId.idInd) = 256 
-- Metadata: AllocUnitId = 72057594045792256                                
-- Metadata: PartitionId = 72057594040549376                                Metadata: IndexId = 0
-- Metadata: ObjectId = 245575913      m_prevPage = (0:0)                  m_nextPage = (0:0)
-- pminlen = 12                        m_slotCnt = 2                       m_freeCnt = 3202
-- m_freeData = 4986                   m_reservedCnt = 0                   m_lsn = (32:137:15)
-- m_xactReserved = 0                  m_xdesId = (0:0)                    m_ghostRecCnt = 0
-- m_tornBits = 0                      DB Frag ID = 1      
-- Allocation Status

-- GAM (1:2) = ALLOCATED               SGAM (1:3) = ALLOCATED              
-- PFS (1:1) = 0x62 MIXED_EXT ALLOCATED  80_PCT_FULL                        DIFF (1:6) = CHANGED
-- ML (1:7) = NOT MIN_LOGGED                  
-- DATA:
-- Slot 0, Offset 0x60, Length 2445, DumpStyle BYTE

-- Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
-- Record Size = 2445                  
-- Memory Dump @0x000000000B89A060            
-- OFFSET TABLE:
-- Row - Offset                        
-- 1 (0x1) - 2541 (0x9ed)              
-- 0 (0x0) - 96 (0x60)                             
--




-- m_pageId = (1:PAGEID)                  m_headerVersion = ALWAYS_1                 m_type = 1==DATA
-- m_typeFlagBits = 0x0                m_level = HEAP_IS_0                         m_flagBits = 0x8000
-- m_objId (AllocUnitId.idObj) = A   m_indexId (AllocUnitId.idInd) = B 
-- Metadata: AllocUnitId = A+B                                
-- Metadata: PartitionId = 72057594040549376                                Metadata: IndexId = 0
-- Metadata: ObjectId = 245575913      m_prevPage = 0 for heap                  m_nextPage = (0:0)
-- pminlen = 12                        m_slotCnt = # OF RECORDS                       m_freeCnt = FREE SPACE ON PAGE
-- m_freeData = 4986                   m_reservedCnt = 0                   m_lsn = MOST IMPORTANT NUMBER (last log record reflected for this page)
-- m_xactReserved = 0                  m_xdesId = (0:0)                    m_ghostRecCnt = 0
-- m_tornBits = 0                      DB Frag ID = 1                      
-- Allocation Status

-- GAM (1:2) = ALLOCATED               SGAM (1:3) = ALLOCATED              
-- PFS (1:1) = 0x62 MIXED_EXT ALLOCATED  80 PERCENT FULL                        DIFF (1:6) = CHANGED
-- ML (1:7) = NOT MIN_LOGGED                           
-- DATA:
-- Slot 0, Offset 0x60, Length 2445, DumpStyle BYTE

-- Record Type = PRIMARY_RECORD == DATA RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
-- Record Size = 2445                  
-- Memory Dump @0x000000000B89A060         
-- OFFSET TABLE: (SLOT ARRAY, they show backwards)
-- Row - Offset                        
-- 1 (0x1) - 2541 (0x9ed)              
-- 0 (0x0) - 96 (0x60)                             


--DBCC PAGE ('PageExamination', 4, 13, 3);

--PageFID PagePID     IAMFID IAMPID      ObjectID    IndexID     PartitionNumber PartitionID          iam_chain_type       PageType IndexLevel NextPageFID NextPagePID PrevPageFID PrevPagePID
--------- ----------- ------ ----------- ----------- ----------- --------------- -------------------- -------------------- -------- ---------- ----------- ----------- ----------- -----------
--1       284         NULL   NULL        245575913   0           1               72057594040549376    In-row data          10       NULL       0           0           0           0
--1       283         1      284         245575913   0           1               72057594040549376    In-row data          1        0          0           0           0           0
--1       287         1      284         245575913   0           1               72057594040549376    In-row data          1        0          0           0           0           0
--1       282         NULL   NULL        245575913   0           1               72057594040549376    LOB data             10       NULL       0           0           0           0
--1       281         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0
--1       285         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0
--1       286         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0
--1       288         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0

--(8 row(s) affected)

-- this will remove the data and put a forwarder in its place
UPDATE DbccPageTest
SET VCharCol = REPLICATE ('LongRow4', 1000)
WHERE IntCol2 = 4
GO

DBCC IND (PageExamination, DbccPageTest, -1)
GO

--PageFID PagePID     IAMFID IAMPID      ObjectID    IndexID     PartitionNumber PartitionID          iam_chain_type       PageType IndexLevel NextPageFID NextPagePID PrevPageFID PrevPagePID
--------- ----------- ------ ----------- ----------- ----------- --------------- -------------------- -------------------- -------- ---------- ----------- ----------- ----------- -----------
--1       284         NULL   NULL        245575913   0           1               72057594040549376    In-row data          10       NULL       0           0           0           0
--1       283         1      284         245575913   0           1               72057594040549376    In-row data          1        0          0           0           0           0
--1       287         1      284         245575913   0           1               72057594040549376    In-row data          1        0          0           0           0           0
--1       289         1      284         245575913   0           1               72057594040549376    In-row data          1        0          0           0           0           0
--1       282         NULL   NULL        245575913   0           1               72057594040549376    LOB data             10       NULL       0           0           0           0
--1       281         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0
--1       285         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0
--1       286         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0
--1       288         1      282         245575913   0           1               72057594040549376    LOB data             3        0          0           0           0           0

--(9 row(s) affected)

CREATE CLUSTERED INDEX Dbcc_CI
	ON DbccPageTest (IntCol1);
GO

DBCC IND (PageExamination, DbccPageTest, -1)
GO

--PageFID PagePID     IAMFID IAMPID      ObjectID    IndexID     PartitionNumber PartitionID          iam_chain_type       PageType IndexLevel NextPageFID NextPagePID PrevPageFID PrevPagePID
--------- ----------- ------ ----------- ----------- ----------- --------------- -------------------- -------------------- -------- ---------- ----------- ----------- ----------- -----------
--1       292         NULL   NULL        245575913   1           1               72057594040614912    In-row data          10       NULL       0           0           0           0
--1       291         1      292         245575913   1           1               72057594040614912    In-row data          1        0          1           293         0           0
--1       293         1      292         245575913   1           1               72057594040614912    In-row data          1        0          0           0           1           291
--1       294         1      292         245575913   1           1               72057594040614912    In-row data          2        1          0           0           0           0
--1       282         NULL   NULL        245575913   1           1               72057594040614912    LOB data             10       NULL       0           0           0           0
--1       281         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       285         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       286         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       288         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0

--(9 row(s) affected)

-- PAGE 294 has PageType 2 => index record

DBCC PAGE ('PageExamination', 1, 294, 1);
GO

--Slot 0, Offset 0x60, Length 11, DumpStyle BYTE

--Record Type = INDEX_RECORD          Record Attributes =                 Record Size = 11

--Memory Dump @0x000000001537A060

--0000000000000000:   06010000 00230100 000100                      .....#.....

DBCC PAGE ('PageExamination', 1, 294, 3);
GO

--FileId PageId      Row    Level  ChildFileId ChildPageId IntCol1 (key) UNIQUIFIER (key) KeyHashValue     Row Size
-------- ----------- ------ ------ ----------- ----------- ------------- ---------------- ---------------- --------
--1      294         0      1      1           291         NULL          NULL             NULL             11
--1      294         1      1      1           293         4             0                NULL             11

--(2 row(s) affected)


CREATE NONCLUSTERED INDEX Dbcc_NCI
	ON DbccPageTest (IntCol2);
GO

DBCC IND (PageExamination, DbccPageTest, -1)
GO

--PageFID PagePID     IAMFID IAMPID      ObjectID    IndexID     PartitionNumber PartitionID          iam_chain_type       PageType IndexLevel NextPageFID NextPagePID PrevPageFID PrevPagePID
--------- ----------- ------ ----------- ----------- ----------- --------------- -------------------- -------------------- -------- ---------- ----------- ----------- ----------- -----------
--1       292         NULL   NULL        245575913   1           1               72057594040614912    In-row data          10       NULL       0           0           0           0
--1       291         1      292         245575913   1           1               72057594040614912    In-row data          1        0          1           293         0           0
--1       293         1      292         245575913   1           1               72057594040614912    In-row data          1        0          0           0           1           291
--1       294         1      292         245575913   1           1               72057594040614912    In-row data          2        1          0           0           0           0
--1       282         NULL   NULL        245575913   1           1               72057594040614912    LOB data             10       NULL       0           0           0           0
--1       281         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       285         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       286         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       288         1      282         245575913   1           1               72057594040614912    LOB data             3        0          0           0           0           0
--1       283         NULL   NULL        245575913   3           1               72057594040680448    In-row data          10       NULL       0           0           0           0
--1       295         1      283         245575913   3           1               72057594040680448    In-row data          2        0          0           0           0           0

--(11 row(s) affected)

DBCC PAGE ('PageExamination', 1, 295, 3);
GO

--FileId PageId      Row    Level  IntCol2 (key) IntCol1 (key) UNIQUIFIER (key) KeyHashValue     Row Size
-------- ----------- ------ ------ ------------- ------------- ---------------- ---------------- --------
--1      295         0      0      1             1             0                (4fab0ff3e3c7)   12
--1      295         1      0      2             2             0                (29a347ff72ce)   12
--1      295         2      0      3             3             0                (f4a47ffbfd36)   12
--1      295         3      0      4             4             0                (e5b3d7e750dd)   12

--(4 row(s) affected)

DROP INDEX DbccPageTest.Dbcc_CI;
GO

DBCC IND (PageExamination, DbccPageTest, -1)
GO

--PageFID PagePID     IAMFID IAMPID      ObjectID    IndexID     PartitionNumber PartitionID          iam_chain_type       PageType IndexLevel NextPageFID NextPagePID PrevPageFID PrevPagePID
--------- ----------- ------ ----------- ----------- ----------- --------------- -------------------- -------------------- -------- ---------- ----------- ----------- ----------- -----------
--1       292         NULL   NULL        245575913   0           1               72057594040745984    In-row data          10       NULL       0           0           0           0
--1       291         1      292         245575913   0           1               72057594040745984    In-row data          1        0          1           293         0           0
--1       293         1      292         245575913   0           1               72057594040745984    In-row data          1        0          0           0           1           291
--1       282         NULL   NULL        245575913   0           1               72057594040745984    LOB data             10       NULL       0           0           0           0
--1       281         1      282         245575913   0           1               72057594040745984    LOB data             3        0          0           0           0           0
--1       285         1      282         245575913   0           1               72057594040745984    LOB data             3        0          0           0           0           0
--1       286         1      282         245575913   0           1               72057594040745984    LOB data             3        0          0           0           0           0
--1       288         1      282         245575913   0           1               72057594040745984    LOB data             3        0          0           0           0           0
--1       287         NULL   NULL        245575913   3           1               72057594040811520    In-row data          10       NULL       0           0           0           0
--1       284         1      287         245575913   3           1               72057594040811520    In-row data          2        0          0           0           0           0

--(10 row(s) affected)

DBCC PAGE ('PageExamination', 1, 284, 3);
GO

--FileId PageId      Row    Level  IntCol2 (key) HEAP RID (key)     KeyHashValue     Row Size
-------- ----------- ------ ------ ------------- ------------------ ---------------- --------
--1      284         0      0      1             0x2301000001000000 (18284b7a376f)   16
--1      284         1      0      2             0x2301000001000100 (275f04354dbc)   16
--1      284         2      0      3             0x2301000001000200 (e4ab3fffc1f9)   16
--1      284         3      0      4             0x2501000001000000 (334ab1ad6e51)   16
--                                                 FFFFFFFFPPPPSSSS
-- S slot number
-- P page ID
-- F page within file

--(4 row(s) affected)
