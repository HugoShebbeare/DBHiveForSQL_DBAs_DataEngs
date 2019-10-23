CREATE PROC usp_DetectSQLCPU_ThresholdReached 
--RR code for thresholds, added as proc by HS, Oct 2017
--declare @count INT OUTPUT -- not sure If we need this, 
-- since will report 0 on all but times when cpu is 90, I have left step as cmd line 
-- so goal is to fail when expected 90 threshold reached, and free proc cache the server
-- DBA_CPU_Threshold  runs every 15 minutes, and will wait between 
AS

DECLARE @ts_now BIGINT = (
                             SELECT cpu_ticks / (cpu_ticks / ms_ticks) FROM sys.dm_os_sys_info
                         );
DECLARE @threshold INT = 40; -- percent
DECLARE @count INT;

WITH cte
AS (SELECT TOP (10)
        SQLProcessUtilization AS [SQL Server Process CPU Utilization],
        SystemIdle AS [System Idle Process],
        100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization],
        DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time]
    FROM
    (
        SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle],
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization],
               [timestamp]
        FROM
        (
            SELECT [timestamp],
                   CONVERT(XML, record) AS [record]
            FROM sys.dm_os_ring_buffers
            WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
                  AND record LIKE '%<SystemHealth>%'
        ) AS x
    ) AS y
    ORDER BY record_id DESC)
SELECT @count = COUNT(*)
FROM cte
WHERE [SQL Server Process CPU Utilization] > @threshold;

SELECT @count;
GO