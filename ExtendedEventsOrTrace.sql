
SELECT * FROM sys.configurations 
WHERE configuration_id = 1568
-- where are they now?
SELECT path FROM sys.traces 
-- get from trace issues
SELECT    *
FROM::fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL11.CDEPROD\MSSQL\Log\log_1985.trc', 100)
--\\?\F:\MSSQL\Data\audittrace20170830150206_178.trc
    INNER JOIN sys.trace_events e
        ON eventclass = trace_event_id
    INNER JOIN sys.trace_categories AS cat
        ON e.category_id = cat.category_id
WHERE spid=86
--loginname like '%sql%' 
--AND applicationname like '%studio%'
--e.name NOT like 'Audit Schema%'
--AND e.name NOT like 'Audit Statement%'
ORDER BY starttime DESC;


CREATE EVENT SESSION [PerformanceMonitorUsers] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlos.wait_info_external(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.auto_stats,
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlos.task_time,sqlserver.client_hostname,sqlserver.is_system,sqlserver.session_nt_username)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)) AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%Report Server%') AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%SQLAgent%'))),
ADD EVENT sqlserver.rpc_starting(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1),collect_statement=(1)
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)) AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%Report Server%') AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%SQLAgent%'))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)) AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%Report Server%') AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%SQLAgent%'))),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlos.task_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.is_system,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username)
    WHERE ([package0].[divides_by_uint64]([sqlserver].[session_id],(5)) AND [package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_transaction(
    ACTION(package0.callstack,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)) 
ADD TARGET package0.event_file(SET filename=N'query_wait_analysis.xel',max_rollover_files=(3))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
GO

