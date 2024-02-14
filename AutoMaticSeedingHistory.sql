-- automatic seeding history
select * 
from sys.dm_hadr_automatic_seeding
order by start_time desc
--  DBCC TRACESTATUS(9567)  
-- for replicas on slow connection
/*
Dbcc traceon(9567)
--	Enables compression of the data stream for Always On Availability Groups during automatic seeding. Compression can significantly reduce the transfer time during automatic seeding, and increases the load on the processor.
*/

select * 
from sys.dm_hadr_physical_seeding_stats
order by start_time_utc desc, local_database_name

---- sagar mulukanoori's better version :)
select local_database_name
, remote_machine_name,role_desc ,internal_state_desc 
,transfer_rate_bytes_per_second/1024/1024 as transfer_rate_MB_per_second ,transferred_size_bytes/1024/1024/1024 as transferred_size_GB
,database_size_bytes/1024/1024/1024 as Database_Size_GB,
is_compression_enabled     from sys.dm_hadr_physical_seeding_stats

 SELECT start_time, ag.name, db.database_name, current_state, performed_seeding, failure_state, failure_state_desc
 FROM sys.dm_hadr_automatic_seeding autos 
    JOIN sys.availability_databases_cluster db ON autos.ag_db_id = db.group_database_id
    JOIN sys.availability_groups ag ON autos.ag_id = ag.group_id
Order by start_time desc

SELECT r.command, r.wait_type, r.wait_resource, DB_NAME(tl.resource_database_id) as [database_name], tl.resource_type,
    tl.resource_subtype, tl.request_mode, tl.request_type, tl.request_status,  r.session_id as blocked_session_id,
    r.blocking_session_id
FROM sys.dm_tran_locks as tl
join sys.dm_exec_requests as r on tl.request_session_id = r.session_id
--WHERE tl.request_session_id = <concern
