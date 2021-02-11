USE [master]
GO

/****** Object:  Table [dbo].[DiskLatency]    Script Date: 10/22/2019 2:40:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DiskLatency](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Drive] [nvarchar](2) NOT NULL,
	[Volume Mount Point] [nvarchar](256) NOT NULL,
	[Read Latency] [bigint] NOT NULL,
	[Write Latency] [bigint] NOT NULL,
	[Overall Latency] [bigint] NOT NULL,
	[Avg Bytes/Read] [bigint] NOT NULL,
	[Avg Bytes/Write] [bigint] NULL,
	[Avg Bytes/Transfer] [bigint] NULL,
	[InsertDate] [date] NULL,
 CONSTRAINT [PK_DiskLatency] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DiskLatency] ADD  CONSTRAINT [DF_DiskLatency_InsertDate]  DEFAULT (getdate()) FOR [InsertDate]
GO



set IDENTITY_INSERT [dbo].[DiskLatency] ON
INSERT INTO [dbo].[DiskLatency]
           ([Drive]
           ,[Volume Mount Point]
           ,[Read Latency]
           ,[Write Latency]
           ,[Overall Latency]
           ,[Avg Bytes/Read]
           ,[Avg Bytes/Write]
           ,[Avg Bytes/Transfer]) --- collection 
-- Drive level latency information (Query 27) (Drive Level Latency)
-- Based on code from Jimmy May
SELECT tab.[Drive], tab.volume_mount_point AS [Volume Mount Point], 
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) 
	END AS [Read Latency],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
	END AS [Write Latency],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE (io_stall/(num_of_reads + num_of_writes)) 
	END AS [Overall Latency],
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (num_of_bytes_read/num_of_reads) 
	END AS [Avg Bytes/Read],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (num_of_bytes_written/num_of_writes) 
	END AS [Avg Bytes/Write],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
	END AS [Avg Bytes/Transfer]
--	into DiskLatency
FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
	         SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
	         SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
	         SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.volume_mount_point 
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
	  CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs 
      GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.volume_mount_point) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);
go
set IDENTITY_INSERT [dbo].[DiskLatency] OFF


---- just files  https://www.mssqltips.com/sqlservertip/6125/disk-latency-for-sql-server-database-and-transaction-log-files/
   SELECT TOP (10) DB_NAME (a.database_id) AS dbname,
      a.io_stall / NULLIF (a.num_of_reads + a.num_of_writes, 0) AS average_tot_latency,
      Round ((a.size_on_disk_bytes / square (1024.0)), 1) AS size_mb,
      b.physical_name AS [fileName]
   FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS a,
      sys.master_files AS b
   WHERE a.database_id = b.database_id
      AND a.FILE_ID = b.FILE_ID
   ORDER BY average_tot_latency DESC
