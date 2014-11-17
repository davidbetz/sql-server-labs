USE master;
GO

IF DATABASEPROPERTYEX('StatisticsExample', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE StatisticsExample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE StatisticsExample;
END
GO

CREATE DATABASE StatisticsExample;
GO

USE StatisticsExample;
GO

DBCC TRACEON (3604);
GO

CREATE TABLE Book (
	BookID INT IDENTITY(1, 1) NOT NULL,
	Title NVARCHAR(256) NOT NULL,
	ISBN CHAR(14) NOT NULL,
	PlaceHolder CHAR(50) NULL
) ON [Primary];
GO

CREATE UNIQUE CLUSTERED INDEX IDX_Book_BookID ON Book(BookID);
GO

SET STATISTICS IO ON
GO

WITH Prefix(Prefix)
AS
(
	SELECT 100
	UNION ALL
	SELECT Prefix + 1
	FROM Prefix
	WHERE Prefix < 600
),
Postfix(Postfix)
AS
(
	SELECT 100000001
	UNION ALL
	SELECT Postfix + 1
	FROM Postfix
	WHERe Postfix < 100002500
)
INSERT INTO Book(ISBN, Title)
SELECT
CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9), Postfix),
'Title for ISBN' + CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9), Postfix)
FROM Prefix CROSS JOIN Postfix
OPTION(MAXRECURSION 0)
GO

CREATE NONCLUSTERED INDEX Book_ISBN_NCI ON Book(ISBN);
GO

DBCC SHOW_STATISTICS('Book', Book_ISBN_NCI)
GO

--Name                                                                                                                             Updated              Rows                 Rows Sampled         Steps  Density       Average key length String Index Filter Expression                                                                                                                                                                                                                                                Unfiltered Rows
---------------------------------------------------------------------------------------------------------------------------------- -------------------- -------------------- -------------------- ------ ------------- ------------------ ------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------
--Book_ISBN_NCI                                                                                                               Nov 15 2014  9:19PM  1252500              1252500              189    1             18                 YES          NULL                                                                                                                                                                                                                                                             1252500

--(1 row(s) affected)

--All density   Average Length Columns
--------------- -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--7.984032E-07  14             ISBN
--7.984032E-07  18             ISBN, BookID

--(2 row(s) affected)

--RANGE_HI_KEY   RANGE_ROWS    EQ_ROWS       DISTINCT_RANGE_ROWS  AVG_RANGE_ROWS
---------------- ------------- ------------- -------------------- --------------
--100-0100000001 0             1             0                    1
--101-0100001796 4294          1             4294                 1
--103-0100000892 4095          1             4095                 1
--105-0100002036 6143          1             6143                 1

WITH Prefix(Prefix) AS (  
      SELECT Num        
	  FROM (VALUES(104),(104),(104),(104),(104)) Num(Num) 

),
Postfix(Postfix) as (    
	SELECT 100000001    
	UNION all     
	SELECT Postfix + 1      
	FROM Postfix    
	WHERE Postfix < 100002500
) 
INSERT INTO Book(ISBN, Title)    
SELECT
CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9),Postfix)
,'Title for ISBN' + CONVERT(CHAR(3), Prefix) + '-0' + CONVERT(CHAR(9),Postfix)      
FROM Prefix CROSS JOIN Postfix
OPTION (MAXRECURSION 0);
GO

--++ Mod Count == 12500
--Stat ID     Table       Statistics        last_updated                rows                 rows_sampled         Mod Count
------------- ----------- ----------------- --------------------------- -------------------- -------------------- --------------------
--1           dbo.Book    IDX_Book_BookID   NULL                        NULL                 NULL                 NULL
--2           dbo.Book    Book_ISBN_NCI     2014-11-16 00:11:26.7600000 1252500              1252500              12500
SELECT
s.stats_id as [Stat ID]
,sc.name + '.' + t.name as [Table]
,s.name as [Statistics]
,p.last_updated
,p.rows
,p.rows_sampled
,p.modification_counter as [Mod Count]
FROM sys.stats s join sys.tables t ON s.object_id = t.object_id
JOIN sys.schemas sc ON t.schema_id = sc.schema_id
OUTER APPLY sys.dm_db_stats_properties(t.object_id,s.stats_id) p
WHERE sc.name = 'dbo' and t.name = 'Book'
GO

UPDATE STATISTICS Book Book_ISBN_NCI WITH FULLSCAN
GO

--++ Mod Count == 0
--Stat ID     Table       Statistics      last_updated                rows                 rows_sampled         Mod Count
------------- ----------- --------------- --------------------------- -------------------- -------------------- --------------------
--1           dbo.Book    IDX_Book_BookID NULL                        NULL                 NULL                 NULL
--2           dbo.Book    Book_ISBN_NCI   2014-11-16 00:11:58.5430000 1265000              1265000              0
SELECT
s.stats_id as [Stat ID]
,sc.name + '.' + t.name as [Table]
,s.name as [Statistics]
,p.last_updated
,p.rows
,p.rows_sampled
,p.modification_counter as [Mod Count]
FROM sys.stats s join sys.tables t ON s.object_id = t.object_id
JOIN sys.schemas sc ON t.schema_id = sc.schema_id
OUTER APPLY sys.dm_db_stats_properties(t.object_id,s.stats_id) p
WHERE sc.name = 'dbo' and t.name = 'Book'
GO

DBCC SHOW_STATISTICS('Book', Book_ISBN_NCI)
GO

--Name                                                                                                                             Updated              Rows                 Rows Sampled         Steps  Density       Average key length String Index Filter Expression                                                                                                                                                                                                                                                Unfiltered Rows
---------------------------------------------------------------------------------------------------------------------------------- -------------------- -------------------- -------------------- ------ ------------- ------------------ ------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------
--Book_ISBN_NCI                                                                                                               Nov 15 2014  9:54PM  1265000              1265000              184    0.9901289     18                 YES          NULL                                                                                                                                                                                                                                                             1265000

--(1 row(s) affected)

--All density   Average Length Columns
--------------- -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--7.984032E-07  14             ISBN
--7.905138E-07  18             ISBN, BookID

--(2 row(s) affected)

--RANGE_HI_KEY   RANGE_ROWS    EQ_ROWS       DISTINCT_RANGE_ROWS  AVG_RANGE_ROWS
---------------- ------------- ------------- -------------------- --------------
--100-0100000001 0             1             0                    1
--100-0100002248 2246          1             2246                 1
--104-0100000001 7752          6             7752                 1
--104-0100000685 4098          6             683                  6
--104-0100001369 4098          6             683                  6
--105-0100000001 6786          1             1131                 6

SELECT BookID, ISBN, Title
FROM Book
WHERE ISBN LIKE '114%'
GO

WITH Postfix(Postfix)
AS
(
 SELECT 100000001
 UNION all
 SELECT Postfix + 1
 FROM Postfix
 WHERE Postfix < 100250000
)
INSERT INTO Book(ISBN, Title)
 SELECT
 '999-0' + CONVERT(CHAR(9),Postfix)
 ,'Title for ISBN 999-0' + CONVERT(CHAR(9),Postfix)
 FROM Postfix
OPTION (maxrecursion 0)
GO

DBCC SHOW_STATISTICS('Book', Book_ISBN_NCI)
GO

--+++++++++ 1265000; the new records are not here
--Name                                                                                                                             Updated              Rows                 Rows Sampled         Steps  Density       Average key length String Index Filter Expression                                                                                                                                                                                                                                                Unfiltered Rows
---------------------------------------------------------------------------------------------------------------------------------- -------------------- -------------------- -------------------- ------ ------------- ------------------ ------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------
--Book_ISBN_NCI                                                                                                                    Nov 15 2014 11:26PM  1265000              1265000              184    0.9901289     18                 YES          NULL                                                                                                                                                                                                                                                             1265000

--All density   Average Length Columns
--------------- -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--7.984032E-07  14             ISBN
--7.905138E-07  18             ISBN, BookID

--RANGE_HI_KEY   RANGE_ROWS    EQ_ROWS       DISTINCT_RANGE_ROWS  AVG_RANGE_ROWS
---------------- ------------- ------------- -------------------- --------------
--100-0100000001 0             1             0                    1
--100-0100002248 2246          1             2246                 1
--104-0100000001 7752          6             7752                 1
--598-0100000397 8191          1             8191                 1
--600-0100002500 7102          1             7102                 1
--+++++++++ 999 is missing

SELECT *
FROM Book
WHERE ISBN LIKE '999%'
GO

UPDATE STATISTICS Book Book_ISBN_NCI WITH FULLSCAN
GO

--++++++++++++++++ records are here; 999 is present
--Name                                                                                                                             Updated              Rows                 Rows Sampled         Steps  Density       Average key length String Index Filter Expression                                                                                                                                                                                                                                                Unfiltered Rows
---------------------------------------------------------------------------------------------------------------------------------- -------------------- -------------------- -------------------- ------ ------------- ------------------ ------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- --------------------
--Book_ISBN_NCI                                                                                                                    Nov 15 2014 11:29PM  1515000              1515000              166    0.9917581     18                 YES          NULL                                                                                                                                                                                                                                                             1515000

--All density   Average Length Columns
--------------- -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--6.655574E-07  14             ISBN
--6.60066E-07   18             ISBN, BookID

--RANGE_HI_KEY   RANGE_ROWS    EQ_ROWS       DISTINCT_RANGE_ROWS  AVG_RANGE_ROWS
---------------- ------------- ------------- -------------------- --------------
--100-0100000001 0             1             0                    1
--101-0100001796 4294          1             4294                 1
--999-0100189505 8191          1             8191                 1
--999-0100197697 8191          1             8191                 1
--999-0100205889 8191          1             8191                 1
--999-0100230465 24575         1             24575                1
--999-0100238657 8191          1             8191                 1
--999-0100246849 8191          1             8191                 1
--999-0100249999 3149          1             3149                 1
--999-0100250000 0             1             0                    1

DBCC SHOW_STATISTICS('Book', Book_ISBN_NCI)
GO

SELECT *
FROM Book
WHERE ISBN LIKE '999%'
GO
