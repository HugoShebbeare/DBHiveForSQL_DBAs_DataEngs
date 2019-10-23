
GO

/****** Object:  Table [dbo].[SQLServerInfo]    Script Date: 10/24/2017 3:55:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLServerInfoExtended]
([ServerName] NVARCHAR(80) NULL,
	[InstanceName] NVARCHAR(80) null, 
		-- just in case it's different, or multiple instances are on the same server
	[Version] [nvarchar](128) NULL,
	[ProdLevel] [nvarchar](128) NULL,
	[Edition] [nvarchar](128) NULL,
	[cpu_count] [smallint] NOT NULL,
	[hyperthread_ratio] [smallint] NOT NULL,
	   [IntegratedSecurity] SMALLINT null,
	   [DataDirectory] SMALLINT null,
--	   SERVERPROPERTY('InstanceDefaultDataPath') AS [InstanceDefaultDataPath],
--SERVERPROPERTY('InstanceDefaultLogPath') AS [InstanceDefaultLogPath],
	   [HADR ENabled] SMALLINT null,
--SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus],
	[max server memory (MB)] int NULL,
	[optimize for ad hoc workloads] bit NULL,
	[fill factor (%)] [smallint] NULL,
	[max degree of parallelism] smallint NULL,
	[cost threshold for parallelism] smallint NULL,
	[Is CLR Enabled] SMALLINT NULL,
	--SERVERPROPERTY('BuildClrVersion') AS [Build CLR Version],
	[Blocked Process Threshold] SMALLINT null,
	[Is xp_cmdshell Enabled] SMALLINT null,
	-- stuff from here on useful for security evaluations/scores - proof that we pass some CIS,NIST,STIGs
	[Ad Hoc Distributed Queries] SMALLINT null,
	[Ole Automation Procedures] SMALLINT null,
	[SMO and DMO XPs] SMALLINT null,
	[Agent XPs] SMALLINT null,
    [Remote Admin Connections] SMALLINT null,
	[Common Criteria Compliance Enabled] SMALLINT null,
	[Scan for Startup Procs] SMALLINT null,
	[Maximum Worker Threads] SMALLINT null,
	[cross db ownership chaining] SMALLINT null,
	[Allow Updates to SYS TBLs] SMALLINT null,
	[date_in] [datetime] NOT NULL
) ON [PRIMARY]
GO

-- add any of these?


-- Get selected server properties (Query 3) (Server Properties)
SELECT SERVERPROPERTY('MachineName') AS [MachineName], 
SERVERPROPERTY('ServerName') AS [ServerName],  
SERVERPROPERTY('InstanceName') AS [Instance], 
SERVERPROPERTY('IsClustered') AS [IsClustered], 
SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
SERVERPROPERTY('Edition') AS [Edition], 
SERVERPROPERTY('ProductLevel') AS [ProductLevel],				-- What servicing branch (RTM/SP/CU)
SERVERPROPERTY('ProductUpdateLevel') AS [ProductUpdateLevel],	-- Within a servicing branch, what CU# is applied
SERVERPROPERTY('ProductVersion') AS [ProductVersion],
SERVERPROPERTY('ProductMajorVersion') AS [ProductMajorVersion], 
SERVERPROPERTY('ProductMinorVersion') AS [ProductMinorVersion], 
SERVERPROPERTY('ProductBuild') AS [ProductBuild], 
SERVERPROPERTY('ProductBuildType') AS [ProductBuildType],			  -- Is this a GDR or OD hotfix (NULL if on a CU build)
SERVERPROPERTY('ProductUpdateReference') AS [ProductUpdateReference], -- KB article number that is applicable for this build
