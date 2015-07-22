--from Pro SQL Server Internals, p. 29

USE master;
GO

IF DATABASEPROPERTYEX('HeapAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE HeapAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HeapAnalysis;
END
GO

CREATE DATABASE HeapAnalysis;
GO

USE HeapAnalysis;
GO

SET NOCOUNT ON;
GO

DBCC TRACEON (3604);
GO

create table dbo.Heap
(
Val varchar(8000) not null
);
GO

;with CTE(ID,Val)
as
(
select 1, replicate('0',4089)
union all
select ID + 1, Val from CTE where ID < 20
)
insert into dbo.Heap
select Val from CTE;
GO

select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent
from sys.dm_db_index_physical_stats(db_id(),object_id(N'dbo.Heap'),0,null,'DETAILED');
GO

insert into dbo.Heap(Val) values(replicate('1',100));
GO

-- same page count (record fit)
select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent
from sys.dm_db_index_physical_stats(db_id(),object_id(N'dbo.Heap'),0,null,'DETAILED');
GO

insert into dbo.Heap(Val) values(replicate('2',2000));
GO

-- it would have fit, but PFS is used; SQL Server doesn't check space directly
select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent
from sys.dm_db_index_physical_stats(db_id(),object_id(N'dbo.Heap'),0,null,'DETAILED');
GO

USE master;
GO

IF DATABASEPROPERTYEX('HeapAnalysis', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE HeapAnalysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HeapAnalysis;
END
GO