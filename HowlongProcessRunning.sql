--  how long till current operation done
SELECT R.session_id
	, R.percent_complete
	, R.total_elapsed_time/1000 AS elapsed_seconds
	, R.wait_type
	, R.wait_time
	, R.last_wait_type
	, DATEADD(s,100/((R.percent_complete)/ (R.total_elapsed_time/1000)), R.start_time) AS est_complete_time
	, ST.text AS batch_text
	, CAST(SUBSTRING(ST.text, R.statement_start_offset / 2, 
		(
			CASE WHEN R.statement_end_offset = -1 THEN DATALENGTH(ST.text)
			ELSE R.statement_end_offset
			END - R.statement_start_offset 
		) / 2 
	) AS varchar(1024)) AS statement_executing
FROM sys.dm_exec_requests AS R
	CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) AS ST
WHERE R.percent_complete > 0
	AND R.session_id <> @@spid;

--- all of them
select * from sys.dm_exec_requests
SELECT GETDATE()


-- Index rebuild progress
;WITH cte AS
(
SELECT
object_id,
index_id,
partition_number,
rows,
ROW_NUMBER() OVER(PARTITION BY object_id, index_id, partition_number ORDER BY partition_id) as rn
FROM sys.partitions
)
SELECT
   object_name(cur.object_id) as TableName,
   cur.index_id,
   cur.partition_number,
   PrecentDone =
      CASE
         WHEN pre.rows = 0 THEN 0
      ELSE
         ((cur.rows * 100.0) / pre.rows)
      END,
   pre.rows - cur.rows as MissingRows
FROM cte as cur
INNER JOIN cte as pre on (cur.object_id = pre.object_id) AND (cur.index_id = pre.index_id) AND (cur.partition_number = pre.partition_number) AND (cur.rn = pre.rn +1)
ORDER BY 4