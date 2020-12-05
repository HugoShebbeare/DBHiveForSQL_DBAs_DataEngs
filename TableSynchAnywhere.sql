SE [M3EDBPRD]
GO

/****** Object:  Table [dbo].[Discrepancy]    Script Date: 12/05/2020 15:56:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Discrepancy](
	[PK] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[Rowcount] [int] NULL,
	[dtstamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[PK] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [TMVXRUNT]
) ON [TMVXRUNT]

GO

ALTER TABLE [dbo].[Discrepancy] ADD  DEFAULT (getdate()) FOR [dtstamp]
GO



CREATE proc generateSQLNew(@tableName sysname)
as
--declare @tableName sysname='MVXJDTA.CTAXLN'
declare @sql varchar(max)='
IF EXISTS(
SELECT @columns  FROM @tableName (NOLOCK)
EXCEPT
SELECT  @columns FROM [VM-DEV-SQL].M3EDBTSP.@tableName 
) 
INSERT INTO Discrepancy(SchemaName, TableName, [Rowcount]) values( ''MVXJDTA'',''@tableName'',@@ROWCOUNT)
GO
'
declare @timecolumn sysname
select @timecolumn = max(name) from syscolumns where id=object_id(@tableName) and name like '%MDT'
if @timecolumn  is null
select @timecolumn = max(name) from syscolumns where id=object_id(@tableName) and name like '%GDT'
if @timecolumn  is not null
select @sql ='
IF EXISTS(
SELECT @columns  FROM @tableName (NOLOCK)
WHERE @timecolumn > REPLACE(CONVERT(date,dateadd(dd,-14,GETDATE())),''-'','''' )
EXCEPT
SELECT  @columns FROM [VM-DEV-SQL].M3EDBTSP.@tableName 
WHERE @timecolumn > REPLACE(CONVERT(date,dateadd(dd,-14,GETDATE())),''-'','''' )
) 
INSERT INTO Discrepancy(SchemaName, TableName, [Rowcount]) values( ''MVXJDTA'',''@tableName'',@@ROWCOUNT)
GO
'
 
declare @newSQL varchar(max)
declare @newSQL1 varchar(max)
declare @columns varchar(max)=''
select @columns =@columns +name + case when collationid!= 0  then ' collate Latin1_General_BIN ' else '' end+', 'from syscolumns where id=object_id(@tableName)
select @columns=SUBSTRING(@columns, 1, len(@columns)-1)
select @newSQL=REPLACE(@sql,'@tableName',@tableName)
select @newSQL=REPLACE(@newSQL,'@columns',@columns)
if @timecolumn is not null
select @newSQL=REPLACE(@newSQL,'@timecolumn',@timecolumn)
select @newSQL