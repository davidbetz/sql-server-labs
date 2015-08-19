--GRANT VIEW DATABASE STATE TO dbetz;

SELECT SUM(reserved_page_count)*8.0/1024
FROM sys.dm_db_partition_stats; 
GO

-- Calculates the size of individual database objects. 
SELECT sys.objects.name, SUM(reserved_page_count) * 8.0 / 1024
FROM sys.dm_db_partition_stats, sys.objects 
WHERE sys.dm_db_partition_stats.object_id = sys.objects.object_id 
GROUP BY sys.objects.name; 
GO

-- Will return the Server Name we are running on
SELECT @@Servername
 
-- DMV: dm_exec_connections gets the connection information
SELECT getdate() as "RunDateTime", c.* 
FROM sys.dm_exec_connections c
Go
 
-- DMV: dm_exec_sessions gives the current sessions
SELECT getdate() as "RunDateTime", s.*
FROM sys.dm_exec_sessions s
Go
 
--DMV: dm_exec_requests gives the active sessions/spids currently
SELECT getdate() as "RunDateTime", st.text, r.* 
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st
GO

-- Will return the Server Name we are running on
SELECT @@Servername
 
-- DMV: dm_exec_connections gets the connection information
SELECT getdate() as "RunDateTime", c.* 
FROM sys.dm_exec_connections c
Go
 
-- DMV: dm_exec_sessions gives the current sessions
SELECT getdate() as "RunDateTime", s.*
FROM sys.dm_exec_sessions s
Go
 
--DMV: dm_exec_requests gives the active sessions/spids currently
SELECT getdate() as "RunDateTime", st.text, r.* 
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st
GO


-- Will return the Server Name we are running on
SELECT @@Servername
 
-- DMV: dm_exec_connections gets the connection information
SELECT getdate() as "RunDateTime", c.* 
FROM sys.dm_exec_connections c
Go
 
-- DMV: dm_exec_sessions gives the current sessions
SELECT getdate() as "RunDateTime", s.*
FROM sys.dm_exec_sessions s
Go
 
--DMV: dm_exec_requests gives the active sessions/spids currently
SELECT getdate() as "RunDateTime", st.text, r.* 
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st
GO

-- Will return the Server Name we are running on
SELECT @@Servername
 
-- DMV: dm_exec_connections gets the connection information
SELECT getdate() as "RunDateTime", c.* 
FROM sys.dm_exec_connections c
Go
 
-- DMV: dm_exec_sessions gives the current sessions
SELECT getdate() as "RunDateTime", s.*
FROM sys.dm_exec_sessions s
Go
 
--DMV: dm_exec_requests gives the active sessions/spids currently
SELECT getdate() as "RunDateTime", st.text, r.* 
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st
GO

--To get information about the bandwidth used by each database in your SQL Database server.
--SELECT * FROM sys.bandwidth_usage

--To get information about the database state of a database that is being copied.
SELECT * FROM sys.databases

--To get information about the replica databases on a given server.
--SELECT * FROM sys.dm_database_copies

--To get information about all the replica databases of a given source database.
--SELECT * FROM sys.dm_continuous_copy_status


select * from sys.dm_tran_locks


select * from sys.fulltext_indexes
select * from sys.dm_db_file_space_usage
--select * from sys.dm_os_volume_stats
select * from sys.dm_db_partition_stats


--SELECT 
--    (COUNT(end_time) - SUM(CASE WHEN avg_cpu_percent > 80 THEN 1 ELSE 0 END) * 1.0) / COUNT(end_time) AS 'CPU Fit Percent'
--    ,(COUNT(end_time) - SUM(CASE WHEN avg_log_write_percent > 80 THEN 1 ELSE 0 END) * 1.0) / COUNT(end_time) AS 'Log Write Fit Percent'
--    ,(COUNT(end_time) - SUM(CASE WHEN avg_data_io_percent > 80 THEN 1 ELSE 0 END) * 1.0) / COUNT(end_time) AS 'Physical Data Read Fit Percent'
--FROM sys.dm_db_resource_stats