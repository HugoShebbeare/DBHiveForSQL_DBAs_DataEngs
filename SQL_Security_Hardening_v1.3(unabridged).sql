/* ------------------------------------------------------------------------------------------------ */
/*                                                                                                  */
/*  SQL Server Hardening Scripts                                                               */
/*                                                                                                  */
/*  By Frank Xue, Frank Yoon, Hugo Shebbeare, Stacey V Murphy                                         */
/*																    */
/*  Version 1.1		-- August 14, 2015										*/
/*  Version	1.15	-- September 1, 2015. Remove ml\Entegra and gcosi\dmspbdb					*/
/*                                                                                                  */
/*  Version	1.20	-- Remove CA\SQLSrvrca		October 15, 2015                                    */
/*                                                                                                  */
/*  Version 1.21  -- Danny M. Replace Public to Revoke Public. And drop "gcosi\dmssqlsrvr"          */
/*  Version 1.26  -- Hugo S./Stacey V M. DENY CONTROL to REVOKE Control in sys dbs. SQL 2014 Ready  */
/*	------------------------------ Part I:  Server Level --------------------------------------	*/
 
-- 0.50 - prerequisites for hardening
-- only disable and rename SA for instances not involved with Replication (most aren't)

DECLARE @SYSType VARCHAR (10) --<===== Please sepcify the system type, Prod or NoneProd
SELECT @SYSType = 'PROD' 

DECLARE @RoleMember int 
DECLARE @Instance varchar (50)
DECLARE	@Agent varchar(50)
DECLARE @CMD varchar(7000)
DECLARE	@MajorSec varchar(80)
DECLARE @MinorSec varchar (80)
DECLARE @Len int

SELECT	@Len = (80 -len ('Hardening ' + @@SERVERNAME  + ' on ' +  Convert(varchar(10), GETDATE(), 110))) /2
SELECT	@MajorSec = REPLICATE ('=', @Len ) + ' Hardening ' + @@SERVERNAME + ' on ' + Convert(varchar(10), GETDATE(),110) + ' ' + REPLICATE ('=', @Len ) 
SELECT	@MinorSec = REPLICATE ('-', 80) 
PRINT	@MajorSec + CHAR(13)

SELECT  @RoleMember = 0

-- 1 Tighten Sysadmin members

USE master

PRINT 'I-1. Tighten Default Sysadmin Users'
PRINT 'Hardening Guide - 5.1- Validating and Disabling Guest and SA Accounts'
PRINT @MinorSec

-- 1.1 Rename and disable login "sa" -- Hardening Guide - 5.1, 7.1

IF EXISTS (SELECT * FROM sys.server_principals WHERE name= 'sa')
	BEGIN
		ALTER LOGIN [sa] WITH NAME = [Watermelon] -- Rename sa into Watermelon
		ALTER SERVER ROLE [sysadmin] DROP MEMBER [Watermelon]
		PRINT 'Login "sa" Is Renamed and Disabled AND REMOVED FROM SYSADMIN'  -- added sysadmin membership removal Feb '16
		PRINT ''
	END
	

---- 1.2 Downgrade built-in service accounts NT SERVICE\MSSQL$INSTANCE and NT SERVICE\AGENT$INSTANCE

IF EXISTS (SELECT * FROM sys.server_principals l join sys.server_role_members srm on l.principal_id=srm.member_principal_id 
				join sys.server_principals s on s.principal_id=srm.role_principal_id
				WHERE l.name like 'NT SERVICE\MSSQL%' and s.name = 'sysadmin') 
		SET @RoleMember = 1

IF EXISTS (SELECT * FROM sys.server_principals l join sys.server_role_members srm on l.principal_id=srm.member_principal_id 
				join sys.server_principals s on s.principal_id=srm.role_principal_id
				WHERE l.name like 'NT SERVICE\SQLAgent%' and s.name = 'sysadmin') 
		SET @RoleMember = @RoleMember + 2

IF @RoleMember > 0
	BEGIN
		SELECT @Instance = CONVERT(varchar(20), SERVERPROPERTY('instancename'))
		IF @Instance is not null
			SELECT @Agent = 'NT SERVICE\SQLAgent$' + @Instance, 
					@Instance= 'NT SERVICE\MSSQL$' + @Instance	
		ELSE 
			SELECT @Instance= 'NT SERVICE\MSSQLServer' , 
					@Agent = 'NT SERVICE\SQLAgent'

		IF @RoleMember in (1,3)
			BEGIN
				SELECT @CMD = 'ALTER SERVER ROLE [sysadmin] DROP MEMBER [' + @Instance + ']'
				EXEC (@CMD)
				--PRINT @Instance + ' virtual service account Downgraded!'
			END
		IF @RoleMember in (2,3)
			BEGIN
				SELECT @CMD = 'ALTER SERVER ROLE [sysadmin] DROP MEMBER [' + @Agent + ']'
				EXEC (@Cmd) 
				PRINT @Agent + ' virtual service account Downgraded!'
			END
		PRINT ''
	END
-- other defaults not necessary in sysadmin.
ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\SQLWriter]
ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\Winmgmt]
-- 2 Create security principals, and add role members

PRINT 'I-2: Create Security Principals'
PRINT @MinorSec

-- 2.1 Create [NT SERVICE\Winmgmt]Server Role "Monitoring"

IF EXISTS (select * FROM SYS.SERVER_PRINCIPALS WHERE name = 'Monitoring')
	BEGIN																	--Archive the Monitoring role members if any
		DECLARE @MonitorMembers table (RoleName varchar (10), LoginName varchar(40))
		INSERT INTO @MonitorMembers 
			SELECT r.name, l.name
			FROM sys.server_principals l join sys.server_role_members srm on l.principal_id=srm.member_principal_id 
					join sys.server_principals r on r.principal_id=srm.role_principal_id
			WHERE r.name='Monitoring'
		IF EXISTS (SELECT * FROM @MonitorMembers)
			BEGIN
				SET @CMD = ''
				SELECT @CMD = @CMD + 'ALTER SERVER ROLE Monitoring DROP MEMBER [' + LoginName + '];' + CHAR(13)
					FROM @MonitorMembers
				EXEC (@CMD)
			END
		DROP SERVER ROLE Monitoring
	END
CREATE SERVER ROLE Monitoring Authorization sysadmin
PRINT 'SERVER ROLE Monitoring Created.'

-- 2.2 Create Logins as Members of Role "Monitoring" 

IF @SYSType = 'PROD' AND NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\DMSStatsCollector')
	CREATE LOGIN [gcosi\DMSStatsCollector] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
IF @SYSType <> 'PROD' AND NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\DMSnpStatsCollector')
	CREATE LOGIN [gcosi\DMSnpStatsCollector] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\Patrol')
	CREATE LOGIN [gcosi\Patrol] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\probe')
	CREATE LOGIN [gcosi\probe] FROM WINDOWS WITH DEFAULT_DATABASE=[master]

PRINT 'Logins are created'

-- 2.3 Add the Logins to the Server Role "Monitoring"
ALTER SERVER ROLE Monitoring ADD MEMBER [gcosi\Patrol]
ALTER SERVER ROLE Monitoring ADD MEMBER [gcosi\Probe]
-- any our monitoring account service

PRINT 'Five Logins Added to the Server Role "Monitoring"'
PRINT ''

-- 3 Grant permissions

PRINT 'I-3: Grant Permissions to the New Server Role "Monitoring"'
PRINT @MinorSec

-- clean up Control Mess, if still there
Revoke control SERVER TO [Monitoring] -- too elevated for monitoring, removed in v26
-- we'll do all granular instead


GRANT CONNECT SQL TO [Monitoring]
-- if 2014, we can use Connect Any database
	declare @SQLVersion varchar(50)
	set @SQLversion=Substring((select @@version),29,2)
		Begin
		IF @SQLversion='12' GRANT CONNECT ANY Database TO Monitoring
		END
--GRANT CONNECT REPLICATION TO [Monitoring]  -- fails in 2014
GRANT ALTER TRACE TO [Monitoring]
GRANT VIEW ANY DATABASE TO [Monitoring]
GRANT VIEW ANY DEFINITION TO Monitoring
GRANT VIEW SERVER STATE TO Monitoring
Grant CREATE DDL EVENT NOTIFICATION TO Monitoring
GRANT CREATE TRACE EVENT NOTIFICATION TO Monitoring

PRINT 'Server Role "Monitoring" Granted Permissions'
PRINT ''

-- 4 Revoke permissions to mitigate sysadmin membership risk

PRINT 'I-4: Denny Unecessary Permissions for the New Principals'
PRINT @MinorSec

--4.1 Remove Logins from the Server Role "Sysadmin"  
DECLARE @CMD1 VARCHAR (7000)
SET @CMD1 = ''
SELECT @CMD1 = @CMD1 + 'ALTER SERVER ROLE [sysadmin] DROP MEMBER [' + l.name + '] ' + CHAR(13)
	FROM sys.server_principals l JOIN sys.server_role_members srm on l.principal_id=srm.member_principal_id 
		JOIN sys.server_principals r on r.principal_id=srm.role_principal_id
		WHERE r.name = 'sysadmin' AND l.name in 
				('gcosi\Patrol','gcosi\Probe',
						--'ca\sqlsrvrca',  removed on Oct. 15, 2015; 'gcosi\DMSSQLSrvr' removed on Oct. 29,2015,
				'gcosi\DMSSQLbkp','gcosi\DMSStatsCollector','gcosi\DMSnpStatsCollector'
				)

EXEC (@CMD1)

PRINT 'New Logins Removed from Sysadmin'

-- 4.2 Deny Server Role "Monitoring" Permissions 
-- because we have granted control server, we must apply these DENY statements
Use Master
go
DENY ALTER ANY AVAILABILITY GROUP TO [Monitoring];
DENY ALTER ANY ENDPOINT TO [Monitoring];
DENY ALTER ANY LINKED SERVER TO [Monitoring];
DENY ALTER ANY LOGIN TO [Monitoring];
DENY ALTER ANY SERVER ROLE TO [Monitoring];
--obviously, we want control on number or roles
DENY CREATE ENDPOINT TO [Monitoring];
-- if 2014, we can use Connect Any database
	declare @SQLVersion varchar(50)
	set @SQLversion=Substring((select @@version),29,2)
		Begin
		IF @SQLversion='12' DENY impersonate ANY login to [Monitoring] -- new for 2014
		END

---- Find the Isolated account and deny impersonate on it 
--IF EXISTS (SELECT * FROM sys.server_principals l join sys.server_role_members srm on l.principal_id=srm.member_principal_id 
--				join sys.server_principals s on s.principal_id=srm.role_principal_id
--				WHERE l.name like '%sqsv%' and s.name = 'sysadmin') 
--				-- fix the following to deny impersonate to user logins or groups, each one, not just top 1
--	DENY impersonate on login::@@service account name here  
--	to (SELECT top 1 l.name FROM sys.server_principals l join sys.server_role_members srm 
--					on l.principal_id=srm.member_principal_id 
--					join sys.server_principals s on s.principal_id=srm.role_principal_id
--					WHERE l.type in ('U','G') and 
--						l.name not like '%sqsv%' 
--						and s.name = 'sysadmin' and 
--						l.name not in ('NT SERVICE\Winmgmt','NT SERVICE\SQLWriter','Watermelon','distributor_admin'))
---- have an explicit deny on the instance-specific service accou

DENY Alter ANY Server Audit to [Monitoring]
DENY Unsafe Assembly to [Monitoring];
DENY ALTER SETTINGS to [Monitoring]
REVOKE CONTROL SERVER to [Monitoring]; -- too elevated, explicit REVOKE (since Deny too messy)
DENY SHUTDOWN to [Monitoring];

PRINT 'Some Restrictions to the Server Role "Monitorng" Added.'
PRINT ''

/*	------------------------------ Part II:  DB Level --------------------------------------	*/
-- This will create database role Monitoring and add users to it for msdb, model

--DECLARE @SYSType VARCHAR (10)												--<===== Please sepcify the system type, Prod or NoneProd
--SELECT @SYSType = '' 
--DECLARE @MinorSec varchar (80)
--SELECT	@MinorSec = REPLICATE ('-', 80) 

USE model

-- 1. Create Security Principals

PRINT 'II-1: Manage Monitoring Accesses to the Model database'
PRINT @MinorSec

-- 1.1 Create Users (patrol, probe, stats)

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\patrol' )
	CREATE USER [gcosi\patrol] FOR LOGIN [gcosi\patrol]
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\patrol' )
	CREATE USER [gcosi\patrol] FOR LOGIN [gcosi\probe]
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\DMSnpStatsCollector' ) AND @SYSType <> 'PROD'
	BEGIN	
		CREATE USER [gcosi\DMSnpStatsCollector] FOR LOGIN [gcosi\DMSnpStatsCollector]
		DENY CONTROL ON SCHEMA::[dbo] TO [gcosi\DMSnpStatsCollector]
	END
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\DMSStatsCollector' ) AND @SYSType = 'PROD'
	BEGIN
		CREATE USER [gcosi\DMSStatsCollector] FOR LOGIN [gcosi\DMSStatsCollector]
		DENY CONTROL ON SCHEMA::[dbo] TO [gcosi\DMSStatsCollector]
	END
--IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CA\sqlsrvrca' )  -- Removed on Oct. 15, 2015
	--CREATE USER [CA\sqlsrvrca] FOR LOGIN [CA\sqlsrvrca]

PRINT 'New Model DB Users Created for the Logins'

-- 1.2 Re-create DB Role "Monitoring" and Grant Permissions

SELECT  @CMD = ''
SELECT  @CMD = @CMD + ' ALTER ROLE ' + r.name + ' DROP MEMBER [' + u.name + '];' + CHAR(13)
	FROM sys.database_principals u join sys.database_role_members rm on u.principal_id = rm.member_principal_id
		join sys.database_principals r on rm.role_principal_id = r.principal_id
			WHERE r.name = 'Monitoring'
IF LEN(@CMD) > 10
	EXEC (@CMD)
		--PRINT @CMD
	 
IF EXISTS (SELECT * FROM sys.database_principals WHERE name ='Monitoring' and type='R')
	DROP ROLE Monitoring
CREATE ROLE [Monitoring] AUTHORIZATION [dbo] -- now within Model add a Monitoring Role for all new databases
--GRANT CONTROL TO Monitoring -- too elevated
GRANT ALTER ANY DATABASE EVENT NOTIFICATION  TO [Monitoring];
GRANT view definition, execute, references on schema::[sys] to [Monitoring]  -- not select on DATA, Feb 2016
GRANT select, view definition, execute, references on schema::[dbo] to [Monitoring]
DENY INSERT, UPDATE, DELETE, ALTER TO [Monitoring]  -- requirements for prod 2012, onwards, no select in user databases

PRINT 'DB Role Monitoring Created'

-- 1.3 Add Users to the DB Role 

ALTER ROLE [Monitoring] ADD MEMBER [gcosi\patrol]
IF @SYSType <> 'PROD'--
	ALTER ROLE [Monitoring] ADD MEMBER [gcosi\DMSnpStatsCollector]
ELSE 
	ALTER ROLE [Monitoring] ADD MEMBER [gcosi\DMSStatsCollector]
ALTER ROLE [Monitoring] ADD MEMBER [gcosi\probe]

PRINT 'DB Users Added to the DB Role Monitoring in Model DB'
PRINT ''

-- 2.1 Add Some Users to Fixed Database Roles in the Master Database

USE master 

--DECLARE @SYSType VARCHAR (10)												--<===== Please sepcify the system type, Prod or NoneProd
--SELECT @SYSType = '' 
--DECLARE @MinorSec varchar (80)
--SELECT	@MinorSec = REPLICATE ('-', 80) 

PRINT 'II-2: Manage Monitoring Accesses to the Master Database'
PRINT @MinorSec

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\patrol' )
	CREATE USER [gcosi\patrol] FOR LOGIN [gcosi\patrol]
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\DMSnpStatsCollector' ) AND @SYSType <> 'PROD'
	BEGIN	-- clean up
		CREATE USER [gcosi\DMSnpStatsCollector] FOR LOGIN [gcosi\DMSnpStatsCollector]
		REVOKE CONTROL ON SCHEMA::[dbo] TO [gcosi\DMSnpStatsCollector]
	END
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\DMSStatsCollector' ) AND @SYSType = 'PROD'
	BEGIN
		CREATE USER [gcosi\DMSStatsCollector] FOR LOGIN [gcosi\DMSStatsCollector]
		REVOKE CONTROL ON SCHEMA::[dbo] TO [gcosi\DMSStatsCollector]
	END
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\probe' )
	CREATE USER [gcosi\probe] FOR LOGIN [gcosi\probe]
--IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CA\sqlsrvrca' )  -- Removed on Oct. 15, 2015
--	CREATE USER [CA\sqlsrvrca] FOR LOGIN [CA\sqlsrvrca]
--IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\dmssqlsrvr' )  -- Removed on Oct. 29, 2015
--	CREATE USER [gcosi\dmssqlsrvr] FOR LOGIN [gcosi\dmssqlsrvr]

--ALTER ROLE db_datareader ADD MEMBER [CA\sqlsrvrca]	-- Removed on Oct. 15, 2015
IF @SYSType = 'PROD'
	BEGIN
		GRANT select, view definition, execute, references on schema::dbo to [gcosi\DMSStatsCollector]
		GRANT select, view definition, execute, references on schema::sys to [gcosi\DMSStatsCollector]
	END
ELSE
	BEGIN
		ALTER ROLE db_datareader ADD MEMBER [gcosi\DMSnpStatsCollector] -- Only Non_Production
		GRANT select, view definition, execute, references on schema::dbo to [gcosi\DMSnpStatsCollector]
		GRANT select, view definition, execute, references on schema::sys to [gcosi\DMSnpStatsCollector]
	END

PRINT 'DB Users Created and Added to DB Role Monitoring for the Master Database' 

-- 2.3 Grant Permissions to Some Users
GRANT select, view definition, execute on schema::dbo to  [gcosi\patrol],[gcosi\probe]
				-- [CA\sqlsrvrca],  -- Removed on October 15, 2015
GRANT select, view definition, execute on schema::sys to  [gcosi\patrol],[gcosi\probe]
				--[CA\sqlsrvrca], -- Removed on October 15, 2015

--DECLARE @SYSType VARCHAR (10)												
--<===== Please sepcify the system type, Prod or NoneProd
--SELECT @SYSType = '' 
--DECLARE @MinorSec varchar (80)
--SELECT	@MinorSec = REPLICATE ('-', 80) 

PRINT 'Schema Permissions Granted to 4 Perticular Users in the Master Database'

-- 2.4 Create DB Role Monitoring
SELECT  @CMD = ''
SELECT  @CMD = @CMD + ' ALTER ROLE ' + r.name + ' DROP MEMBER [' + u.name + '];' + CHAR(13)
	FROM sys.database_principals u join sys.database_role_members rm on u.principal_id = rm.member_principal_id
		join sys.database_principals r on rm.role_principal_id = r.principal_id
			WHERE r.name = 'Monitoring'
IF LEN(@CMD) > 10
	EXEC (@CMD)
		--PRINT @CMD
IF EXISTS (SELECT * FROM sys.database_principals WHERE name ='Monitoring' and type='R')
	DROP ROLE Monitoring
CREATE ROLE [Monitoring] AUTHORIZATION [dbo] -- now within Model add a Monitoring Role for all new databases
-- fix control mess, if existing
revoke control on schema::dbo to [Monitoring]
--revoke control on schema::sys to [Monitoring] -- Cannot grant, deny, or revoke CONTROL permission on INFORMATION_SCHEMA or SYS schema.
-- adjust to correct grants.
GRANT select, view definition, execute, references on schema::dbo to [Monitoring]
GRANT select, view definition, execute, references on schema::sys to [Monitoring]
DENY insert, update, delete, alter TO [Monitoring] 

PRINT 'Database Role Monitoring Created in the Master Database, with '

-- 3.1. Create Some Users in msdb, ensure they do not have control
PRINT 'II-3: Manage Monitoring Accesses to the MSDB Database'
PRINT @MinorSec

USE msdb -- MSDB
 
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\patrol' )
	CREATE USER [gcosi\patrol] FOR LOGIN [gcosi\patrol]
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\DMSnpStatsCollector' ) AND @SYSType <> 'PROD'
	BEGIN	
		CREATE USER [gcosi\DMSnpStatsCollector] FOR LOGIN [gcosi\DMSnpStatsCollector]
		Revoke CONTROL ON SCHEMA::[dbo] TO [gcosi\DMSnpStatsCollector]
	END
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\DMSStatsCollector' ) AND @SYSType = 'PROD'
	BEGIN
		CREATE USER [gcosi\DMSStatsCollector] FOR LOGIN [gcosi\DMSStatsCollector]
		Revoke CONTROL ON SCHEMA::[dbo] TO [gcosi\DMSStatsCollector]
	END
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gcosi\probe' )
	CREATE USER [gcosi\probe] FOR LOGIN [gcosi\probe]
--IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CA\sqlsrvrca' )  -- Removed on October 15, 2015
--	CREATE USER [CA\sqlsrvrca] FOR LOGIN [CA\sqlsrvrca]

SELECT  @CMD = ''
SELECT  @CMD = @CMD + ' ALTER ROLE ' + r.name + ' DROP MEMBER [' + u.name + '];' + CHAR(13)
	FROM sys.database_principals u join sys.database_role_members rm on u.principal_id = rm.member_principal_id
		join sys.database_principals r on rm.role_principal_id = r.principal_id
			WHERE r.name = 'Monitoring'
IF LEN(@CMD) > 10
	EXEC (@CMD)
		--PRINT @CMD
	 
IF EXISTS (SELECT * FROM sys.database_principals WHERE name ='Monitoring' and type='R')
	DROP ROLE [Monitoring]
CREATE ROLE [Monitoring] AUTHORIZATION [dbo] -- now within Model add a Monitoring Role for all new databases

PRINT 'DB Role Monitoring Created'

Revoke CONTROL on schema::[dbo] to Monitoring -- clean up mess from before, and grant explicit permissions instead
--Revoke CONTROL on schema::sys to Monitoring -- clean up mess from before, and grant explicit permissions instead

GRANT select, view definition, execute, references on schema::dbo to [Monitoring]
GRANT select, view definition, execute, references on schema::sys to [Monitoring]
DENY insert, update, delete, alter TO [Monitoring] 

ALTER ROLE SQLAgentReaderRole ADD MEMBER [gcosi\Patrol]
ALTER ROLE db_backupoperator ADD MEMBER [gcosi\Patrol]

PRINT 'DB Monitoring Users Created in msdb Database'

GRANT select, view definition, execute, references on schema::dbo to  
		[gcosi\patrol], [gcosi\probe]  --, [CA\sqlsrvrca]  -- Removed on October 15, 2015
GRANT select, view definition, execute, references on schema::sys to  
		[gcosi\patrol], [gcosi\probe]  -- , [CA\sqlsrvrca]

-- 3.2 Add More Users to Some Fixed Database Roles in msdb

IF @SYSType = 'PROD'
	BEGIN 
		ALTER ROLE SQLAgentReaderRole ADD MEMBER [gcosi\DMSStatsCollector]  -- For Production
		ALTER ROLE db_backupoperator ADD MEMBER [gcosi\DMSStatsCollector]	-- For Production
		GRANT select, view definition, execute, references on schema::dbo to [gcosi\DMSStatsCollector]
		GRANT select, view definition, execute, references on schema::sys to [gcosi\DMSStatsCollector]
	END
ELSE
	BEGIN
		ALTER ROLE SQLAgentReaderRole ADD MEMBER [gcosi\DMSnpStatsCollector] -- For Non-Prod
		ALTER ROLE db_backupoperator ADD MEMBER [gcosi\DMSnpStatsCollector] -- For Non-Prod
		GRANT select, view definition, execute, references on schema::dbo to [gcosi\DMSnpStatsCollector]
		GRANT select, view definition, execute, references on schema::sys to [gcosi\DMSnpStatsCollector]
	END
 PRINT 'DB Users Added to Fixed DB Roles and Granted Schema Permissions in MSDB'
 PRINT ''

 ---- ADD SPADE Login/User  New April 2016
USE [master]
GO
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'spade')
	CREATE LOGIN [spade] WITH PASSWORD=N'LongPass', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GRANT CONNECT SQL TO [Spade]
GRANT VIEW ANY DEFINITION TO [Spade]
-- 2014 onwards only, ignore error otherwise
Grant Connect Any Database TO [Spade]
go
-- user rights in master
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'spade' )
	CREATE USER [spade] FOR LOGIN [spade]
ALTER ROLE [db_datareader] ADD MEMBER [spade] -- you didn't mention sys dbs, so I figure read access okay?
GO
USE [model]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'spade' )
	CREATE USER [spade] FOR LOGIN [spade]-- so instead of DBO, the following two sys grants are sufficient for spade
GRANT select on sys.sysusers to [spade]
GRANT select on sys.sysobjects to [spade]
GO


/*	---------------------------- Part III:  DB Level Restrictions ---------------------------	*/


--DECLARE @SYSType VARCHAR (10)												--<===== Please sepcify the system type, Prod or NoneProd
--SELECT @SYSType = '' 
--DECLARE @MinorSec varchar (80)
--SELECT	@MinorSec = REPLICATE ('-', 80) 

-- 1. Revoke some permissions for the designated users to be sure
PRINT 'III-1 Impose Restrictions to the certain Monitoring Users to be sure Control not allowed'
PRINT @MinorSec

USE master

-- Removed originally, but readded in Feb, not a bad thing to reduce if there
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\dmssqlsrvr')  
	BEGIN
		DENY ALTER ANY USER to [gcosi\dmssqlsrvr]
		REVOKE CONTROL to [gcosi\dmssqlsrvr]
	END
-- the usual suspects for monitoring, just to be sure no control
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\Patrol')
	BEGIN
		DENY ALTER ANY USER to [gcosi\Patrol]
		REVOKE CONTROL to [gcosi\Patrol]
	END
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'gcosi\probe')
	BEGIN
		DENY ALTER ANY USER to [gcosi\probe]
		REVOKE CONTROL to [gcosi\probe]
	END
PRINT 'User Permission Retrictions Imposed'
PRINT ''

-- 2. Deny more rights to public (add to system databases)
-- SQL Server Hardening Guide 7.3 Revoking Registry Read to Public 

PRINT 'III-2 Some Permissions Denied for Public'
PRINT @MinorSec

REVOKE EXECUTE on xp_instance_regread to [public]   -- Changed from DENNY to REVOKE  on Oct. 289, 2015
REVOKE EXECUTE on xp_regread to [public] -- MEANS that each group of users needs Grant Execute on xp_ to Group

REVOKE EXECUTE on sp_helptext to [public]
REVOKE SELECT on sys.syscomments to [public]

-- additional from Guardium's scan for Access to General Extended procedures (February 2016)
REVOKE EXECUTE on xp_getnetname to [public]
REVOKE EXECUTE on xp_dirtree to [public]
REVOKE EXECUTE on xp_msver to [public]
REVOKE EXECUTE on xp_fixeddrives to [public]
REVOKE EXECUTE on xp_sscanf to [public]
REVOKE EXECUTE on xp_sprintf to [public]
-- these also?  not tested yet
--revoke view server state from public
--revoke view any database from public

-- what about these in CIS standards 
-- https://labs.portcullis.co.uk/blog/ms-sql-server-audit-extended-stored-procedures-table-privileges/
--xp_availablemedia
-- 3.3 xp_dirtree
-- 3.4 xp_enumgroups
-- 3.5 xp_fixeddrives
-- 3.6 xp_servicecontrol
-- 3.7 xp_subdirs
-- 3.8 xp_regaddmultistring
-- 3.9 xp_regdeletekey
-- 3.10 xp_regdeletevalue
-- 3.11 xp_regenumvalue
-- 3.12 xp_regremovemultistring
-- 3.13 xp_regwrite
-- 3.14 xp_regread

/*
-- we would have to add explicit access to any of these extended stored procs in master, by group (major pain)
-- add if Canadian server statement here (redundant for SU, since they are sysadmin, but as examples)
grant EXECUTE on xp_getnetname to [gcosi\DMS_SQL_Can_su]
grant EXECUTE on xp_dirtree to [gcosi\DMS_SQL_Can_su]
grant EXECUTE on xp_msver to [gcosi\DMS_SQL_Can_su]
grant EXECUTE on xp_fixeddrives to [gcosi\DMS_SQL_Can_su]
grant EXECUTE on xp_sscanf to [gcosi\DMS_SQL_Can_su]
grant EXECUTE on xp_sprintf to [gcosi\DMS_SQL_Can_su]

-- registry and helptext, syscomments (users of SSMS, their groups need to be added or Properties of objects throw errors)
grant EXECUTE on xp_instance_regread to [GroupName]
grant EXECUTE on xp_regread to [GroupName]
-- doubtful users will need these
grant EXECUTE on sp_helptext to [GroupName]
grant EXECUTE on sp_helptext to [GroupName]
*/

-- add if US server statement here
/*
-- offshore
grant EXECUTE on xp_getnetname to [gcosi\DMS_SQL_ISC_su]
grant EXECUTE on xp_dirtree to [gcosi\DMS_SQL_ISC_su]
grant EXECUTE on xp_msver to [gcosi\DMS_SQL_ISC_su]
grant EXECUTE on xp_fixeddrives to [gcosi\DMS_SQL_ISC_su]
grant EXECUTE on xp_sscanf to [gcosi\DMS_SQL_ISC_su]
grant EXECUTE on xp_sprintf to [gcosi\DMS_SQL_ISC_su]

-- registry and helptext, syscomments (users of SSMS, their groups need to be added or Properties of objects throw errors)
grant EXECUTE on xp_instance_regread to [GroupName]
grant EXECUTE on xp_regread to [GroupName]
-- doubtful users will need these
grant EXECUTE on sp_helptext to [GroupName]
grant EXECUTE on sp_helptext to [GroupName]

-- US example (SU group redudant, just an example)
grant EXECUTE on xp_getnetname to [gcosi\DMS_SQL_US_su]
grant EXECUTE on xp_dirtree to [gcosi\DMS_SQL_US_su]
grant EXECUTE on xp_msver to [gcosi\DMS_SQL_US_su]
grant EXECUTE on xp_fixeddrives to [gcosi\DMS_SQL_US_su]
grant EXECUTE on xp_sscanf to [gcosi\DMS_SQL_US_su]
grant EXECUTE on xp_sprintf to [gcosi\DMS_SQL_US_su]

-- registry and helptext, syscomments (users of SSMS, their groups need to be added or Properties of objects throw errors)
grant EXECUTE on xp_instance_regread to [GroupName]
grant EXECUTE on xp_regread to [GroupName]
-- doubtful users will need these
grant EXECUTE on sp_helptext to [GroupName]
grant EXECUTE on sp_helptext to [GroupName]
*/

-- automatically grant any logins these public rights?  of of these above as a cursor

PRINT 'Public Access Restriction Imposed'
PRINT ''

-- 2.1 OLEDB Permissions			-- This Section is Added on October 15, 2015
Use master
--- disable adhoc access for each ole db provider
EXEC master.dbo.sp_MSset_oledb_prop N'SQLNCLI11', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'ADsDSOObject', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'DTSPackageDSO', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'DTSPackageDSO', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'IBMDADB2.DB2COPY1', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.Jet.OLEDB.4.0', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'MSDAORA', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'MSDAOSP', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'MSDASQL', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'MSDMine', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'MSIDXS', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'MSOLAP', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'SQLNCLI10', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'SQLOLEDB', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'SQLReplication.OLEDB', N'DisallowAdHocAccess', 1
--in 2014
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DisallowAdHocAccess', 1
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.15.0', N'DisallowAdHocAccess', 1
GO

PRINT 'Public Access Restriction Imposed'
PRINT ''

IF @SYSType <> 'PROD'
	BEGIN
	EXEC sp_configure 'common criteria compliance enabled',1
	GO
	RECONFIGURE WITH OVERRIDE;
	GO
END

--PRINT 'Common Criteria compliance Enabled!'
PRINT ''

-- 3. Revoke Guest connection in Model DB

PRINT 'III-3 Revoke Guest Connection in the Model Database'
PRINT @MinorSec

USE model
go
REVOKE CONNECT FROM GUEST

PRINT 'Guest Connection Revoked in the Model Database, b/c you cannot in master, temp'
PRINT ''
