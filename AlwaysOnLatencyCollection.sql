USE [msdb]
GO

/****** Object:  Job [AlwaysOn_Latency_Data_Collection]    Script Date: 2019-10-10 16:14:22 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2019-10-10 16:14:22 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AlwaysOn_Latency_Data_Collection', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'AGROPUR\admhushebbe', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect AG Information]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect AG Information', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' USE tempdb
                  IF OBJECT_ID(''AGInfo'') IS NOT NULL
                      BEGIN
                        DROP TABLE AGInfo
                   END 
                  IF OBJECT_ID(''LatencyCollectionStatus'') IS NOT NULL
                      BEGIN
                        DROP TABLE LatencyCollectionStatus
                      END
                   CREATE TABLE LatencyCollectionStatus(
                        [collection_status] [NVARCHAR](60)  NULL,
                        [start_timestamp] [DATETIMEOFFSET] NULL,
                        [startutc_timestamp] [DATETIMEOFFSET] NULL
                    )
                  INSERT INTO LatencyCollectionStatus(collection_status, start_timestamp, startutc_timestamp) values (''Started'', GETDATE(), GETUTCDATE())
                  SELECT
                  AGC.name as agname
                  , RCS.replica_server_name as replica_name
                  , ARS.role_desc as agrole
                  INTO AGInfo
                  FROM
                      sys.availability_groups_cluster AS AGC
                      INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
                      ON
                      RCS.group_id = AGC.group_id
                      INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
                      ON
                      ARS.replica_id = RCS.replica_id
                      where AGC.name =  N''AGEKHO1''', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create XE Session]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create XE Session', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (select * from sys.server_event_sessions 
                WHERE name = N''AlwaysOn_Data_Movement_Tracing'')
                    BEGIN
                    DROP EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER 
                    END
                CREATE EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER ADD EVENT sqlserver.hadr_apply_log_block, 
ADD EVENT sqlserver.hadr_capture_log_block, 
ADD EVENT sqlserver.hadr_database_flow_control_action, 
ADD EVENT sqlserver.hadr_db_commit_mgr_harden, 
ADD EVENT sqlserver.hadr_log_block_send_complete, 
ADD EVENT sqlserver.hadr_send_harden_lsn_message, 
ADD EVENT sqlserver.hadr_transport_flow_control_action, 
ADD EVENT sqlserver.log_flush_complete, 
ADD EVENT sqlserver.log_flush_start, 
ADD EVENT sqlserver.recovery_unit_harden_log_timestamps, 
ADD EVENT sqlserver.log_block_pushed_to_logpool, 
ADD EVENT sqlserver.hadr_transport_receive_log_block_message, 
ADD EVENT sqlserver.hadr_receive_harden_lsn_message, 
ADD EVENT sqlserver.hadr_log_block_group_commit, 
ADD EVENT sqlserver.hadr_log_block_compression, 
ADD EVENT sqlserver.hadr_log_block_decompression, 
ADD EVENT sqlserver.hadr_lsn_send_complete, 
ADD EVENT sqlserver.hadr_capture_filestream_wait, 
ADD EVENT sqlserver.hadr_capture_vlfheader ADD TARGET package0.event_file(SET filename=N''AlwaysOn_Data_Movement_Tracing.xel'',max_file_size=(25),max_rollover_files=(4))
                WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
                
                ALTER EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER STATE = START', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait For Collection]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait For Collection', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:2:00'' 
                                                       GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [End XE Session]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'End XE Session', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER STATE = STOP', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Extract XE Data]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extract XE Data', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
                    BEGIN TRANSACTION
                    USE tempdb
                    IF OBJECT_ID(''#EventXml'') IS NOT NULL
                    BEGIN
                        DROP TABLE #EventXml
                    END 

                    SELECT 
                        xe.event_name, 
                        CAST(xe.event_data AS XML) AS event_data
                    INTO #EventXml
                    FROM
                    (
                    SELECT
                            object_name AS event_name,
                            CAST(event_data AS XML) AS event_data
                        FROM sys.fn_xe_file_target_read_file(
                                    ''AlwaysOn_Data_Movement_Tracing*.xel'', 
                                    NULL, NULL, NULL)
                        WHERE object_name IN (''hadr_log_block_group_commit'',
                                    ''log_block_pushed_to_logpool'',
                                    ''log_flush_start'',
                                    ''log_flush_complete'',
                                    ''hadr_log_block_compression'',
                                    ''hadr_capture_log_block'',
                                    ''hadr_capture_filestream_wait'',
                                    ''hadr_log_block_send_complete'',
                                    ''hadr_receive_harden_lsn_message'',
                                    ''hadr_db_commit_mgr_harden'',
                                    ''recovery_unit_harden_log_timestamps'',
                                    ''hadr_capture_vlfheader'',
                                    ''hadr_log_block_decompression'',
                                    ''hadr_apply_log_block'',
                                    ''hadr_send_harden_lsn_message'',
                                    ''hadr_log_block_decompression'',
                                    ''hadr_lsn_send_complete'',
                                    ''hadr_transport_receive_log_block_message'')
    
                    ) xe

                    IF OBJECT_ID(''DMReplicaEvents'') IS NOT NULL
                    BEGIN
                        DROP TABLE DMReplicaEvents
                    END 

                    SET ANSI_NULLS ON

                    SET QUOTED_IDENTIFIER ON

                    CREATE TABLE DMReplicaEvents(
                        [server_name] [NVARCHAR](128) NULL,
                        [event_name] [NVARCHAR](60) NOT NULL,
                        [log_block_id] [BIGINT] NULL,
                        [database_id] [INT] NULL,
                        [processing_time] [BIGINT] NULL,
                        [start_timestamp] [BIGINT] NULL,
                        [publish_timestamp] [DATETIMEOFFSET] NULL,
                        [log_block_size] [BIGINT] NULL,
                        [target_availability_replica_id] [UNIQUEIDENTIFIER] NULL,
                        [local_availability_replica_id] [UNIQUEIDENTIFIER] NULL,
                        [database_replica_id] [UNIQUEIDENTIFIER] NULL,
                        [mode] [BIGINT] NULL,
                        [availability_group_id] [UNIQUEIDENTIFIER] NULL,
                        [pending_writes]  [BIGINT] NULL
                    )

                    IF OBJECT_ID(''LatencyResults'') IS NOT NULL
                    BEGIN
                        DROP TABLE LatencyResults
                    END 
                    CREATE TABLE LatencyResults(
                       [event_name] [NVARCHAR](60) NOT NULL,
                       [processing_time] [BIGINT] NULL,
                       [publish_timestamp] [DATETIMEOFFSET] NULL,
                       [server_commit_mode] [NVARCHAR](60) NULL
                    )


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        NULL AS database_id,
                        AoData.value(''(data[@name="total_processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 75, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        AoData.value(''(data[@name="log_block_size"]/value)[1]'', ''BIGINT'') AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_log_block_send_complete''

                    GO


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''INT'') AS database_id,
                        AoData.value(''(data[@name="duration"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 65, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        AoData.value(''(data[@name="pending_writes"]/value)[1]'',''BIGINT'') AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''log_flush_complete''

                    GO

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        NULL AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="time_to_commit"]/value)[1]'', ''BIGINT'') AS processing_time,
                        NULL AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 72, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        AoData.value(''(data[@name="replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        AoData.value(''(data[@name="ag_database_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS database_replica_id,
                        NULL AS mode,
                        AoData.value(''(data[@name="group_id"]/value)[1]'',''UNIQUEIDENTIFIER'') AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_db_commit_mgr_harden''

                    GO


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 82, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''recovery_unit_harden_log_timestamps''

                    GO

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 73, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        AoData.value(''(data[@name="uncompressed_size"]/value)[1]'', ''INT'') AS log_block_size,
                        AoData.value(''(data[@name="availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_log_block_compression''

                    GO


                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        AoData.value(''(data[@name="database_id"]/value)[1]'', ''BIGINT'') AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 75, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        AoData.value(''(data[@name="uncompressed_size"]/value)[1]'', ''BIGINT'') AS log_block_size,
                        AoData.value(''(data[@name="availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_log_block_decompression''

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        NULL AS database_id,
                        AoData.value(''(data[@name="total_sending_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 69, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        NULL AS target_availability_replica_id,
                        NULL AS local_availability_replica_id,
                        NULL AS database_replica_id,
                        NULL AS mode,
                        NULL AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_lsn_send_complete''

                    INSERT INTO DMReplicaEvents
                    SELECT 
                        @@SERVERNAME AS server_name,
                        xe.event_name,
                        AoData.value(''(data[@name="log_block_id"]/value)[1]'', ''BIGINT'') AS log_block_id,
                        NULL AS database_id,
                        AoData.value(''(data[@name="processing_time"]/value)[1]'', ''BIGINT'') AS processing_time,
                        AoData.value(''(data[@name="start_timestamp"]/value)[1]'', ''BIGINT'') AS start_timestamp,
                        CAST(SUBSTRING(CAST(xe.event_data AS NVARCHAR(MAX)), 87, 24) AS DATETIMEOFFSET) AS publish_timestamp,
                        NULL AS log_block_size,
                        AoData.value(''(data[@name="target_availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS target_availability_replica_id,
                        AoData.value(''(data[@name="local_availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS local_availability_replica_id,
                        AoData.value(''(data[@name="target_availability_replica_id"]/value)[1]'', ''UNIQUEIDENTIFIER'') AS database_replica_id,
                        AoData.value(''(data[@name="mode"]/value)[1]'', ''BIGINT'') AS mode,
                        AoData.value(''(data[@name="availability_group_id"]/value)[1]'',''UNIQUEIDENTIFIER'') AS availability_group_id,
                        NULL AS pending_writes
                    FROM #EventXml AS xe
                    CROSS APPLY xe.event_data.nodes(''/event'')  AS T(AoData)
                    WHERE xe.event_name = ''hadr_transport_receive_log_block_message''


                    DELETE
                    FROM DMReplicaEvents
                    WHERE CAST(publish_timestamp AS DATETIME) < DATEADD(minute, -2, CAST((SELECT MAX(publish_timestamp) from DMReplicaEvents) as DATETIME))
                    COMMIT
                    GO', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Result Set]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Result Set', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
                    BEGIN TRANSACTION
                    USE tempdb
                    declare @ag_id as nvarchar(60) 
                    declare @event as nvarchar(60) 
                    set @ag_id = (select group_id from  sys.availability_groups_cluster where name = N''AGEKHO1'')
                    IF OBJECT_ID(''DbIdTable'') IS NOT NULL
                    BEGIN
                        DROP TABLE DbIdTable
                    END 
                    CREATE TABLE DbIdTable(
                        [database_id] [INT] NULL
                    )

                    INSERT INTO DbIdTable
                    select distinct database_id  from sys.dm_hadr_database_replica_states where group_id=@ag_id 

                    delete from tempdb.dbo.DMReplicaEvents where not (availability_group_id = @ag_id or availability_group_id is NULL) 

                    delete from tempdb.dbo.DMReplicaEvents where not (database_id in (select database_id from DbIdTable) or database_id is NULL)

                    set @event = ''availability_mode_desc''
                    INSERT INTO LatencyResults
                    select @event, NULL as processing_time, NULL as publish_timestamp, availability_mode_desc as server_commit_mode from sys.availability_replicas  A
                    inner join 
                    (select * from sys.dm_hadr_availability_replica_states) B
                    on A.replica_id = B.replica_id and A.group_id = @ag_id and A.replica_server_name = @@SERVERNAME

                    set @event = ''start_time''
                    INSERT INTO LatencyResults
                    select @event as event_name, NULL as processing_time, min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents

                    set @event = ''recovery_unit_harden_log_timestamps''
                    INSERT INTO LatencyResults
                    select @event, avg(processing_time), min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from DMReplicaEvents where event_name=''recovery_unit_harden_log_timestamps'' GROUP BY DATEPART(YEAR, publish_timestamp), DATEPART(MONTH, publish_timestamp), DATEPART(DAY, publish_timestamp), DATEPART(HOUR, publish_timestamp), DATEPART(MINUTE, publish_timestamp), DATEPART(SECOND, publish_timestamp) 

                    set @event = ''avg_recovery_unit_harden_log_timestamps''
                    INSERT INTO LatencyResults
                    select @event as event_name,AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''recovery_unit_harden_log_timestamps'' 

                    set @event = ''hadr_db_commit_mgr_harden''
                    INSERT INTO LatencyResults
                    select @event, avg(processing_time), min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from DMReplicaEvents where event_name=''hadr_db_commit_mgr_harden'' GROUP BY DATEPART(YEAR, publish_timestamp), DATEPART(MONTH, publish_timestamp), DATEPART(DAY, publish_timestamp), DATEPART(HOUR, publish_timestamp), DATEPART(MINUTE, publish_timestamp), DATEPART(SECOND, publish_timestamp)

                    set @event = ''avg_hadr_db_commit_mgr_harden''
                    INSERT INTO LatencyResults
                    SELECT @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_db_commit_mgr_harden''

                    set @event = ''avg_hadr_log_block_send_complete''
                    INSERT INTO LatencyResults
                    SELECT @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode FROM tempdb.dbo.DMReplicaEvents WHERE event_name = ''hadr_log_block_send_complete''

                    set @event = ''avg_hadr_log_block_compression''
                    INSERT INTO LatencyResults
                    SELECT @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_log_block_compression''

                    set @event = ''avg_hadr_log_block_decompression''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_log_block_decompression''

                    set @event = ''hadr_lsn_send_complete''
                    INSERT INTO LatencyResults
                    select @event, avg(processing_time), min(publish_timestamp) as publish_timestamp, NULL as server_commit_mode from DMReplicaEvents where event_name=''hadr_lsn_send_complete'' GROUP BY DATEPART(YEAR, publish_timestamp), DATEPART(MONTH, publish_timestamp), DATEPART(DAY, publish_timestamp), DATEPART(HOUR, publish_timestamp), DATEPART(MINUTE, publish_timestamp), DATEPART(SECOND, publish_timestamp) 

                    set @event = ''avg_hadr_lsn_send_complete''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_lsn_send_complete''

                    set @event = ''avg_hadr_transport_receive_log_block_message''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''hadr_transport_receive_log_block_message''


                    set @event = ''avg_log_flush_complete''
                    INSERT INTO LatencyResults
                    select @event as event_name, AVG(processing_time*1000) as processing_time, NULL as publish_timestamp, NULL as server_commit_mode from tempdb.dbo.DMReplicaEvents where event_name=''log_flush_complete''
                    COMMIT

            ', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop XE Session]    Script Date: 2019-10-10 16:14:22 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop XE Session', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DROP EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER
                                                            UPDATE tempdb.dbo.LatencyCollectionStatus set collection_status =''Completed''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

