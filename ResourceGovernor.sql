USE master;
GO

CREATE RESOURCE POOL Pool1 WITH (max_cpu_percent = 30);
CREATE RESOURCE POOL Pool2 WITH (max_cpu_percent = 70);
GO

CREATE WORKLOAD GROUP Group1 USING Pool1;
CREATE WORKLOAD GROUP Group2 USING Pool2;
go

CREATE DATABASE DB1;
GO

CREATE DATABASE DB2;
GO

-- must be in master
CREATE FUNCTION dbo.MyClassifier()
RETURNS sysname WITH SCHEMABINDING
AS
BEGIN
    DECLARE @GroupName sysname;
    -- ORIGINAL_DB_NAME is from the connection string, in SSMS this is your connecting DB
    IF ORIGINAL_DB_NAME() IN ('DB1')
        SET @GroupName = 'Group1';
    ELSE IF ORIGINAL_DB_NAME() IN ('DB2')
        SET @GroupName = 'Group2';
    ELSE 
        SET @GroupName = 'Default';
    RETURN @GroupName;
END
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.MyClassifier);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

SELECT * FROM sys.dm_resource_governor_configuration
SELECT * FROM sys.dm_resource_governor_workload_groups
SELECT * FROM sys.dm_os_performance_counters where counter_name = 'cpu usage %'
GO

SELECT OBJECT_SCHEMA_NAME(classifier_function_id) AS [schema_name],
       OBJECT_NAME(classifier_function_id) AS [function_name]
FROM sys.dm_resource_governor_configuration
GO

ALTER RESOURCE GOVERNOR DISABLE;
DROP WORKLOAD GROUP Group1;
DROP WORKLOAD GROUP Group2;
DROP RESOURCE POOL Pool1;
DROP RESOURCE POOL Pool2;
DROP DATABASE DB1;
DROP DATABASE DB2;
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = null);
DROP FUNCTION dbo.MyClassifier
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

/*
SELECT
    Sess.session_id,    Sess.program_name,    Sess.host_name,    Sess.login_name,
    Sess.nt_domain,    Sess.nt_user_name,    Sess.original_login_name,    RG_WG.pool_id,
    RG_P.name as Pool_Name,    Sess.group_id,    RG_WG.name as WorkGroup_Name
FROM sys.dm_exec_sessions Sess
    INNER JOIN sys.dm_resource_governor_workload_groups RG_WG ON Sess.group_id = RG_WG.group_id
    INNER JOIN sys.dm_resource_governor_resource_pools RG_P ON RG_WG.pool_id = RG_P.pool_id
WHERE Sess.is_user_process = 1;
    
*/

    --DBCC CHECKCATALOG('master')
/*
DBCC MEMORYSTATUS
DBCC SQLPERF(SPINLOCKSTATS)
SELECT * FROM sys.dm_os_memory_clerks
SELECT * FROM sys.dm_os_wait_stats order by wait_type
SELECT * FROM sys.dm_os_waiting_tasks
SELECT * FROM sys.dm_os_ring_buffers where ring_buffer_type='RING_BUFFER_OOM'
SELECT * FROM sys.dm_os_ring_buffers where ring_buffer_type='RING_BUFFER_RESOURCE_MONITOR'
SELECT * FROM sys.dm_os_ring_buffers where ring_buffer_type='RING_BUFFER_MEMORY_BROKER'
SELECT * FROM sys.dm_os_memory_cache_clock_hands
*/