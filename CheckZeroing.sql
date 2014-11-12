DBCC TRACEON(3004, 3605, -1)
GO

CREATE DATABASE ZeroingCheck;
GO

EXEC sp_readerrorlog;
GO

DROP DATABASE ZeroingCheck;
GO

DBCC TRACEOFF(3004, 3605, -1)
GO

--+ DISABLED HERE
--DBCC TRACEON 3004, server process ID (SPID) 52. This is an informational message only; no user action is required.
--DBCC TRACEON 3605, server process ID (SPID) 52. This is an informational message only; no user action is required.
--Zeroing C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\ZeroingCheck_log.ldf from page 0 to 102 (0x0 to 0xcc000)
--Zeroing completed on C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\ZeroingCheck_log.ldf
--Starting up database 'ZeroingCheck'.
--FixupLogTail(progress) zeroing C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\ZeroingCheck_log.ldf from 0x5000 to 0x6000.
--Zeroing C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\ZeroingCheck_log.ldf from page 3 to 32 (0x6000 to 0x40000)
--Zeroing completed on C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\ZeroingCheck_log.ldf
--DBCC TRACEOFF 3004, server process ID (SPID) 52. This is an informational message only; no user action is required.
--DBCC TRACEOFF 3605, server process ID (SPID) 52. This is an informational message only; no user action is required.