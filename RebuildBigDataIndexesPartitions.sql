-- compress a table, after estimate provides it's worth of operation in the first place
USE [XArchive]
go
ALTER TABLE [dbo].[200BNrowTable] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE, online=on -- enterprise edition only 
)

-- recreate over an existing index
CREATE UNIQUE CLUSTERED INDEX [CLNS_X] ON [dbo].[300BNrowTable]
(
	[FILE_ID] ASC,
	[RECORD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, 
DROP_EXISTING = On, data_compression=page, ONLINE = on,-- line added when moving from one file group to another (instead of FG1, onto Primary
 ,FILLFACTOR = 95, --- important if correcting server level value that was incorrect already
 ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [primary]
GO

-- and then specific partitions
-- and largest history table all partitions (active rows)
ALTER INDEX [PK_BNRowTable] ON [dbo].[BNRowTable] 
REBUILD PARTITION = 2 -- script out all the partition numbers that need rebuilding
 WITH (SORT_IN_TEMPDB = on, maxdop=24, DATA_COMPRESSION = PAGE) -- max dop to make it quick
go
