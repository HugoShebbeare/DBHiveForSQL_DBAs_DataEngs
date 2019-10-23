Print '**********SQL Server Security Audit Review Report, V1.05 for Alithya, by Hugo Shebbeare*************'

------------------------------------------------------------------------------

print '*********************************************************************'
print '*****Section 2: corresponding SQL All Security Hardening Section*****'
print '*********************************************************************'
print ''
print ''
print '*******************************************'
print '***2a. Review principals and logins info***'
print '*******************************************'
print ''

SELECT  
	login.name
	,login.create_date
	,login.modify_date
	,login.type_desc
  FROM sys.server_principals login
  left join sys.sql_logins sqll 
	on login.principal_id=sqll.principal_id
  where login.type_desc not in ('SERVER_ROLE', 'CERTIFICATE_MAPPED_LOGIN')

-- remove the defaults, if you want to harden right away
--ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\SQLWriter]
--ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\Winmgmt]
--ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\MSSQLSERVER]
--ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\SQLSERVERAGENT]




print '***Comments:***'
print '--are all of the above necessary on this server?'
print '--can you reduce the SQL Logins? Can they be AD instead? (AD is more secure)'
print '--WATCH out for BUILTIN\Administrators - they should have been elminated already above'
print '--should not be added, as per best practices'
print 'End of comments---'
print ''
print ''
print '**************************************************'
print '***End of 2a. Review principals and logins info***'
print '**************************************************'


print ''
print ''
-----------------------------------------------------------------------------------
print '*********************************************************'
print '***2b. Check who is a member of the fixed server roles***'
print '*********************************************************'
print ''
print 'Members of ServerRole - sysadmin'
print ''

	exec sp_helpsrvrolemember 'sysadmin'
print ''
print '--Should only contain SU accounts or the Service Accounts'
print '--review that only only the necessary groups or people are sysadmin'
print '--for example of way too many, see -and BUILTIN\Administrators also?!!!'
print ''
print ''
print 'Members of ServerRole - SecurityAdmin'
print ''
 	exec master.dbo.sp_helpsrvrolemember 'securityadmin'  
print ''
print '***Comment:role reserved for DBAs usually***'
print ''
print 'Members of Serverrole - ServerAdmin'
	exec master.dbo.sp_helpsrvrolemember 'serveradmin'
print ''
print '*****Members of Serverrole - Monitoring *****'
Select *
FROM sys.database_principals u join sys.database_role_members rm on u.principal_id = rm.member_principal_id
		join sys.database_principals r on rm.role_principal_id = r.principal_id
			WHERE r.name = 'Monitoring'  -- monitoring accounts
print ''
print 'Members of serverrole - SetupAdmin'

	exec master.dbo.sp_helpsrvrolemember 'setupadmin'
print ''
print 'Members of ProcessAdmin'

	exec master.dbo.sp_helpsrvrolemember 'processadmin'  
print ''
print 'Members of DiskAdmin'
print ''
	exec master.dbo.sp_helpsrvrolemember 'diskadmin'
print ''
print 'Members of serverrole - DBCreator'
print ''
	exec master.dbo.sp_helpsrvrolemember 'dbcreator'
print ''
print 'Members of serverrole - BulkAdmin'
print ''
	exec master.dbo.sp_helpsrvrolemember 'bulkadmin'
print ''
print 'SA User - 1=Disabled, If NAME not SA, Renamed to Ines...or generic persons name...'
SELECT name, is_disabled FROM sys.server_principals WHERE sid = 0x01;
print ' ** SA USER status above ** IF NAME=WATERMELLON Rename status is Good **'

print '*******************************************************'
print '***2b completed.  End of Server Role member listings***'
print '*******************************************************'
print ''
----------------------------------------------------------------------------------------
print '***comments***'
print '--if nobody shows up in any of the above thats a good thing'
print '--often  those members will be in DBAs and Monitoring roles'
print '--which are User Defined Server Roles, see DBAs / Montoring role creation above.'
print '***End of Comments***'
print ''
print ''
print '*************************************************************************************************************'
print '***2c.  Check for null passwords first, and then sql logins that would be expired if AD rules applied********'
print '*************************************************************************************************************'

SELECT name,type_desc,create_date,modify_date,password_hash 
FROM sys.sql_logins 
WHERE PWDCOMPARE('',password_hash)=1;

print 'or for logins that use password of the same name'
SELECT name,type_desc,create_date,modify_date,password_hash 
FROM sys.sql_logins 
WHERE PWDCOMPARE(name,password_hash)=1;

print '************************************************************************************************************'
print '***and those sql logins that would be expired if AD rules applied*******************************************'
print '************************************************************************************************************'

SELECT SQLLoginName = sp.name FROM sys.server_principals sp JOIN sys.sql_logins AS sl ON sl.principal_id = sp.principal_id WHERE sp.type_desc = 'SQL_LOGIN' AND sp.name in (SELECT name AS IsSysAdmin FROM sys.server_principals p WHERE IS_SRVROLEMEMBER('sysadmin',name) = 1) AND sl.is_expiration_checked <> 1;

print 'ignore if you have disabled SA already, when it shows up here'
print '*******************************************************'
print '***End of 2c. Check for null passwords, and expired****'
print '*******************************************************'
print ''
----------------------------------------------------------------------------------------

print ''
print '****************************************'
print '***2d.  Check out CONTROL Permissions***'
print '****************************************'
print ''

	SELECT
		 login.name
		 ,perm.class_desc
		 ,perm.permission_name
		 ,perm.state_desc
	FROM sys.server_permissions perm 
	JOIN sys.server_principals login
		on perm.grantee_principal_id=login.principal_id
	WHERE perm.permission_name='CONTROL SERVER';

print ''
print '***Comments: NOBODY IN THERE? Good  Otherwise, why?'
print '--##MS_PolicySigningCertificate##  it is okay for this placeholder to be there?'
print '***End of comments***'
print ''
print '***********************************************'
print '***End of 2d.  Check out CONTROL Permissions***'
print '***********************************************'
-----------------------------------------------------------------------------------------
print ''
print '**************************************************************************************'
print '***2e. Fix this to find grantees from sys.server_principals login or sys.sql_logins***'
print '**************************************************************************************'
print ''

-----------------------------------------------------------------------------
--- Rights Granted: Given a list of Users in the current database, return
---		the list of effective rights (including Deny) based on the Grants 
---		issued to the User, all Roles the User is a member of, membership
---		in fixed database Roles (e.g., db_datareader) and membership in any
---		fixed server roles.
-----------------------------------------------------------------------------

--- BUG/FEATURE: Doesn't account for the fact that each Login is de facto a member of Public.

set nocount on;

---------------------------------------
--- Declarations
---------------------------------------

declare
	@AllUsers	bit = 0,	--<<< SET THIS VALUE
							--	1 = Gather for ALL Users
							--	0 = Gather for explicit list in @Users table
	@ShowRaw	bit = 0,

	@PKey		int = 1,
	@MaxPKey	int = 0,

	@sqlStmt	nvarchar(max) = N'',
	@Login		sysname = N'',
	@template	nvarchar(max) = N'exec xp_logininfo ''<<UserName>>'', ''all''';

if object_id('tempdb..#loginInfo') is not null
	drop table #loginInfo;

create table #loginInfo (
	accountName		sysname,		-- Fully qualified Windows account name.
	type			char(8),		-- Type of Windows account. Valid values are user or group.
	privilege		char(9) null,	-- Access privilege for SQL Server. Valid values are admin, user, or null.
	MappedLoginName	sysname,		-- For user accounts that have user privilege, mapped login name 
									--	shows the mapped login name that SQL Server tries to use when 
									--	logging in with this account by using the mapped rules with 
									--	the domain name added before it.
	PermissionPath	sysname			-- Group membership that allowed the account access.
	);

declare @Users table (
	pkey		int identity(1, 1),
	UserName	sysname
	)

---------------------------------------
--- Define the User(s) of interest
---------------------------------------

insert into @Users (UserName)
values
	--('role_DenyWrite'),			--<<< Populate with a list of Users or Roles
	--('XYZ\WINDOWSGROUP'),
	('XYZ\WINDOWSUSER'),
	--('SqlLogin'),
	('public')

set @MaxPKey = @@rowcount;

-----------------------------------------------------------------------------
--- Find Logins that are members of Windows Groups and add the Group to the 
---	set of Logins
-----------------------------------------------------------------------------

while (@PKey <= @MaxPKey)
begin
	select @Login = UserName
	from @Users
	where pkey = @PKey

	if exists(select *
			from sys.server_principals sp
			where sp.name = @Login
			and sp.type = 'U'
			) 
		or
		not exists(select *
			from sys.server_principals sp
			where sp.name = @Login
			) 
	begin
		set @sqlStmt = replace(@template, '<<UserName>>', @Login);

		truncate table #loginInfo;

		insert into #loginInfo (
			accountName,
			type,
			privilege,
			MappedLoginName,
			PermissionPath
			)
		exec sp_ExecuteSQL @sqlStmt

		--/**/select * from #loginInfo;

		insert into @Users(UserName)
		select l.PermissionPath
		from #loginInfo l
		left outer join
			@Users u
				on	u.UserName = l.PermissionPath
				and	l.type = 'user'
		where
			u.UserName is null
	end

	set @PKey += 1;
end

--/**/select 'Agg Users' Label, * from @Users

-----------------------------------------------------------------------------

if @ShowRaw = 1
begin
	select
		@@servername SrvName,
		db_name() DbName,
		d.name dn,
		s.sid ServerSID,
		d.sid DB_SID,
		case
			when s.sid = d.sid then 1
			else 0
			end is_equal
	from
		sys.server_principals s
	inner join
		sys.database_principals d
			on d.name = s.name
	where
		@AllUsers = 1
		or
		s.Name in (
			select UserName
			from @Users
			)
end

-----------------------------------------------------------------------------

;with AllRoles	-- Recursively find all Roles the Users are members of
as	(
	select
		dp.principal_id,
		dp.name,
		dp.sid,
		cast('' as sysname) MemberName,
		cast(dp.name as sysname) Lineage,
		dp.name BaseName
	from sys.database_principals dp
	left outer join sys.server_principals sp
		on	dp.sid = sp.sid
	--where
	--	dp.type in ('S', 'U', 'G')
	--or	dp.name = 'public'			-- Public is special since it is not in sys.database_role_members

	union all

	select 
		r.principal_id, 
		r.name,
		r.sid, 
		rm.Name, 
		cast(r.Name + N'.' + Lineage as sysname), 
		ar.BaseName
	from
		AllRoles ar
	inner join
		sys.database_role_members drm
			on	drm.member_principal_id = ar.principal_id
	inner join
		sys.database_principals r
			on	r.principal_id = drm.role_principal_id
	inner join
		sys.database_principals rm
			on	rm.principal_id = drm.member_principal_id
)
select a.*
from (
	-------------------------------------------
	--- Object Level Rights: Explicit Grants
	---	(Based on User and Role Memberships)
	-------------------------------------------

	SELECT 'Explicit Grants' How,
		coalesce(so.name, '.') AS 'Object Name', 

		sp.permission_name,
		state_desc,

		u.Name Grantee,
		ar.Lineage,
		ar.BaseName
	FROM
		sys.database_permissions sp					-- Rights Granted
	inner join
		sys.database_principals u					-- Grantee
			on	sp.grantee_principal_id = u.principal_id

	left outer join
		sys.objects so								-- Object
			on	so.object_id = sp.major_id

	inner join
		AllRoles ar
			on	u.sid = ar.sid

	WHERE 
		(
		so.name is Null
	or
		LEFT(so.name,3) NOT IN ('sp_', 'fn_', 'dt_', 'dtp', 'sys')
		--AND
		--so.type IN ('U','V','TR','P','FN','IF','TF')
		)
	--and	not (
	--		sp.class_desc = 'DATABASE'
	--	and sp.permission_name = 'CONNECT'
	--	)
	and	sp.major_id >= 0					-- Negative => System Object
	and (
		ar.BaseName = 'public'
		or
		@AllUsers = 1
		or
		ar.BaseName in (
			select UserName
			from @Users
			)
		)

	union --all

	-------------------------------------------
	--- Fixed Database Role Membership
	-------------------------------------------

	select 'Fixed Database Role' How,
		ar.Name,
		'.',
		'.',
		ar.MemberName,
		ar.Lineage,
		ar.BaseName
	from
		AllRoles ar
	inner join
		sys.database_principals r
			on	r.principal_id = ar.principal_id
			and	r.is_fixed_role = 1
	where
		@AllUsers = 1
		or
		ar.BaseName in (
			select UserName
			from @Users
			)

	union --all

	-------------------------------------------
	--- Fixed Server Role Membership
	-------------------------------------------

	select 'Fixed Server Role' How,
		sr.Name,
		'.',
		'.',
		'Server Role',
		'.',
		l.Name
	from sys.server_principals l
	inner join
		sys.server_role_members r
	on
		r.member_principal_id = l.principal_id
	inner join
		sys.server_principals sr
	on
		sr.principal_id = r.role_principal_id
	and	sr.type = 'R'
	where
		@AllUsers = 1
		or
		l.name in (
				select UserName
				from @Users
				)

	union --all

	-------------------------------------------
	--- Explicit Server Level Rights
	---	(Based on Login)
	-------------------------------------------

	select 'Explicit Server: Login' How,
		'Server',
		sp.permission_name,
		sp.state_desc,
		l.Name,
		'.',
		l.Name
	from
		sys.server_permissions sp				-- Rights Granted
	inner join
		sys.server_principals l					-- Grantee
			on	sp.grantee_principal_id = l.principal_id
	where
		sp.permission_name <> 'CONNECT SQL'
	and	(
		@AllUsers = 1
		or
		l.name in (
				select UserName
				from @Users
				)
		)

	union --all

	-------------------------------------------
	--- Explicit Server Level Rights
	---	(Based on Login -> Server Role)
	-------------------------------------------

	select 'Explicit Server: Role' How,
		'Server',
		sp.permission_name,
		sp.state_desc,
		l.Name,
		'.',
		l.Name
	from
		sys.server_permissions sp				-- Rights Granted
	inner join
		sys.server_principals sr
			on	sp.grantee_principal_id = sr.principal_id
			and	sr.type = 'R'					-- Grantee is Server Role
	inner join
		sys.server_role_members srm
			on	sr.principal_id = srm.role_principal_id
	inner join
		sys.server_principals l					-- Login is member of Role
			on	srm.member_principal_id = l.principal_id
	where
		sp.permission_name <> 'CONNECT SQL'
	and	(
		@AllUsers = 1
		or
		l.name in (
				select UserName
				from @Users
				)
		)
	) a
order by
	BaseName,
	case
		when permission_name = '' then 1 else 2 end,
	[Object Name],
	permission_name,
	state_desc,
	Grantee


print ''
print '***Comments***'
print '--see something wrong, then execcute the following example'
print '--will not work in master tho:  DENY View Any Database to Guest' 
print '--replace the View any database permission name with what is concerning'
print ''
print ''
print '**************************************************************************************'
print '***End of 2e. Fix this to find grantees from sys.server_principals login or sys.sql_logins***'
print '**************************************************************************************'



--------------------------------------------------------------------------------------------
print '*************************'
print '*** 2f.  Details about Role Membership ***'
print '*************************'
print ''
print ''
-- Role Members
create table #AppRoleMembers_t
	(lineData	varchar(2000))

create table #AppRoleMembers_Aggregate_t
	(dbname		nvarchar(128)
	,login		nvarchar(128)
	,isapprole	int
	,pw_len		int)


insert #AppRoleMembers_t
	select 'select 		db_name()
		,t1.name
		,t2.isapprole
		,len(t1.password) 
		from master.dbo.syslogins as t1 
		inner join ' + name + '.dbo.sysusers as t2 on t1.name = t2.name 
		where t2.isapprole = 1 
		and t1.password is null' 
	from master.dbo.sysdatabases 
	where dbid > 4
	and databasepropertyex(name, 'SQLSortOrder') = databasepropertyex('master', 'SQLSortOrder')
	order by name
declare @tsql	varchar(4000)

declare db_cur2 cursor
for
 	select lineData from #AppRoleMembers_t

open db_cur2

fetch next from db_cur2 into @tsql

set @tsql = 'insert #AppRoleMembers_Aggregate_t ' + @tsql

while (@@fetch_status = 0)
begin
	--print @tsql
	exec (@tsql)
	fetch next from db_cur2 into @tsql
end

close db_cur2

deallocate db_cur2


--select * from AppRoleMembers_t
print '*** Check count on AppRoleMembers_Aggregate ***)'
if (select count(*) from #AppRoleMembers_Aggregate_t) = 0
begin
	print 'No application roles with blank passwords exist on this server at this time.'

end

	select * from #AppRoleMembers_Aggregate_t


drop table #AppRoleMembers_t
drop table #AppRoleMembers_Aggregate_t

set nocount on

declare @tsql2	varchar(70),
	@name	varchar(64)

declare db_cur cursor
for
 	select name from master.dbo.sysdatabases where dbid > 4 order by name

open db_cur

fetch next from db_cur into @name

set @tsql2 = 'exec ' + @name + '.dbo.sp_helprolemember'

while (@@fetch_status = 0)
begin
	print 'Roles in database ' + @name + ':'
	set @tsql2 = 'exec ' + @name + '.dbo.sp_helprolemember'
	exec (@tsql2)
	fetch next from db_cur into @name
end


close db_cur

deallocate db_cur

print ''
print '****************************'
print '***End of 2f.Role Members***'
print '****************************'
print ''
print ''

print '*******************************************************************************'
print '*****End of Section 2: see above user permissions, roles, role membership *****'
print '*******************************************************************************'
print ''
print ''
----------------------------------------------------------------------------

print '****************************************************************************'
Print '*****Section 3.0  Port Hardening *******************************************'
print '****************************************************************************'

-- 3.1.1 corresponding SQL All Security Hardening Section
-- Validate which ports SQL is listening, as well as Connections
-- Query Endpoints and Connections:

Print ''
Print '****************************'
Print '*** 3a.  Query Endpoints ***'
print '****************************'
print ''
	select * 
	  from sys.endpoints

print ''
print '***Comments:***' 
print '-- Port 1433 should not be there unless an exception - is VIA there? Why? (we do not support VIA, only Named Pipes, TCPIP and SharedMemory)'
print '-- how do we stop VIA? '
print ''
Print ''
Print '***********************************'
Print '****End of 3a.  Query Endpoints****'
print '***********************************'
print ''
print ''
print '******************************'
print '****3b.  Query Connections****'
print '******************************'

	select * 
	  from sys.dm_exec_connections
	  -- as per best practices of Security hardening, make sure Named Pipes are disabled unless necessary
	
print ''
print '***comments:***'
print '-- this query is more important once server is up and in pre-production testing'
print '-- 3.1.1 - 12.1 & 12.2 corresponding SQL All Security Hardening Section'
print '-- for each new application added, one should verify the wanted/identifiable'
print '-- (and not unwanted) logins are viewed'

print '-- are those local/client_net_address(es) coming from desireable clients?'
print '-- named pipes will probably be the most popular transport method.'
print '************Are their orphan windows accounts on SQL?'
exec sp_validateLogins -- can only be run by sysadmin?
go

print '************Change Users Login Stored Prod Report?'
EXEC sp_change_users_login @Action='Report'; -- can only be run by sysadmin?
go
-- DROP USER <username>;  -- if necessary 

print '***End of User / login Connections and orphan check***'
print ''
print '*************************************'
print '****End of 3b.  Query Connections****'
print '*************************************'
print ''
print ''
print '****************************************************************************'
Print '*****End of Section 3.0  Port Hardening*************************************'
print '****************************************************************************'
print ''
print ''
------------------------------------------------------------------------
print '****************************************************************************'
print '*****Section 5.3  SQL 2012 Services Running*********************************'
print '****************************************************************************'
print ''
print ''
print '*************************************************************'
print '****5.3a corresponding SQL All Security Hardening Section****'
print '*************************************************************'
print '-- new for sql 2012: check which services are listed:'

print 'Print SQL Server Services Configured'
print '-----------------------------------------------------------------'

	select * 
	  from sys.dm_server_services
GO
Use Master 
GO -- in case above errors out for less then 2012 version

print '***Comments:***'
print '-- for sql 2012, our standard is to have Database Engine (you will see one per instance), '
print '-- Agent, Reporting Service Account'
print '-- Integration Services, SQL Browser - and only in special cases Analysis Services'
print '-- IF you see Distributed Replay Controller or other servers that make no sense in production, disable them'
print ''
print '*********************************************************************'
print '*** End of 5.3a corresponding SQL All Security Hardening Section*****'
print '*********************************************************************'
print ''
print ''
print '****************************************************************************'
print '*****End of Section 5.3  SQL 2012 Services Running *************************'
print '****************************************************************************'

-----------------------------------------------------------------------


print ''
print '****************************************************************************'
print '*****10: SQL Server Config-important for performance ***********************'
print '****************************************************************************'
print ''
print '*******************************'
print '*** 10a.  exec sp_configure (shows all configuration settings) ****'
print '*******************************'
print ''
	exec master.dbo.sp_configure

print 'End of SQL Server Configuration Settings...'
print ''
print '**************************************************'
print '*****End of 10a. exec sp_configure****************'
print '**************************************************'
print ''
print '***********************************************************************'
print '***Section 10b.  Cluster installation Validate cluster node details ***'
print '***********************************************************************'
print ''
-- Clustered Installation, validate cluster node details
print 'Servername'
	select @@SERVERNAME
	go
print '@@version'
	select @@VERSION
	go
print 'xp_msver'
	exec xp_msver
	go
print 'sp_configure'
	exec sp_configure 'show advanced options',1
	go
	reconfigure
	go
	exec sp_configure 
	go
print 'dm_os_cluster_nodes'
	SELECT * 
	  FROM sys.dm_os_cluster_nodes 
	go
print 'ComputerNamePhysicalNetBios\CurrentNodeName'

	SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [CurrentNodeName]

print ''
print '******************************************************************************'
print '***End of Section 10b.  Cluster installation Validate cluster node details ***'
print '******************************************************************************'
print ''
print ''
print ''
print '*********************************************************************************************************'
print '*****End of Section 10 Security Hardening on the Instance post installation for audit documentation *****'
print '*********************************************************************************************************'
print ''
print ''
print ''
print '***************************************************************************************'
print '***** Section 11.  BEGIN details on how to validate and improve Database security *****'
print '***************************************************************************************'
print ''
print '***Comments:***'
print '-- BEGIN details on how to validate and improve Database security'
print '-- The following is provided to help DBAs narrow down security management to simply database level access.'
print '***End of comments***'
print ''
print ''
print '*******************************************************************************************'
print '***Section 11a. Review existing Database Grants (user databases should be denied select)***'
print '*******************************************************************************************'
print '  ***** Stacey V. Murphy, use case would be to validate Control problems *****'
SELECT CASE dperms.state_desc
    WHEN 'GRANT_WITH_GRANT_OPTION' THEN 'GRANT'
    ELSE state_desc 
  END
  + ' ' + permission_name + ' ON ' +
  CASE dperms.class
    WHEN 0 THEN 'DATABASE::[' + DB_NAME() + ']'
    WHEN 1 THEN
      CASE dperms.minor_id
        WHEN 0 THEN 'OBJECT::[' + sch.[name] + '].[' + obj.[name] + ']'
        ELSE 'OBJECT::[' + sch.[name] + '].[' + obj.[name] + '] ([' + col.[name] + '])'
      END
    WHEN 3 THEN 'SCHEMA::[' + SCHEMA_NAME(major_id) + ']'
    WHEN 4 THEN 'USER::[' + USER_NAME(major_id) + ']'
    WHEN 24 THEN 'SYMMETRIC KEY::[' + symm.[name] + ']'
    WHEN 25 THEN 'CERTIFICATE::[' + certs.[name] + ']'
    WHEN 26 THEN 'ASYMMETRIC KEY::[' + asymm.[name] +']'
  END
  + ' TO [' + dprins.[name] + ']' +
  CASE dperms.state_desc
    WHEN 'GRANT_WITH_GRANT_OPTION' THEN ' WITH GRANT OPTION;'
    ELSE ';'
  END COLLATE database_default AS 'Permissions'
FROM sys.database_permissions dperms
  INNER JOIN sys.database_principals dprins
    ON dperms.grantee_principal_id = dprins.principal_id
  LEFT JOIN sys.columns col
    ON dperms.major_id = col.object_id AND dperms.minor_id = col.column_id
  LEFT JOIN sys.objects obj
    ON dperms.major_id = obj.object_id
  LEFT JOIN sys.schemas sch
    ON obj.schema_id = sch.schema_id
  LEFT JOIN sys.asymmetric_keys asymm
    ON dperms.major_id = asymm.asymmetric_key_id
  LEFT JOIN sys.symmetric_keys symm
    ON dperms.major_id = symm.symmetric_key_id
  LEFT JOIN sys.certificates certs
    ON dperms.major_id = certs.certificate_id
WHERE dperms.type <> 'CO'
    AND dperms.major_id > 0;


	SELECT 
		perms.state_desc AS State 
		,permission_name AS [Permission] 
		,obj.name AS [on Object]
		,dPrinc.name AS [to User Name] 
		,sPrinc.name AS [who is Login Name]
	  FROM sys.database_permissions AS perms
		JOIN sys.database_principals AS dPrinc
		ON perms.grantee_principal_id = dPrinc.principal_id
		JOIN sys.objects AS obj
		ON perms.major_id = obj.object_id
		LEFT OUTER JOIN sys.server_principals AS sPrinc
		ON dPrinc.sid = sPrinc.sid


print ''
print '**********************************************************************************************'
print '***** Section 11b.  Validate related Linked Server security *****'
print '**********************************************************************************************'

		Select	s.name LinkedServerName
			, ll.remote_name  as Remote_login 
		from	sys.servers s 
				INNER JOIN 
			sys.linked_logins ll ON s.server_id = ll.server_id 
		where	s.server_id > 0 
			AND ll.local_principal_id=0 
			AND ll.uses_self_credential=0
 			--AND s.product='SQL Server' 

/* Basically this checks to see if there is a default mapping for all logins to the linked server. 
From SSMS it looks like this: (radio button at the bottom).  (so anyone who has access to that server, also can perform "distributor_admin" queries against repl_distributor. ) */
print ''
print '**********************************************************************************************'
print '***** End of Section 11.  config details to validate and improve Database security *****'
print '**********************************************************************************************'
-- END of typical Output Section for Auditing documentation

print '****** other general system database permissions that might help with investigations*********'
PRINT 'Important MSDB permissions to check'
select name from  msdb.sys.objects,msdb.sys.database_permissions  where msdb.sys.database_permissions.major_id=msdb.sys.objects.object_id  and name in ('sp_add_job')   and STATE <> 'D' and  STATE <> 'R'  and grantee_principal_id=0 

PRINT 'Important MSDB Grants Grantees'
select 'db = ' + db_name () +': grantee = ' + su.name  + ' : Object_name = ' + so.name  from  msdb.dbo.sysobjects so,msdb.dbo.syspermissions sp, dbo.sysusers su  where sp.id=so.id  and su.uid = sp.grantee  and so.name in ('sp_get_dtspackage')   and actadd>0 and actmod=0 and sp.grantee=0 

print 'Grantees to specific high risk stored procs in master (no results mean good)'
SELECT DISTINCT user_name(prv.grantee_principal_id) AS Grantee FROM sys.database_permissions prv WHERE object_name(prv.major_id) IN ('sp_OACreate','sp_OAMethod','sp_OADestroy','sp_OASetProperty','sp_OAGetErrorInfo','sp_OAStop','sp_OAGetProperty')

PRINT 'Who sees syscomments and sp_helptext  (no results mean good)'
SELECT  user_name(prv.grantee_principal_id) "Grantee", object_name(prv.major_id) "ObjectName", prv.permission_name "Privilege" FROM sys.database_permissions prv WHERE object_name(prv.major_id) in ('syscomments', 'sp_helptext') and prv.state not in ('D','R')



print '**********************************************************************************************'
print '***** CIS Section Check.  BEGIN details on where to reduce database server vulnerabilities *****'
print '**********************************************************************************************'

PRINT '**********************************************************************************************************************' 
PRINT 'some specific values for CIS standards that may be enabled on company systems (test exceptions for vulnerability scans)' 
PRINT 'Pay special attention to the RUN_VALUE column Flag (1/0 True/False)'

PRINT 'Even if a setting is non-standard, there may be an application or requirement for development setting that persists'

PRINT 'Tread lightly, but continuously with hardening, if possible'

print 'CIS SQL2000 v1.0 Item # 2.2 - patch level'
PRINT 'SQL Server Version (a repeat of above, but CIS focus, see configuration output above for all)' 
select @@version
print 'Which SQL Server Service Pack is installed'
SELECT SERVERPROPERTY('ProductLevel') as SP_installed;

-- thanks to these enhancements, we have been able to customise several servers to improve their score -- since some of these options are better than standard on certain sox servers, thus score >80%
-- average jump with our latest 30 test exceptions, plus close CIS checks, improve score 6-7%

PRINT 'Microsoft Server Version Number (not SQL patch level)' 
select @@Microsoftversion

PRINT 'CIS SQL2005 v1.1.1 Item # 4.20'
-- Guest connection is revoked in hardening already, let's validate more
PRINT 'No Public Or Guest Predefined Role Authorization'
USE model -- add [database_name]; -- roll through all code to create (cursor like the grants one from gdmmonitor from ibm) 
GO 
SELECT DB_NAME() AS DBName, dpr.name, dpe.permission_name FROM sys.database_permissions dpe JOIN sys.database_principals dpr ON dpe.grantee_principal_id=dpr.principal_id WHERE dpr.name='guest' AND dpe.permission_name='CONNECT'; 
--other useful checks, per database - please add script to roll through each DB
PRINT 'DOES The GUEST User have Access (In Model)?'
SELECT usr.name FROM .dbo.sysusers usr WHERE usr.name = 'guest' AND usr.issqluser = 1 AND usr.hasdbaccess = 1

Use Master
go
PRINT 'DOES The GUEST User have Access? In Master? (cannot revoke)'
SELECT usr.name FROM .dbo.sysusers usr WHERE usr.name = 'guest' AND usr.issqluser = 1 AND usr.hasdbaccess = 1


PRINT ' Windows versus SQL Mixed Mode Authenitcation, standard=0'
Select SERVERPROPERTY('IsIntegratedSecurityOnly')
Print 'If Integrated Security =1, then Windows Authentication'

PRINT 'CIS SQL2000 v1.0 Item # 2.9'
PRINT 'Allow Updates To System Tables Is Off  1=Yes, 0=NO (1=BAD, not standard)'
use master
go
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'ALLOW UPDATES';

print 'CIS SQL2005 v1.2.0 Item # 2.3'
PRINT 'Default ports are to be avoided,  we usually set to ports to internal standard'
select local_tcp_port, * from sys.dm_exec_connections  
PRINT 'you should see TCP and Shared Memory per standard, and also Named Pipes if FTIndexing used'
print 'DBAs should Named Pipes protocol, as well as disable FTE service'

PRINT 'CIS SQL2005 v2.0.0 Item # 1.7.1'
PRINT 'Are Named Pipes Enabled (if Full Text used, should be) otherwise default build it TCP/Shared Memory only'
select local_tcp_port, * from sys.dm_exec_connections  where net_transport not in ('tcp','shared memory')

print 'CIS SQL2005 v1.1.1 Item # 9.1'
print '**** ARE ADHOC Distributed QUERIES ENABLED?  1=Yes, 0=NO (preferably non Standard, thus =0)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'ad hoc distributed queries';

print 'CIS SQL2005 v1.1.1 Item # 9.2 or SQL2012 Item # 2.3'
PRINT 'Is CLR Enabled?  1=Yes, 0=NO (For most, non Standard, thus =0)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'clr enabled';

print 'CIS SQL2005 v1.1.1 Item # 3.2.4'
PRINT 'Are Cross Database Ownerships Enabled?  1=Yes, 0=NO'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Cross db ownership chaining';

Print 'CIS SQL2005 v1.1.1 Item # 9.9'
PRINT 'Are there any web tasks?'
SELECT  distinct su.name  + ' ' + owner.name  + '.' + db_name() + '.' + so.name  FROM     dbo.sysprotects sp, dbo.sysusers su, dbo.sysobjects so, dbo.sysusers owner  WHERE     sp.uid = su.uid   and sp.id = so.id   and owner.uid = so.uid   and so.name in ('mswebtasks','xp_runwebtask')   and su.name = 'public' 

PRINT 'CIS SQL2008 R2 V1 Item # 2.14'
Print 'Is the SA account disabled? (results bad is IS_Disabled=0, empty better)'
SELECT * FROM sys.server_principals WHERE name= 'sa'

print 'CIS SQL2008 R2 V1 Item # 2.13' 
print 'how to show that a sql server instance is hidden?'
-- cannot find out how to get this, just a physical option check - maybe registry?

print 'CIS SQL2005 v1.1.1 Item # 3.14 or SQL2012 Item #2.5'
PRINT 'Is OLE automation Enabled? (It is our Standard to be =1, but if 0, more secure)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Ole Automation Procedures';

print 'CIS SQL2005 v1.1.1 Item # 3.15'
print 'Access to Registry Access Extended Stored Procedures (MASTER database)'
select OBJECT_NAME(major_id) as 'extended_procedure', permission_name, 'PUBLIC' as 'to_principal'
from sys.database_permissions where OBJECT_NAME(major_id) like 'XP_%'
AND [type] = 'EX' AND grantee_principal_id = 0
order by 'extended_procedure';
-- fix with --REVOKE EXECUTE on xp_instance_regread to [public]   -- Changed from DENNY to REVOKE  on Oct. 289, 2015
--REVOKE EXECUTE on xp_regread to [public] -- MEANS that each group of users needs Grant Execute on xp_ to Group

print 'CIS SQL2000 v1.0 Item # 3.16'
print 'Is there access to SNMP extended procedures?'
-- don't know the query for this yet

PRINT 'CIS SQL Item # 2.6'
PRINT 'Is Remote Access Enabled? (It is Standard to be =1)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Remote access';

PRINT 'CIS SQL Item # 2.8'
PRINT 'Are Start-up Procedures Enabled (It is Standard to be =1)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Scan for startup procs';

PRINT 'CIS SQL2012 Item # 2.7'
PRINT ' Are Remote Admin Connections Enabled?  1=Yes, 0=NO (It is Standard to be =1, but =0 better)'
USE master; 
GO 
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Remote admin connections' AND SERVERPROPERTY('IsClustered') = 0;

PRINT 'Is SQL Mail Enabled? (It is Not Standard, thus no results)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'SQL Mail XPs';

PRINT 'Is Database Mail Enabled? (It is Standard to be =1)'
SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Database Mail XPs';

PRINT 'Is XP_CMDSHELL Enabled? (It is Standard to be =1)'
EXECUTE sp_configure 'show advanced options',1; RECONFIGURE WITH OVERRIDE; EXECUTE sp_configure 'xp_cmdshell'; 

Print 'Which Login Mode is Enabled? ( Mode is Mixed)'
exec xp_loginconfig 'login mode';

Print 'Login Audit Level? ( standard is Failed Only, but if ALL even better)'
exec XP_loginconfig 'audit level';

print 'The time this audit review report was run on this server'
select Getdate()

print 'latest error log for date above'
exec xp_readerrorlog

PRINT '*************************************************************************************'
PRINT '*******END FULL Updated Audit Review Report for SQL Server February 2016 ************'
PRINT '******* including CIS stds to watch for vulnerabilities and hrdng validations *******'
PRINT '**************************************************************************************'

/*
-- add insert date for local sql dba utility database for all these important base security tables to be stored regularly
use AlithyaDBAUtility 
go -- load audit info, cross cut in time into dba tools database (to be centralized on X)


select   [configuration_id]
      ,[name]
      ,[value]
      ,[minimum]
      ,[maximum]
      ,[value_in_use]
      ,[description]
      ,[is_dynamic]
      ,[is_advanced]
      ,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as ServerName, 
	  SERVERPROPERTY('InstanceName') as InstanceName, 
	  SERVERPROPERTY('ProductLevel') as SP_installed,
	SERVERPROPERTY('ProductVersion') as SQLVersion,
	SERVERPROPERTY('IsIntegratedSecurityOnly') as WindowsAuthentificationOnly
	   into [dbo].dbaSysConfiguration
		from master.sys.Configurations

			ALTER TABLE dbo.dbaSysConfiguration
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())
-- master sys database principals

SELECt [name]
      ,[principal_id]
      ,[type]
      ,[type_desc]
      ,[default_schema_name]
      ,[create_date]
      ,[modify_date]
      ,[owning_principal_id]
      ,[sid]
      ,[is_fixed_role]
      ,[authentication_type]
      ,[authentication_type_desc]
      ,[default_language_name]
      ,[default_language_lcid] 
	   into dbaSysDatabase_principals
FROM master.sys.database_principals

ALTER TABLE dbo.dbaSysDatabase_principals
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())

USE AlithyaDBAUtility
GO --truncate table dbaSysServerPermissions

SELECT [class]
      ,[class_desc]
      ,[major_id]
      ,[minor_id]
      ,[grantee_principal_id]
      ,[grantor_principal_id]
      ,[type]
      ,[permission_name]
      ,[state]
      ,[state_desc]
	  into dbaSysServer_Permissions
FROM master.sys.server_permissions

ALTER TABLE dbo.dbaSysServer_Permissions
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())

USE AlithyaDBAUtility
GO 
Select [class]
      ,[class_desc]
      ,[major_id]
      ,[minor_id]
      ,[grantee_principal_id]
      ,[grantor_principal_id]
      ,[type]
      ,[permission_name]
      ,[state]
      ,[state_desc]
	   into dbaSysDatabase_Permissions 
FROM master.sys.database_permissions

ALTER TABLE dbo.dbaSysDatabase_Permissions
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())

USE AlithyaDBAUtility
GO 
select [name]
      ,[principal_id]
      ,[sid]
      ,[type]
      ,[type_desc]
      ,[is_disabled]
      ,[create_date]
      ,[modify_date]
      ,[default_database_name]
      ,[default_language_name]
      ,[credential_id]
      ,[owning_principal_id]
      ,[is_fixed_role]
INTO  dbaSysServer_Principals
FROM master.sys.server_principals

ALTER TABLE dbo.dbaSysServer_Principals
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())

USE AlithyaDBAUtility
GO 
select [uid]
      ,[status]
      ,[name]
      ,[sid]
      ,[roles]
      ,[createdate]
      ,[updatedate]
      ,[altuid]
      ,[password]
      ,[gid]
      ,[environ]
      ,[hasdbaccess]
      ,[islogin]
      ,[isntname]
      ,[isntgroup]
      ,[isntuser]
      ,[issqluser]
      ,[isaliased]
      ,[issqlrole]
      ,[isapprole]
 into dbaSysUsers
FROM master.sys.sysusers

ALTER TABLE dbo.dbaSysUsers
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())

USE AlithyaDBAUtility
GO 
select  [servicename]
      ,[startup_type]
      ,[startup_type_desc]
      ,[status]
      ,[status_desc]
      ,[process_id]
      ,[last_startup_time]
      ,[service_account]
      ,[filename]
      ,[is_clustered]
      ,[cluster_nodename]
 into dbaSysDM_Server_Services
from master.sys.dm_server_services

	  ALTER TABLE dbo.dbaSysDM_Server_Services
		ADD dbaInsertedDate DATETIME DEFAULT (GETDATE())

USE AlithyaDBAUtility
GO 
select [session_id]
      ,[most_recent_session_id]
      ,[connect_time]
      ,[net_transport]
      ,[protocol_type]
      ,[protocol_version]
      ,[endpoint_id]
      ,[encrypt_option]
      ,[auth_scheme]
      ,[node_affinity]
      ,[num_reads]
      ,[num_writes]
      ,[last_read]
      ,[last_write]
      ,[net_packet_size]
      ,[client_net_address]
      ,[client_tcp_port]
      ,[local_net_address]
      ,[local_tcp_port]
      ,[connection_id]
      ,[parent_connection_id]
      ,[most_recent_sql_handle]
	  into dbaSysDM_Exec_Connections
from master.sys.dm_exec_connections

USE alithyaDBAUtility
GO -- run this only when absolutely necesary, and if the data is needed backup first
-- move to secure auditing central server first once backed up
TRUNCATE TABLE dbo.dbaSysDM_Exec_Connections
TRUNCATE TABLE dbo.dbaSysConfiguration
TRUNCATE TABLE dbaSysDM_Server_Services
TRUNCATE TABLE dbaSysUsers
TRUNCATE TABLE dbaSysServer_Principals
TRUNCATE TABLE dbaSysDatabase_Permissions
TRUNCATE TABLE dbaSysServer_Permissions
TRUNCATE TABLE dbaSysDatabase_principals

-- now create daily job to populate

USE [msdb]
GO

/****** Object:  Job [DBA_Audit-SysUser-Databases]    Script Date: 2018-07-16 3:59:45 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 2018-07-16 3:59:45 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Audit-SysUser-Databases', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This audit job depends on the exitence of a utility DB to store the permissions, principals, users, services and connection detail on a daily basis. Not an Ola Hellengren script, created by H. Shebbeare based on sql server auditing blog posts on sql server central. Change Job Owner to the Service Account before running.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'ALILPT043\SQL2017', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Insert into Audit tables (configuration, users, permissions, exec connections, services)]    Script Date: 2018-07-16 3:59:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insert into Audit tables (configuration, users, permissions, exec connections, services)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
 Insert into [dbo].dbaSysConfiguration
  ([configuration_id]
           ,[name]
          ,[value]
           ,[minimum]
           ,[maximum]
           ,[value_in_use]
           ,[description]
           ,[is_dynamic]
           ,[is_advanced]
           ,[ServerName]
           ,[InstanceName]
           ,[SP_installed]
           ,[SQLVersion]
           ,[WindowsAuthentificationOnly])
select   [configuration_id]
      ,[name]
      ,[value]
      ,[minimum]
      ,[maximum]
      ,[value_in_use]
      ,[description]
      ,[is_dynamic]
      ,[is_advanced]
      ,SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') as ServerName, 
	  SERVERPROPERTY(''InstanceName'') as InstanceName, 
	  SERVERPROPERTY(''ProductLevel'') as SP_installed,
	SERVERPROPERTY(''ProductVersion'') as SQLVersion,
	SERVERPROPERTY(''IsIntegratedSecurityOnly'') as WindowsAuthentificationOnly
	from master.sys.Configurations

insert into dbo.dbaSysDatabase_principals ([name]
      ,[principal_id]
      ,[type]
      ,[type_desc]
      ,[default_schema_name]
      ,[create_date]
      ,[modify_date]
      ,[owning_principal_id]
      ,[sid]
      ,[is_fixed_role]
      ,[authentication_type]
      ,[authentication_type_desc]
      ,[default_language_name]
      ,[default_language_lcid])
SELECt [name]
      ,[principal_id]
      ,[type]
      ,[type_desc]
      ,[default_schema_name]
      ,[create_date]
      ,[modify_date]
      ,[owning_principal_id]
      ,[sid]
      ,[is_fixed_role]
      ,[authentication_type]
      ,[authentication_type_desc]
      ,[default_language_name]
      ,[default_language_lcid] 
FROM master.sys.database_principals

GO --truncate table dbaSysServerPermissions
Insert into dbo.dbaSysServer_Permissions
	([class]
      ,[class_desc]
      ,[major_id]
      ,[minor_id]
      ,[grantee_principal_id]
      ,[grantor_principal_id]
      ,[type]
      ,[permission_name]
      ,[state]
      ,[state_desc])
SELECT [class]
      ,[class_desc]
      ,[major_id]
      ,[minor_id]
      ,[grantee_principal_id]
      ,[grantor_principal_id]
      ,[type]
      ,[permission_name]
      ,[state]
      ,[state_desc]
FROM master.sys.server_permissions

insert into dbo.dbaSysDatabase_Permissions 
		([class]
      ,[class_desc]
      ,[major_id]
      ,[minor_id]
      ,[grantee_principal_id]
      ,[grantor_principal_id]
      ,[type]
      ,[permission_name]
      ,[state]
      ,[state_desc])
Select [class]
      ,[class_desc]
      ,[major_id]
      ,[minor_id]
      ,[grantee_principal_id]
      ,[grantor_principal_id]
      ,[type]
      ,[permission_name]
      ,[state]
      ,[state_desc]
FROM master.sys.database_permissions

insert into dbo.dbaSysServer_Principals
	([name]
      ,[principal_id]
      ,[sid]
      ,[type]
      ,[type_desc]
      ,[is_disabled]
      ,[create_date]
      ,[modify_date]
      ,[default_database_name]
      ,[default_language_name]
      ,[credential_id]
      ,[owning_principal_id]
      ,[is_fixed_role])
select [name]
      ,[principal_id]
      ,[sid]
      ,[type]
      ,[type_desc]
      ,[is_disabled]
      ,[create_date]
      ,[modify_date]
      ,[default_database_name]
      ,[default_language_name]
      ,[credential_id]
      ,[owning_principal_id]
      ,[is_fixed_role]
FROM master.sys.server_principals

insert into dbo.dbaSysUsers
	([uid]
      ,[status]
      ,[name]
      ,[sid]
      ,[roles]
      ,[createdate]
      ,[updatedate]
      ,[altuid]
      ,[password]
      ,[gid]
      ,[environ]
      ,[hasdbaccess]
      ,[islogin]
      ,[isntname]
      ,[isntgroup]
      ,[isntuser]
      ,[issqluser]
      ,[isaliased]
      ,[issqlrole]
      ,[isapprole])
select [uid]
      ,[status]
      ,[name]
      ,[sid]
      ,[roles]
      ,[createdate]
      ,[updatedate]
      ,[altuid]
      ,[password]
      ,[gid]
      ,[environ]
      ,[hasdbaccess]
      ,[islogin]
      ,[isntname]
      ,[isntgroup]
      ,[isntuser]
      ,[issqluser]
      ,[isaliased]
      ,[issqlrole]
      ,[isapprole]
FROM master.sys.sysusers

insert into dbo.dbaSysDM_Server_Services
	([servicename]
      ,[startup_type]
      ,[startup_type_desc]
      ,[status]
      ,[status_desc]
      ,[process_id]
      ,[last_startup_time]
      ,[service_account]
      ,[filename]
      ,[is_clustered]
      ,[cluster_nodename])
select  [servicename]
      ,[startup_type]
      ,[startup_type_desc]
      ,[status]
      ,[status_desc]
      ,[process_id]
      ,[last_startup_time]
      ,[service_account]
      ,[filename]
      ,[is_clustered]
      ,[cluster_nodename]
from master.sys.dm_server_services

insert into dbo.dbaSysDM_Exec_Connections
	([session_id]
      ,[most_recent_session_id]
      ,[connect_time]
      ,[net_transport]
      ,[protocol_type]
      ,[protocol_version]
      ,[endpoint_id]
      ,[encrypt_option]
      ,[auth_scheme]
      ,[node_affinity]
      ,[num_reads]
      ,[num_writes]
      ,[last_read]
      ,[last_write]
      ,[net_packet_size]
      ,[client_net_address]
      ,[client_tcp_port]
      ,[local_net_address]
      ,[local_tcp_port]
      ,[connection_id]
      ,[parent_connection_id]
      ,[most_recent_sql_handle])
select [session_id]
      ,[most_recent_session_id]
      ,[connect_time]
      ,[net_transport]
      ,[protocol_type]
      ,[protocol_version]
      ,[endpoint_id]
      ,[encrypt_option]
      ,[auth_scheme]
      ,[node_affinity]
      ,[num_reads]
      ,[num_writes]
      ,[last_read]
      ,[last_write]
      ,[net_packet_size]
      ,[client_net_address]
      ,[client_tcp_port]
      ,[local_net_address]
      ,[local_tcp_port]
      ,[connection_id]
      ,[parent_connection_id]
      ,[most_recent_sql_handle]
from master.sys.dm_exec_connections', 
		@database_name=N'AlithyaDBAUtility', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [setup permissions (example to change and run once)]    Script Date: 2018-07-16 3:59:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'setup permissions (example to change and run once)', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [AlithyaDBAUtility]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [dbo]
GO
USE [master]
GO
CREATE USER [hshebbeare] FOR LOGIN [GCOSI\hshebbeare] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [master]
GO
ALTER ROLE [db_owner] ADD MEMBER [hshebbeare]
GO
USE [AlithyaDBAUtility]
GO
ALTER ROLE [db_owner] ADD MEMBER [hshebbeare]', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clean Out Audit Tables (not scheduled, run manually only when backup done and necessary for space)]    Script Date: 2018-07-16 3:59:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clean Out Audit Tables (not scheduled, run manually only when backup done and necessary for space)', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'TRUNCATE TABLE dbo.dbaSysDM_Exec_Connections
TRUNCATE TABLE dbo.dbaSysConfiguration
TRUNCATE TABLE dbo.dbaSysDM_Server_Services
TRUNCATE TABLE dbo.dbaSysUsers
TRUNCATE TABLE dbo.dbaSysServer_Principals
TRUNCATE TABLE dbo.dbaSysDatabase_Permissions
TRUNCATE TABLE dbo.dbaSysServer_Permissions
TRUNCATE TABLE dbo.dbaSysDatabase_principals
', 
		@database_name=N'AlithyaDBAUtility', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180716, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'1e4c3e58-3a7e-4ece-8544-e26702a1aa64'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
*/