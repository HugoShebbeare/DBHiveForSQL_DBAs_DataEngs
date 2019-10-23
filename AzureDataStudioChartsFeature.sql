Writing scripts to display performance data
To view a graph of the counter you chose to record and display how it varies over time, you must query the temporary global table you have created, as in the following code:

SQL

Copy
SELECT top 70 counter_name, [retrieval_time],
    CASE WHEN LAG(cntr_value,1) OVER (ORDER BY [retrieval_time]) IS NULL THEN  
        cntr_value-cntr_value
        ELSE cntr_value - LAG(cntr_value,1) OVER (ORDER BY [retrieval_time]) END AS cntr_value
FROM ##tblPerfCount
ORDER BY [retrieval_time] DESC
GO
When you run such a query in Azure Data Studio, you can use the Chart Viewer to display a time series graph. The chart will show how the counter varies over time.