--from Pro SQL Server Internals, p. 116

USE master;
GO

IF DATABASEPROPERTYEX('PageSplits', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE PageSplits SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE PageSplits;
END
GO

CREATE DATABASE PageSplits;
GO

USE PageSplits;
GO

SET NOCOUNT ON;
GO

DBCC TRACEON (3604);
GO

create table dbo.PageSplitDemo
(
ID int not null,
Data varchar(8000) null
);
GO

create unique clustered index IDX_PageSplitDemo_ID
on dbo.PageSplitDemo(ID);
GO

;with N1(C) as (select 0 union all select 0) -- 2 rows
,N2(C) as (select 0 from N1 as T1 cross join N1 as T2) -- 4 rows
,N3(C) as (select 0 from N2 as T1 cross join N2 as T2) -- 16 rows
,N4(C) as (select 0 from N3 as T1 cross join N3 as T2) -- 256 rows
,N5(C) as (select 0 from N4 as T1 cross join N2 as T2) -- 1,024 rows
,IDs(ID) as (select row_number() over (order by (select NULL)) from N5)
insert into dbo.PageSplitDemo(ID)
select ID * 2
from Ids
where ID <= 620
GO

--page_count           avg_page_space_used_in_percent
---------------------- ------------------------------
--1                    99.5552260934025
select page_count, avg_page_space_used_in_percent
from sys.dm_db_index_physical_stats(db_id(),object_id(N'dbo.PageSplitDemo'),1,null,'DETAILED');
GO

insert into dbo.PageSplitDemo(ID,Data) values(101,replicate('a',8000));
GO

--page_count           avg_page_space_used_in_percent
---------------------- ------------------------------
--3                    66.1848282678527
--1                    0.457128737336299
select page_count, avg_page_space_used_in_percent
from sys.dm_db_index_physical_stats(db_id(),object_id(N'dbo.PageSplitDemo'),1,null,'DETAILED');

USE master;
GO

IF DATABASEPROPERTYEX('PageSplits', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE PageSplits SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE PageSplits;
END
GO