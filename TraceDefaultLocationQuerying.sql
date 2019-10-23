-- are they enabled? https://www.mytechmantra.com/LearnSQLServer/Different-Ways-to-Find-Default-Trace-Location-in-SQL-Server/
SELECT * FROM sys.configurations 
WHERE configuration_id = 1568
-- where are they now?
SELECT path FROM sys.traces 
-- get from trace issues
SELECT    *
FROM::fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\log_186.trc', 100)
--\\?\F:\MSSQL\Data\audittrace20170830150206_178.trc
    INNER JOIN sys.trace_events e
        ON eventclass = trace_event_id
    INNER JOIN sys.trace_categories AS cat
        ON e.category_id = cat.category_id
WHERE loginname like '%mywebgrocer%' 
--AND applicationname = 'Quick Reindex'
--e.name NOT like 'Audit Schema%'
--AND e.name NOT like 'Audit Statement%'
ORDER BY starttime DESC;

select * from sys.sysdatabases 
select getdate()