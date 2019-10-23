/*  --------------------------------------------------------------------------	*/
/*				RUN as TEXT, IN SSMS, use Control-T																*/
/*  ======= CHECK THE READINESS OF A SQL SERVER INSTANCE FOR PATCHING =======	*/
/*																				*/
/*  By Frank Xue, on July 09, 2015	                                            */
/*																				*/
/*  Version 2 on July 14, 2015: to handle next_run_date =0 fopr some jobs	    */
/*																				*/
/*	Version 2.6 on July 15, 2015: Add xp_regread to list default DB locations.	*/
/*																				*/
/*	v.3 Hugo S., adjusted to Alithya 2018, added backup location, refactored	*/
/*				added productversion instead of level to get exact build        */
/*  --------------------------------------------------------------------------	*/
/*  It checks 6 aspects of an instance:											
		1) The SQL Server version and its current product level
		2) The default locations of database files (data files, log files and backup)
		3) All databases in full server mode (online, multi-user and read-write)
		4) Recent backups for both system databases and users databases
		5) If any SQL Server Agent jobs scheduled for the next few hours
		6) If any exceptions in the error log.
	-- for consolidation work a sheet with a column explaining each component installed, multiple instance per server 
	-- and then what to do with them (consolidate? request decom, uninstall - procedure)
*/

-- !!!!!!!!!!! Please Specify the New SP Level to @NewSP !!!!!!!!!!! --


USE master
GO

-- Declare All Variables
DECLARE @NewSP varchar(25) 
SET @NewSP = 'SQL Server 2017 (RTM-CU8)' --<===== Supply the latest-desired build level here, say 'SQL Server 2017 (RTM-CU8)'
DECLARE @MajorLine varchar(100)
DECLARE @MinorLine varchar(100)
DECLARE @SectLine varchar(45)
DECLARE @SVRName varchar(30)
DECLARE @Version varchar(150)
DECLARE @DBStatus TABLE
(
    DBName VARCHAR(128) NOT NULL,
    Issue VARCHAR(50) NOT NULL
)
DECLARE @DBBackup TABLE
(
    DBName VARCHAR(128) NOT NULL,
    BackupType VARCHAR(5) NOT NULL,
    LastBackup DATETIME NOT NULL
)
DECLARE @ERRLog TABLE
(
    LogTime DATETIME NOT NULL,
    ProcInfo VARCHAR(100) NOT NULL,
    ErrorMsg VARCHAR(2000) NOT NULL
)
DECLARE @JobNextRun TABLE
(
    JobName VARCHAR(200) NOT NULL,
    SchdDate VARCHAR(10) NOT NULL,
    SchdTime VARCHAR(8) NOT NULL
)
DECLARE @BckpInterval int 
SET @BckpInterval = 24		--<===== Number of hours a backup before patching considered valid. Default 6 hours
DECLARE @IgnoreErrLog int
SET @IgnoreErrLog = 0				--<===== Default to check SQL Server error log. Set IT to 1 to skip the check!!!
DECLARE @ErrorLogHistory int
SET @ErrorLogHistory = 7			--<===== Days of error to check back. Default 7 days.
DECLARE @JobsNextRun int
SET @JobsNextRun = 4					--<===== Number of hours to the next run of any job. Default 4 (Window is 2-6am  
DECLARE @Msg varchar(500)
DECLARE @ErrMsg varchar(MAX)
DECLARE @TotalError int
DECLARE @Threshold int
DECLARE @BackupFileLocation VARCHAR(150)

SET NOCOUNT ON

-- !!!!! Please Supply the new SP level here to @NewSP --



SELECT @Threshold = 0, @SVRName  =@@servername, @Msg = char(9) + 'Readiness Check for Installing ' + @NewSP + ' on Instance ' + @@servername

-- Create Report Header
SELECT	@MajorLine = REPLICATE ('=',90), 
		@MinorLine = REPLICATE ('-',90),
		@SectLine  = REPLICATE ('-',45)
PRINT @MajorLine
PRINT @Msg
PRINT @MinorLine
PRINT ''
PRINT ' 1. Current Product Level: '
PRINT @SectLine

-- Part I  Check SQL Server Version & Current Product Level
SELECT @Version = SUBSTRING(@@version, 11, 35) + ' ' + CONVERT(VARCHAR(25), SERVERPROPERTY('productversion')) 
					+ ' ' + CONVERT(VARCHAR(30), SERVERPROPERTY('Edition'));
IF SUBSTRING(LTRIM(RTRIM(@NewSP)),1,25) = @Version  -- we are only matching first 25 characters...not perfect!
	BEGIN
		SELECT @Msg = char(9) + @version + char(13)
		PRINT  @Msg
		SELECT @Threshold = @Threshold + 1
		PRINT ''
		SELECT @ErrMsg = char(9) + 'No Patching Needed!!! Instance ' + @@SERVERNAME + ' is at the same product level.'
		RAISERROR (@ErrMsg, 16, 1)
		PRINT ''
		-- GOTO FINAL
	END
ELSE 
	BEGIN
		SELECT @Msg = char(9) + 'Current version =' + @version + char(13) + char(9) + 'To Be Installed =' + @NewSP + char(13)
		PRINT  @Msg
	END

-- Part II Check default locations of database files (data and log files)

PRINT ' 2. Default Locations of Databases: '
PRINT @SectLine;
--IF SELECT SERVERPROPERTY('ProductMajorVersion') !=(11)
	 EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', 
		-- watch out for other locations, often you have to check the registry
		--\Microsoft\Microsoft SQL Server\MSSQL14.SQL2017\MSSQLServer
								 N'BackupDirectory', 
								 @BackupFileLocation OUTPUT;
--ELSE  PRINT 'This version of sql does not backups from the registry or server property'

PRINT 'The default path for the database instance Data files is: '
SELECT	SERVERPROPERTY('InstanceDefaultDataPath')  

SELECT	@BackupFileLocation = CHAR(9) + 'The default path for DB Backups is (if found): ' +  @BackupFileLocation + '\' + CHAR(13)

PRINT @BackupFileLocation
PRINT 'The default path for the database instance Log files is:'
SELECT SERVERPROPERTY('InstanceDefaultLogPath')

-- Part III Check All Database Status

PRINT ' 3. Database Status: '
PRINT @SectLine
INSERT INTO @dbstatus 
	SELECT name, CASE 
		WHEN state > 0 THEN 'Not Online' 
		WHEN is_read_only=1 then 'Read_Only' 
		when user_access > 0 then 'Not Multi-User' 
		end AS Status
	from sys.databases
	where state>0 or is_read_only=1 or user_access >0

IF EXISTS (SELECT * FROM @DBStatus)
	BEGIN
		SELECT @ErrMsg = char(9) + 'Following Databases Are Not ready for Patchiing: ' + char(13) 
		SELECT @ErrMsg = @ErrMsg + char(9) + DBName + ': ' + replicate ('.', 40 -(len (DBName) + len (issue))) + issue + char(13)
			FROM @DBStatus
		PRINT @ErrMsg
		SET @Threshold = @Threshold + 1
		SELECT @ErrMsg = char(9) + 'Some databases are not ready for patching! Stop to verify the databases listed above!'
		RAISERROR (@ErrMsg, 16, 1)
		PRINT ''
		-- GOTO FINAL
	END
ELSE
	BEGIN
		SELECT @Msg = char(9) + 'All Databases Are Ready For Patching' + char(13)
		PRINT @Msg
	END

-- Part IV Check Recent DB Backups

PRINT ' 4. Recent DB Backups: '
PRINT @SectLine 
INSERT INTO @DBBackup
	SELECT d.name, '', max( ISNULL( b.backup_finish_date, '2001-01-01' ))
		FROM master.sys.databases d LEFT JOIN MSDB.dbo.backupset b on d.name=b.database_name 
		WHERE d.name <>'tempdb'
		GROUP BY  d.name

	UPDATE @DBBackup SET BackupType = b.type
		FROM @DBBackup t JOIN msdb.dbo.backupset b ON t.DBName = b.database_name and t.LastBackup = ISNULL( b.backup_finish_date, '2001-01-01' )

	UPDATE @DBBackup SET LastBackup = CONVERT (DATETIME, '2001-01-01', 120), BackupType = 'NON'
		WHERE BackupType IS NULL

IF EXISTS (SELECT * FROM @DBBackup WHERE DATEDIFF (hh, LastBackup, getdate()) >= @BckpInterval )  
							-- Assuming that an ad hoc backup run by DBA in the past 6 hours before patching starts.
	BEGIN
		SELECT @Msg = char(9) + 'The Following Database(s) Backups are more than ' + CONVERT (varchar(3), @BckpInterval) + ' hours old: ' + char(13) 
		SELECT @Msg = @Msg + char(9) + DBName + ' has a ' + CASE BackupType WHEN 'D' THEN 'Full' WHEN 'I' THEN 'DIFF' WHEN 'L' THEN 'LOG' ELSE 'Unknown' END  + ' backup from '
						 + CONVERT(VARCHAR(20), LastBackup, 120) + char(13) 
			FROM @DBBackup
				WHERE DATEDIFF (hh, LastBackup, getdate()) >= @BckpInterval
		PRINT @Msg
		SET @Threshold = @Threshold + 1
		SELECT @ErrMsg = char(9) + 'Databases listed above need recent backups (use maint plan, or deploy Hellengren: DatabaseBackup, CommandExecute) '
		RAISERROR (@ErrMsg, 16, 1)
		PRINT ''

	END
ELSE 
	BEGIN
		SELECT @Msg = char(9) + 'All Databases have been recent backups, thus ready for Patching' + char(13)
		PRINT @Msg
	END

-- Part V Check Current Error Log
PRINT ' 5. SQL Server Error Log Check (xp_readerrorlog): '
PRINT @SectLine 

INSERT INTO @ERRLog
	EXEC sys.xp_readerrorlog 0, 1, N'error'
	DELETE @ERRLog
		WHERE DATEDIFF (hh,LogTime, GETDATE()) > 24  -- Errors from 24 hours ago can be ignored
	SELECT @TotalError = COUNT(*) FROM @ERRLog
IF EXISTS (SELECT * FROM @ERRLog WHERE DATEDIFF (dd, LogTime, getdate()) <= @ErrorLogHistory AND @IgnoreErrLog =0) 
	BEGIN
		SET @Threshold = @Threshold + 1
		SELECT @ErrMsg = char(9) + CONVERT( varchar(5), @TotalError) + ' errors found in SQL Server error log, please investigate before patching.'
		RAISERROR (@ErrMsg, 16, 1)
		PRINT ''
		
		PRINT 'Server Instance Error Log Path is (if needed):'
		SELECT SERVERPROPERTY('ErrorLogFileName')
	END
ELSE 
	BEGIN
		SELECT @Msg = char(9) + 'SQL Server Error Log Checks out OK' + char(13) 
		PRINT @Msg
	END

-- Part VI Check Next Run Jobs
PRINT ' 6. SQL Server Agent jobs Next run: '
PRINT @SectLine
	;WITH CTE AS (
	SELECT schedule_id, 
			job_id, 
			RIGHT('0'+convert(varchar (6), next_run_time),6) AS next_run_time, 
			case next_run_date  when 0 then 20500101 end AS next_run_date
	FROM msdb..sysjobschedules
			)
INSERT INTO @JobNextRun
	SELECT j.name,
			convert(varchar(10), convert(datetime, convert(varchar(10),next_run_date)),120),
			SUBSTRING (RIGHT('00000'+ CONVERT(VARCHAR(6),next_run_time),6),1,2)
			+':'+SUBSTRING (RIGHT('00000'+ CONVERT(VARCHAR(6),next_run_time),6),3,2)
			+':'+SUBSTRING (RIGHT('00000'+ CONVERT(VARCHAR(6),next_run_time),6),5,2)
		FROM msdb..sysjobs j join CTE c on j.job_id = c.job_id
			WHERE 
			(convert(varchar(10), convert(datetime, convert(varchar(10),next_run_date)),120) + ' ' + 			
			SUBSTRING (RIGHT('00000'+ CONVERT(VARCHAR(6),next_run_time),6),1,2)
			+':'+SUBSTRING (RIGHT('00000'+ CONVERT(VARCHAR(6),next_run_time),6),3,2)
			+':'+SUBSTRING (RIGHT('00000'+ CONVERT(VARCHAR(6),next_run_time),6),5,2) ) > CONVERT (VARCHAR (20), GETDATE(), 120)

IF EXISTS (SELECT * FROM @JobNextRun WHERE DATEDIFF (hh,  GETDATE (), CONVERT( datetime, (SchdDate + ' ' + SchdTime))) <= @JobsNextRun )

	BEGIN
		DELETE @JobNextRun WHERE  DATEDIFF (hh,  GETDATE (), CONVERT( datetime, (SchdDate + ' ' + SchdTime))) > @JobsNextRun
		SET @Threshold = @Threshold + 1
		SET @Msg = ''
		SELECT @Msg = @Msg + char(9) + 'Job ' + JobName + ' will run today at ' + SchdTime + ' EST' + char(13)
			FROM @JobNextRun
				ORDER BY SchdTime DESC,  JobName
		PRINT @Msg
		SELECT @ErrMsg = char(9) + 'SQL Server Agent jobs that will run in over the next four hours'
		RAISERROR (@ErrMsg, 16, 1)
		PRINT ''
	END

ELSE 
	BEGIN
		SELECT @Msg = char(9) + 'No SQL Agent Job to run in ' + CONVERT (varchar(5), @JobsNextRun) + ' hours.' + char(13) 
		PRINT @Msg
	END

-- PART VII Wrap up the Report, with a final statement of either "Check Failed" or "Check Successful" 


IF @Threshold > 0
	BEGIN
		SELECT @Msg = char(9) + ' CHECK FAILED: INSTANCE ' + @@SERVERNAME + ' IS NOT READY FOR PATCHING to ' + @NewSP + ' :/' 
		PRINT @Msg
		PRINT @MajorLine
	END
ELSE
	BEGIN
		SELECT @Msg = char(9) + 'CHECK SUCCESSFUL: INSTANCE ' + @@SERVERNAME + ' IS READY FOR PATCH Level ' + @NewSP +' :)'
		PRINT @Msg
		PRINT @MajorLine
	END

SET NOCOUNT OFF;

