use master;
go

if DATABASEPROPERTYEX('Spread', 'Version') > 0 drop database Spread;
go

create database Spread
on primary (
Name = 'Spread_Data',
Filename = 'f:\_data\Spread_Data.mdf',
Size = 20mb
),
filegroup NormalFG (
Name = 'Spread__Normal_Data',
Filename = 'e:\Spread__Normal_Data.ndf',
Size = 10mb
),
filegroup SparseFG (
Name = 'Spread__Sparse_Data',
Filename = 'h:\Spread__Sparse_Data.ndf',
Size = 10mb
)
log on (
Name = 'Spread_Log',
Filename = 'c:\_SQL_LOG\Spread_Log.ndf',
Size = 500mb
);
go

use Spread;
go

if object_id('Normal', 'U') is not null drop table Normal
go

create table Normal (
ID int identity primary key not null,
Name char (100) not null,
Type tinyint not null,
Size bigint not null
) on NormalFG;
go

declare @i as int = 3;
while @i <= 1000
begin
exec('alter table Normal add p' + @i + ' int null;');
set @i = @i + 1
end
go

insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Normal (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
go 10000

if object_id('Sparse', 'U') is not null drop table Sparse
go

create table Sparse (
ID int identity primary key not null,
Name char (100) not null,
Type tinyint not null,
Size bigint not null
) on SparseFG;
go

declare @i as int = 3;
while @i <= 1000
begin
exec('alter table Sparse add p' + @i + ' int sparse null;');
set @i = @i + 1
end
go

insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
insert into Sparse (Name, Type, Size, p3) values ('Hello', 1, 100, 1)
go 10000

--sp_help Normal
--sp_help Sparse

select top 10 * from Normal;
select top 10 * from Sparse;

select * from sys.database_files

select avg_record_size_in_bytes, page_count, * from sys.dm_db_index_physical_stats(db_id('Spread'), object_id('Normal'), 1, null, 'sampled')
select avg_record_size_in_bytes, page_count, * from sys.dm_db_index_physical_stats(db_id('Spread'), object_id('Sparse'), 1, null, 'sampled')

-- convert normal
declare @i as int = 3;
while @i <= 1000
begin
exec('alter table Normal alter column p' + @i + ' int sparse null;');
set @i = @i + 1
end
go

--alter index PK__Normal__3214EC27846E38EF on Normal rebuild