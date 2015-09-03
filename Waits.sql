WITH Waits AS
(
    SELECT
        wait_type, 
        wait_time_ms / 1000 AS wait_time_seconds, 
        (100 * wait_time_ms) / SUM(wait_time_ms) OVER() AS [percent], 
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [row_number]
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR',  'LOGMGR_QUEUE', 'CHECKPOINT_QUEUE',  'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',  'FT_IFTS_SCHEDULER_IDLE_WAIT' , 'XE_DISPATCHER_WAIT',  'XE_DISPATCHER_JOIN',  'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
)
--SELECT * FROM Waits
SELECT
    W1.wait_type, 
    CAST(W1.wait_time_seconds AS DECIMAL(12,  2)) AS wait_time_seconds, 
    CAST(W1.[percent] AS DECIMAL(12,  2)) AS [percent], 
    CAST(SUM(W2.[percent]) AS DECIMAL(12,  2)) AS running_percent
FROM Waits AS W1
INNER JOIN Waits AS W2 ON W2.[row_number] <= W1.[row_number]
GROUP BY W1.[row_number],  W1.wait_type,  W1.wait_time_seconds,  W1.[percent]
HAVING SUM(W2.[percent]) - W1.[percent] < 99
OPTION (RECOMPILE);
GO
