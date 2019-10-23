-- general server stats for database breakdown perf use
SELECT * FROM sys.dm_os_performance_counters
ORDER BY cntr_value DESC
--- totals only
SELECT * FROM sys.dm_os_performance_counters
WHERE instance_name ='_Total'
ORDER BY cntr_value DESC
--only transactions / sec
SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name LIKE 'trans%'
ORDER BY cntr_value DESC

-- 1,346,132,728
-- 113,391,311
--122,863,865
--1,126,199,415