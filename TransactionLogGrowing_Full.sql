use master;
go

if DATABASEPROPERTYEX('Sample', 'Version') is not null drop database Sample;
go

create database Sample
on primary (
name = 'Sample_Data',
filename = 'l:\Sample_Data.mdf',
size = 200mb
)
log on (
name = 'Sample_Log',
filename = 'l:\Sample_Log.mdf',
size = 10mb
)
go

alter database Sample modify file (
name = 'Sample_Log',
filegrowth=50%
)

alter database Sample set recovery full;
go

use Sample;
go

create table T (
ID int identity,
Data char (8000) default 'a'
);
go

backup database Sample to disk = 'l:\Sample.bak' with init, stats=10;
go

select log_reuse_wait, log_reuse_wait_desc from sys.databases where name = 'Sample'

backup database Sample to disk = 'l:\Sample_diff.bak' with differential, init, stats=10;
go

backup log Sample to disk = 'l:\Sample_log_1.bak' with init, stats=10;
go

backup log Sample to disk = 'l:\Sample_log_2.bak' with init, stats=10;
go

backup log Sample to disk = 'l:\Sample_log_3.bak' with init, stats=10;
go

select count(*) from fn_dblog(null, null);
go

-- use file = 3 if you have multiple
restore database Sample from Disk = 'l:\Sample.bak' with replace, norecovery;
restore database Sample from Disk = 'l:\Sample_diff.bak' with norecovery;
restore log Sample from Disk = 'l:\Sample_log_1.bak' with norecovery;
restore log Sample from Disk = 'l:\Sample_log_2.bak' with recovery;
restore log Sample from Disk = 'l:\Sample_log_3.bak' with recovery;

select count(*) from T with (nolock)