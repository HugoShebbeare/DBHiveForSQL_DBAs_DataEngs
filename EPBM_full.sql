--- latest policies, Oct 2020
/*-- add missing categories
Microsoft Off by Default: Surface Area Configuration
Microsoft Best Practices: Windows Log File
Microsoft Best Practices: Server Configuration
Microsoft Best Practices: Security
Microsoft Best Practices: Performance
Microsoft Best Practices: Maintenance
Microsoft Best Practices: Database Design
Microsoft Best Practices: Database Configurations
Microsoft Best Practices: Audit
Lowes Policies - Best Practices
Lowes Policies - Backups
*/
USE msdb;  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Lowes Policies - Backups';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Lowes Policies - Best Practices';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Audit';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Off by Default: Surface Area Configuration';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Windows Log File';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Server Configuration';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Security';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Performance';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Maintenance';  
GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Database Design';  

GO  
EXEC dbo.sp_syspolicy_add_policy_category_subscription @target_type = N'database'  
, @target_object = N'master'  
, @policy_category = N'Microsoft Best Practices: Database Configurations';  

	-- validate that the categories are there by right click on policies, Manage Categories,
	--otherwise add them when policies fail to be added 
	
--- CONDITIONS NTXT
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'64-bit Affinity Mask Overlapped', @description=N'Confirms that the same CPUs are not enabled with both the affinity mask option and the affinity I/O mask option, which can slow performance.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>BitwiseAnd</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>AffinityMask</Name>
                        </Attribute>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>AffinityIOMask</Name>
                        </Attribute>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>BitwiseAnd</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>Affinity64Mask</Name>
                        </Attribute>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>Affinity64IOMask</Name>
                        </Attribute>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'64-bit Configuration', @description=N'Confirms that the version of SQL Server uses 64-bit configuration.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>OR</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>String</TypeClass>
                        <Name>Platform</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>NT AMD64</Value>
                        </Constant>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>String</TypeClass>
                        <Name>Platform</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>NT INTEL IA64</Value>
                        </Constant>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'64-bit Configuration of SQL Server Version 2000', @description=N'Confirms that the version of SQL Server is 2000 and uses 64-bit configuration.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Group>
                        <TypeClass>Bool</TypeClass>
                        <Count>1</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>OR</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>String</TypeClass>
                        <Name>Platform</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>NT AMD64</Value>
                        </Constant>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>String</TypeClass>
                        <Name>Platform</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>NT INTEL IA64</Value>
                        </Constant>
                        </Operator>
                        </Operator>
                        </Group>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>VersionMajor</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>8</Value>
                        </Constant>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Affinity Mask Default', @description=N'Confirms whether the setting affinity mask of server is set to zero.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>AffinityMask</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Are there Disabled logins (sp_validateLogins)', @description=N'', @facet=N'Login', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>OR</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>OR</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Bool</TypeClass>
        <Name>IsDisabled</Name>
      </Attribute>
      <Function>
        <TypeClass>Bool</TypeClass>
        <FunctionType>False</FunctionType>
        <ReturnType>Bool</ReturnType>
        <Count>0</Count>
      </Function>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>NE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>String</TypeClass>
        <Name>Name</Name>
      </Attribute>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>##MS_PolicyEventProcessingLogin##</Value>
      </Constant>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>NE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>String</TypeClass>
      <Name>Name</Name>
    </Attribute>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>##MS_PolicyTsqlExecutionLogin##</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Auto Close Disabled', @description=N'Confirms that the AUTO_CLOSE database option is set to off.', @facet=N'IDatabasePerformanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>AutoClose</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>False</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Auto Shrink Disabled', @description=N'Confirms that the AUTO_SHRINK database option is set to off.', @facet=N'IDatabasePerformanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>AutoShrink</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>False</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Auto-configured Dynamic Locks', @description=N'Confirms that the locks option is set to zero. This is the recommended default value.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>DynamicLocks</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Auto-configured Maximum Worker Threads', @description=N'Confirms that the maximum worker threads server option value is set to the recommended value for instances of SQL Server 2005 and later versions.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>MaxWorkerThreads</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Auto-configured Open Objects', @description=N'Confirms that the open objects server option is set to the recommended value of 0.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>OpenObjects</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Blocked Process Threshold Optimized', @description=N'Confirms that the blocked process threshold property is set higher than 4, or is disabled (0).', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>OR</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>GE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>BlockedProcessThreshold</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>5</Value>
                        </Constant>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>BlockedProcessThreshold</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'CLR is Disabled', @description=N'', @facet=N'IServerConfigurationFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>ClrIntegrationEnabled</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>True</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Cluster Disk Resource Corruption Error Check', @description=N'Confirms that an ESCSI host adapter configuration issue or a malfunctioning device error (Event ID –1066) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=1066 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'CmdExec Rights for sysadmins Only', @description=N'Confirms that only members of the sysadmin fixed server role can execute CmdExec and ActiveX Script job steps. Applies only to SQL Server 2000.', @facet=N'IServerSecurityFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>CmdExecRightsForSystemAdminsOnly</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>True</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Collation Matches master or model', @description=N'Confirms that the collation of the database matches the master or model databases.', @facet=N'IDatabasePerformanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>CollationMatchesModelOrMaster</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>True</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Data and Backup on Separate Drive', @description=N'Confirms that the database and the database backups are on separate drives.', @facet=N'IDatabaseMaintenanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>DataAndBackupOnSeparateLogicalVolumes</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>True</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Data and Log Files on Separate Drives', @description=N'Confirms that data and log files are placed on separate drives.', @facet=N'IDatabasePerformanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>OR</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>OR</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>OR</OpType>
      <Count>2</Count>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>EQ</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>Bool</TypeClass>
          <Name>DataAndLogFilesOnSeparateLogicalVolumes</Name>
        </Attribute>
        <Function>
          <TypeClass>Bool</TypeClass>
          <FunctionType>True</FunctionType>
          <ReturnType>Bool</ReturnType>
          <Count>0</Count>
        </Function>
      </Operator>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>LT</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>Numeric</TypeClass>
          <Name>Size</Name>
        </Attribute>
        <Constant>
          <TypeClass>Numeric</TypeClass>
          <ObjType>System.Int32</ObjType>
          <Value>5120</Value>
        </Constant>
      </Operator>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>NE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>Status</Name>
      </Attribute>
      <Function>
        <TypeClass>Numeric</TypeClass>
        <FunctionType>Enum</FunctionType>
        <ReturnType>Numeric</ReturnType>
        <Count>2</Count>
        <Constant>
          <TypeClass>String</TypeClass>
          <ObjType>System.String</ObjType>
          <Value>Microsoft.SqlServer.Management.Smo.DatabaseStatus</Value>
        </Constant>
        <Constant>
          <TypeClass>String</TypeClass>
          <ObjType>System.String</ObjType>
          <Value>Normal</Value>
        </Constant>
      </Function>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Bool</TypeClass>
      <Name>IsSystemObject</Name>
    </Attribute>
    <Function>
      <TypeClass>Bool</TypeClass>
      <FunctionType>True</FunctionType>
      <ReturnType>Bool</ReturnType>
      <Count>0</Count>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Database owner is SA', @description=N'', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>OR</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>OR</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>OR</OpType>
      <Count>2</Count>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>OR</OpType>
        <Count>2</Count>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>EQ</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>String</TypeClass>
            <Name>Owner</Name>
          </Attribute>
          <Constant>
            <TypeClass>String</TypeClass>
            <ObjType>System.String</ObjType>
            <Value>sa</Value>
          </Constant>
        </Operator>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>NE</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>Numeric</TypeClass>
            <Name>ID</Name>
          </Attribute>
          <Constant>
            <TypeClass>Numeric</TypeClass>
            <ObjType>System.Double</ObjType>
            <Value>5</Value>
          </Constant>
        </Operator>
      </Operator>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>NE</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>Numeric</TypeClass>
          <Name>ID</Name>
        </Attribute>
        <Constant>
          <TypeClass>Numeric</TypeClass>
          <ObjType>System.Double</ObjType>
          <Value>6</Value>
        </Constant>
      </Operator>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>NE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>ID</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>7</Value>
      </Constant>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>NE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>ID</Name>
    </Attribute>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>8</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Database Owner Not sysadmin', @description=N'Confirms that no login in the db_owner role has sysadmin privileges.', @facet=N'IDatabaseSecurityFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>IsOwnerSysadmin</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>False</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Database Status', @description=N'', @facet=N'IDatabasePerformanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>Status</Name>
  </Attribute>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>Enum</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Microsoft.SqlServer.Management.Smo.DatabaseStatus</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Normal</Value>
    </Constant>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'DataFile Autogrowth Less than 8MB Condition', @description=N'', @facet=N'DataFile', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>GE</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>Growth</Name>
  </Attribute>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>8192</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Default DB is not master DB', @description=N'', @facet=N'Login', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>NE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>String</TypeClass>
      <Name>DefaultDatabase</Name>
    </Attribute>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>master</Value>
    </Constant>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>NOT_LIKE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>String</TypeClass>
      <Name>Name</Name>
    </Attribute>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>%NT%</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Default Trace Enabled', @description=N'Confirms that the default trace enabled options is turned on.', @facet=N'IServerAuditFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>DefaultTraceEnabled</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Device Driver Control Error Check', @description=N'Confirms that an I/O time-out event error (Event ID -11) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=11 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Device Not Ready Error Check', @description=N'Confirms that a Device Not Ready Error (Event ID –15) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=15 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Disk Defragmentation Resulting Data Corruption', @description=N'Confirms that disk defragmentation resulting data corruption (Event ID –55) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=55 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Endpoint Disabled', @description=N'Confirms that the state of endpoint is disabled.', @facet=N'Endpoint', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>EndpointState</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.EndpointState</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Disabled</Value>
                        </Constant>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Endpoint Stopped', @description=N'Confirms that the state of endpoint is stopped.
Service Broker is required for SCCM', @facet=N'Endpoint', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>EndpointState</Name>
  </Attribute>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>Enum</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Microsoft.SqlServer.Management.Smo.EndpointState</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Started</Value>
    </Constant>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Enterprise or Standard Edition', @description=N'Confirms that the instance of SQL Server is either Enterprise or Standard Edition.', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>OR</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>EngineEdition</Name>
    </Attribute>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>Enum</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Microsoft.SqlServer.Management.Smo.Edition</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Standard</Value>
      </Constant>
    </Function>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>EngineEdition</Name>
    </Attribute>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>Enum</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Microsoft.SqlServer.Management.Smo.Edition</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>EnterpriseOrDeveloper</Value>
      </Constant>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Fail For Any Symmetric Key', @description=N'Confirms that symmetric keys in the database fail this condition.', @facet=N'SymmetricKey', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>False</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Failed I/O Request Check', @description=N'Confirms that a failed I/O request (Event ID 50) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=50 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'File is 1GB or Larger', @description=N'Confirms that the file size is larger than 1 GB.', @facet=N'DataFile', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>GE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>Size</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>1024</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Fill Factor', @description=N'Checks for Fill Factor Not Set.', @facet=N'Index', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>LT</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>FillFactor</Name>
  </Attribute>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>0</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Growth Type Not Percent', @description=N'Confirms that the file growth type is not percent.', @facet=N'DataFile', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>NE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Unsupported</TypeClass>
                        <Name>GrowthType</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>Microsoft.SqlServer.Management.Smo.FileGrowthType</ObjType>
                        <Value>Percent</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Guest', @description=N'The user is the Guest account.', @facet=N'User', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Unsupported</TypeClass>
    <Name>Name</Name>
  </Attribute>
  <Constant>
    <TypeClass>String</TypeClass>
    <ObjType>System.String</ObjType>
    <Value>guest</Value>
  </Constant>
</Operator>', @is_name_condition=1, @obj_name=N'guest', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Has No Database Access', @description=N'Confirms that the database user does not have access to the database.', @facet=N'User', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Unsupported</TypeClass>
    <Name>HasDBAccess</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>False</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'I/O Affinity Mask Disabled', @description=N'Confirms that the server I/O affinity mask property is disabled.', @facet=N'IServerConfigurationFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>AffinityIOMask</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'I/O Delay Warning Check', @description=N'Confirms that an I/O delay warning (Event ID 833) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=833 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'I/O Error During Hard Page Fault Error Check', @description=N'Confirms that an I/O Error during hard page fault (Event ID – 51) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=51 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Is master', @description=N'Confirms that the database name is master.', @facet=N'Database', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>String</TypeClass>
                        <Name>Name</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>master</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=1, @obj_name=N'master', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Is Sysadmin Hardened', @description=N'', @facet=N'User', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>ExecuteSql</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Numeric</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>select case when( select Sid from master.sys.syslogins where sid=@sid and name like ''''%NT%'''') is not null then 1 else 0 end</Value>
      </Constant>
    </Function>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>1</Value>
    </Constant>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>NE</OpType>
    <Count>2</Count>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>ExecuteSql</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Numeric</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>select case when( select Sid from master.sys.syslogins where sid=@sid and sysadmin=1) is not null then 1 else 0 end</Value>
      </Constant>
    </Function>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>1</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Key Length Less Than 128 Bytes', @description=N'Confirms that the Symmetric Key KeyLength property is less than 128 bytes.', @facet=N'SymmetricKey', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>LE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>KeyLength</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>128</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Last Backup Within 24 Hrs', @description=N'', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>GE</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>DateTime</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>DateTime</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>datetime</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>select max(Backup_Finish_Date) FROM MSDB.dbo.BackupSet where database_name=db_name()</Value>
    </Constant>
  </Function>
  <Function>
    <TypeClass>DateTime</TypeClass>
    <FunctionType>DateAdd</FunctionType>
    <ReturnType>DateTime</ReturnType>
    <Count>3</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>day</Value>
    </Constant>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>-1</Value>
    </Constant>
    <Function>
      <TypeClass>DateTime</TypeClass>
      <FunctionType>GetDate</FunctionType>
      <ReturnType>DateTime</ReturnType>
      <Count>0</Count>
    </Function>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Lightweight Pooling Disabled', @description=N'Confirms that lightweight pooling is disabled on the server.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>LightweightPoolingEnabled</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>False</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'LogFile Autogrowth Less than 8MB condition', @description=N'', @facet=N'LogFile', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>GE</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>Growth</Name>
  </Attribute>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>8192</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Maintenance Jobs', @description=N'', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>SELECT COUNT([name]) FROM [msdb].[dbo].[sysjobs] WHERE [name] IN (''''DatabaseIntegrityCheck - SYSTEM_DATABASES'''') AND  [enabled] = 1</Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>1</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Maximum Degree of Parallelism Optimized for SQL 2000', @description=N'Confirms that the maximum degree of parallelism is less than 8. Eight is optimal.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>LE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>MaxDegreeOfParallelism</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>8</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Maximum Worker Threads for 64-bit Configuration Optimized', @description=N'Confirms that the maximum worker threads server option value is set to the recommended value for instances of SQL Server 2000 that are running on a 64-bit server.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>GE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>MaxWorkerThreads</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>500</Value>
                        </Constant>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>LE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>MaxWorkerThreads</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>2000</Value>
                        </Constant>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Microsoft Service Master Key', @description=N'
                        Confirms that the symmetric key is the Service Master Key.
                        
                        The Service Master Key is the root of the SQL Server encryption hierarchy. It is generated automatically the first time it is needed to encrypt another key. By default, the Service Master Key is encrypted using the Windows data protection API and using the local machine key. The Service Master Key can only be opened by the Windows service account under which it was created or by a principal with access to both the service account name and its password.
                        
                        Regenerating or restoring the Service Master Key involves decrypting and re-encrypting the complete encryption hierarchy. Unless the key has been compromised, this resource-intensive operation should be scheduled during a period of low demand.
                      ', @facet=N'SymmetricKey', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Unsupported</TypeClass>
                        <Name>Name</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>##MS_ServiceMasterKey##</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=1, @obj_name=N'##MS_ServiceMasterKey##', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Named Pipes Disabled', @description=N'', @facet=N'IServerSetupFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>NamedPipesEnabled</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>False</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Network Packet Size Optimized', @description=N'Confirms that the value specified for network packet size server option does not exceed 8060 bytes.', @facet=N'IServerPerformanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>LE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>NetworkPacketSize</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>8060</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'No Suspect Database Pages', @description=N'Confirms that the current database has no suspect database pages.  A database page is set as suspect by error 824, which indicates that a logical consistency error was detected during a read operation.', @facet=N'IDatabaseMaintenanceFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>SELECT COUNT(*) AS [Total_Suspect_Pages] FROM msdb.dbo.suspect_pages WHERE event_type IN (1,2,3) AND database_id = DB_ID(DB_NAME()) </Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Int32</ObjType>
    <Value>0</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Not Enterprise Edition', @description=N'Confirms that the instance of SQL Server is not Enterprise Edition.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>NE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>EngineEdition</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.Edition</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>EnterpriseOrDeveloper</Value>
                        </Constant>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Online User Database', @description=N'Confirms that the database is not a system database and that it is online.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>AND</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>AND</OpType>
      <Count>2</Count>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>AND</OpType>
        <Count>2</Count>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>EQ</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>Bool</TypeClass>
            <Name>IsSystemObject</Name>
          </Attribute>
          <Function>
            <TypeClass>Bool</TypeClass>
            <FunctionType>False</FunctionType>
            <ReturnType>Bool</ReturnType>
            <Count>0</Count>
          </Function>
        </Operator>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>EQ</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>Numeric</TypeClass>
            <Name>Status</Name>
          </Attribute>
          <Function>
            <TypeClass>Numeric</TypeClass>
            <FunctionType>Enum</FunctionType>
            <ReturnType>Numeric</ReturnType>
            <Count>2</Count>
            <Constant>
              <TypeClass>String</TypeClass>
              <ObjType>System.String</ObjType>
              <Value>Microsoft.SqlServer.Management.Smo.DatabaseStatus</Value>
            </Constant>
            <Constant>
              <TypeClass>String</TypeClass>
              <ObjType>System.String</ObjType>
              <Value>Normal</Value>
            </Constant>
          </Function>
        </Operator>
      </Operator>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>NE</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>String</TypeClass>
          <Name>Name</Name>
        </Attribute>
        <Constant>
          <TypeClass>String</TypeClass>
          <ObjType>System.String</ObjType>
          <Value>lowesdba</Value>
        </Constant>
      </Operator>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>NE</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>String</TypeClass>
        <Name>Name</Name>
      </Attribute>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>ReportServer</Value>
      </Constant>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>NE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>String</TypeClass>
      <Name>Name</Name>
    </Attribute>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>ReportServerTempDB</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Page Verify Checksum', @description=N'Confirms that the PAGE_VERIFY database option set to CHECKSUM.', @facet=N'IDatabaseMaintenanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>PageVerify</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>Microsoft.SqlServer.Management.Smo.PageVerify</ObjType>
                        <Value>Checksum</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Password Expiration Enabled', @description=N'Confirms that password expiration is enforced for all SQL Server logins.', @facet=N'ILoginOptions', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>PasswordExpirationEnabled</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Password Policy Enforced', @description=N'Confirms that the enforce password option on SQL Server logins is enabled.', @facet=N'ILoginOptions', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>PasswordPolicyEnforced</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Public Server Role Has No Granted Permissions', @description=N'Confirms that the Server permission is not granted to the Public role.', @facet=N'IServerSecurityFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>PublicServerRoleIsGrantedPermissions</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>False</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Read Retry Error Check', @description=N'Confirms that read retry issues (Event ID 825) do not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=825 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Read-only', @description=N'Confirms that the database ReadOnly property is equal to true.', @facet=N'Database', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>ReadOnly</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>Status</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.DatabaseStatus</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Normal</Value>
                        </Constant>
                        </Function>
                        </Operator>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>IsSystemObject</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>False</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Recovery Model Simple', @description=N'Confirms that the database recovery model is set to simple.', @facet=N'IDatabaseMaintenanceFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>RecoveryModel</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.RecoveryModel</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Simple</Value>
                        </Constant>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'RSA 1024 or RSA 2048 Encrypted', @description=N'Confirms that asymmetric keys were created with 1024-bit encryption or better.', @facet=N'AsymmetricKey', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>OR</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>KeyEncryptionAlgorithm</Name>
    </Attribute>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>Enum</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Microsoft.SqlServer.Management.Smo.AsymmetricKeyEncryptionAlgorithm</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Rsa1024</Value>
      </Constant>
    </Function>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>KeyEncryptionAlgorithm</Name>
    </Attribute>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>Enum</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Microsoft.SqlServer.Management.Smo.AsymmetricKeyEncryptionAlgorithm</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Rsa2048</Value>
      </Constant>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SA account Disabled', @description=N'', @facet=N'Login', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>NE</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>String</TypeClass>
    <Name>Name</Name>
  </Attribute>
  <Constant>
    <TypeClass>String</TypeClass>
    <ObjType>System.String</ObjType>
    <Value>sa</Value>
  </Constant>
</Operator>', @is_name_condition=3, @obj_name=N'sa', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Safe Last Full or Diff Backup Date', @description=N'', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>OR</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>GE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>DateTime</TypeClass>
      <Name>LastBackupDate</Name>
    </Attribute>
    <Function>
      <TypeClass>DateTime</TypeClass>
      <FunctionType>DateAdd</FunctionType>
      <ReturnType>DateTime</ReturnType>
      <Count>3</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>day</Value>
      </Constant>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>-15</Value>
      </Constant>
      <Function>
        <TypeClass>DateTime</TypeClass>
        <FunctionType>GetDate</FunctionType>
        <ReturnType>DateTime</ReturnType>
        <Count>0</Count>
      </Function>
    </Function>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>GE</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>DateTime</TypeClass>
      <Name>LastDifferentialBackupDate</Name>
    </Attribute>
    <Function>
      <TypeClass>DateTime</TypeClass>
      <FunctionType>DateAdd</FunctionType>
      <ReturnType>DateTime</ReturnType>
      <Count>3</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>day</Value>
      </Constant>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>-15</Value>
      </Constant>
      <Function>
        <TypeClass>DateTime</TypeClass>
        <FunctionType>GetDate</FunctionType>
        <ReturnType>DateTime</ReturnType>
        <Count>0</Count>
      </Function>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Service Broker Endpoint', @description=N'Confirms that endpoint is of type Service Broker.', @facet=N'Endpoint', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>EndpointType</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.EndpointType</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>ServiceBroker</Value>
                        </Constant>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Soap Endpoint', @description=N'Confirms that endpoint is of type SOAP.', @facet=N'Endpoint', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>EndpointType</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.EndpointType</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Soap</Value>
                        </Constant>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL 2005 Version Check', @description=N'', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>AND</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>VersionMajor</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>9</Value>
      </Constant>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>VersionMinor</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>BuildNumber</Name>
    </Attribute>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>4035</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL OLE  Automation Disabled', @description=N'', @facet=N'IServerConfigurationFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>OleAutomationEnabled</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>False</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL Server 2000 Version Check', @description=N'', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>AND</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>VersionMajor</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>8</Value>
      </Constant>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>VersionMinor</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>BuildNumber</Name>
    </Attribute>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>2050</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL Server 2008 Version Check', @description=N'', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>AND</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>VersionMajor</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>10</Value>
      </Constant>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Numeric</TypeClass>
        <Name>VersionMinor</Name>
      </Attribute>
      <Constant>
        <TypeClass>Numeric</TypeClass>
        <ObjType>System.Double</ObjType>
        <Value>0</Value>
      </Constant>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Numeric</TypeClass>
      <Name>BuildNumber</Name>
    </Attribute>
    <Constant>
      <TypeClass>Numeric</TypeClass>
      <ObjType>System.Double</ObjType>
      <Value>2531</Value>
    </Constant>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL Server Authenticated Logins', @description=N'', @facet=N'Login', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>LoginType</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.LoginType</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>SqlLogin</Value>
                        </Constant>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL Server Version 2000', @description=N'Confirms that the version of SQL Server is 2000.', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>VersionMajor</Name>
  </Attribute>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Int32</ObjType>
    <Value>8</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL Server Version 2005 or a Later Version', @description=N'Confirms that the version of SQL Server is 2005 or a later version.', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>GE</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>VersionMajor</Name>
  </Attribute>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Int32</ObjType>
    <Value>9</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Storage System I/O Timeout Error Check', @description=N'Confirms that an I/O time-out event error (Event ID -9) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=9 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Strongly Encrypted', @description=N'Confirms that the symmetric key encryption algorithm is neither RC2 nor RC4.', @facet=N'SymmetricKey', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>NE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>EncryptionAlgorithm</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.SymmetricKeyEncryptionAlgorithm</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>RC2</Value>
                        </Constant>
                        </Function>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>NE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Numeric</TypeClass>
                        <Name>EncryptionAlgorithm</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>Enum</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Microsoft.SqlServer.Management.Smo.SymmetricKeyEncryptionAlgorithm</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>RC4</Value>
                        </Constant>
                        </Function>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Surface Area Configuration for Database Engine 2000 Features', @description=N'Confirms that the default surface area settings are set for Database 2000 Engine features.', @facet=N'ISurfaceAreaFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>AND</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>AND</OpType>
      <Count>2</Count>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>AND</OpType>
        <Count>2</Count>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>EQ</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>Bool</TypeClass>
            <Name>AdHocRemoteQueriesEnabled</Name>
          </Attribute>
          <Function>
            <TypeClass>Bool</TypeClass>
            <FunctionType>False</FunctionType>
            <ReturnType>Bool</ReturnType>
            <Count>0</Count>
          </Function>
        </Operator>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>EQ</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>Bool</TypeClass>
            <Name>OleAutomationEnabled</Name>
          </Attribute>
          <Function>
            <TypeClass>Bool</TypeClass>
            <FunctionType>False</FunctionType>
            <ReturnType>Bool</ReturnType>
            <Count>0</Count>
          </Function>
        </Operator>
      </Operator>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>EQ</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>Bool</TypeClass>
          <Name>SqlMailEnabled</Name>
        </Attribute>
        <Function>
          <TypeClass>Bool</TypeClass>
          <FunctionType>False</FunctionType>
          <ReturnType>Bool</ReturnType>
          <Count>0</Count>
        </Function>
      </Operator>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Bool</TypeClass>
        <Name>WebAssistantEnabled</Name>
      </Attribute>
      <Function>
        <TypeClass>Bool</TypeClass>
        <FunctionType>False</FunctionType>
        <ReturnType>Bool</ReturnType>
        <Count>0</Count>
      </Function>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Bool</TypeClass>
      <Name>XPCmdShellEnabled</Name>
    </Attribute>
    <Function>
      <TypeClass>Bool</TypeClass>
      <FunctionType>False</FunctionType>
      <ReturnType>Bool</ReturnType>
      <Count>0</Count>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Surface Area Configuration for Database Engine Features', @description=N'Confirms that the default surface area settings are set for Database 2005 and above Engine features.', @facet=N'ISurfaceAreaFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>AND</OpType>
    <Count>2</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>AND</OpType>
      <Count>2</Count>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>AND</OpType>
        <Count>2</Count>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>AND</OpType>
          <Count>2</Count>
          <Operator>
            <TypeClass>Bool</TypeClass>
            <OpType>AND</OpType>
            <Count>2</Count>
            <Operator>
              <TypeClass>Bool</TypeClass>
              <OpType>AND</OpType>
              <Count>2</Count>
              <Operator>
                <TypeClass>Bool</TypeClass>
                <OpType>AND</OpType>
                <Count>2</Count>
                <Operator>
                  <TypeClass>Bool</TypeClass>
                  <OpType>EQ</OpType>
                  <Count>2</Count>
                  <Attribute>
                    <TypeClass>Bool</TypeClass>
                    <Name>AdHocRemoteQueriesEnabled</Name>
                  </Attribute>
                  <Function>
                    <TypeClass>Bool</TypeClass>
                    <FunctionType>False</FunctionType>
                    <ReturnType>Bool</ReturnType>
                    <Count>0</Count>
                  </Function>
                </Operator>
                <Operator>
                  <TypeClass>Bool</TypeClass>
                  <OpType>EQ</OpType>
                  <Count>2</Count>
                  <Attribute>
                    <TypeClass>Bool</TypeClass>
                    <Name>ClrIntegrationEnabled</Name>
                  </Attribute>
                  <Function>
                    <TypeClass>Bool</TypeClass>
                    <FunctionType>True</FunctionType>
                    <ReturnType>Bool</ReturnType>
                    <Count>0</Count>
                  </Function>
                </Operator>
              </Operator>
              <Operator>
                <TypeClass>Bool</TypeClass>
                <OpType>EQ</OpType>
                <Count>2</Count>
                <Attribute>
                  <TypeClass>Bool</TypeClass>
                  <Name>DatabaseMailEnabled</Name>
                </Attribute>
                <Function>
                  <TypeClass>Bool</TypeClass>
                  <FunctionType>False</FunctionType>
                  <ReturnType>Bool</ReturnType>
                  <Count>0</Count>
                </Function>
              </Operator>
            </Operator>
            <Operator>
              <TypeClass>Bool</TypeClass>
              <OpType>EQ</OpType>
              <Count>2</Count>
              <Attribute>
                <TypeClass>Bool</TypeClass>
                <Name>OleAutomationEnabled</Name>
              </Attribute>
              <Function>
                <TypeClass>Bool</TypeClass>
                <FunctionType>False</FunctionType>
                <ReturnType>Bool</ReturnType>
                <Count>0</Count>
              </Function>
            </Operator>
          </Operator>
          <Operator>
            <TypeClass>Bool</TypeClass>
            <OpType>EQ</OpType>
            <Count>2</Count>
            <Attribute>
              <TypeClass>Bool</TypeClass>
              <Name>RemoteDacEnabled</Name>
            </Attribute>
            <Function>
              <TypeClass>Bool</TypeClass>
              <FunctionType>False</FunctionType>
              <ReturnType>Bool</ReturnType>
              <Count>0</Count>
            </Function>
          </Operator>
        </Operator>
        <Operator>
          <TypeClass>Bool</TypeClass>
          <OpType>EQ</OpType>
          <Count>2</Count>
          <Attribute>
            <TypeClass>Bool</TypeClass>
            <Name>ServiceBrokerEndpointActive</Name>
          </Attribute>
          <Function>
            <TypeClass>Bool</TypeClass>
            <FunctionType>True</FunctionType>
            <ReturnType>Bool</ReturnType>
            <Count>0</Count>
          </Function>
        </Operator>
      </Operator>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>EQ</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>Bool</TypeClass>
          <Name>SoapEndpointsEnabled</Name>
        </Attribute>
        <Function>
          <TypeClass>Bool</TypeClass>
          <FunctionType>False</FunctionType>
          <ReturnType>Bool</ReturnType>
          <Count>0</Count>
        </Function>
      </Operator>
    </Operator>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>EQ</OpType>
      <Count>2</Count>
      <Attribute>
        <TypeClass>Bool</TypeClass>
        <Name>SqlMailEnabled</Name>
      </Attribute>
      <Function>
        <TypeClass>Bool</TypeClass>
        <FunctionType>False</FunctionType>
        <ReturnType>Bool</ReturnType>
        <Count>0</Count>
      </Function>
    </Operator>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Bool</TypeClass>
      <Name>XPCmdShellEnabled</Name>
    </Attribute>
    <Function>
      <TypeClass>Bool</TypeClass>
      <FunctionType>False</FunctionType>
      <ReturnType>Bool</ReturnType>
      <Count>0</Count>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'System Databases Not Including Master', @description=N'Confirms that the database is a system database and its name is not master.', @facet=N'Database', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>AND</OpType>
                        <Count>2</Count>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>NE</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>String</TypeClass>
                        <Name>Name</Name>
                        </Attribute>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>master</Value>
                        </Constant>
                        </Operator>
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>IsSystemObject</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'System Failure Error Check', @description=N'Confirms that an unexpected system shutdown error message (Event ID – 6008) does not exist in the system log.', @facet=N'Server', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>IsNull</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>2</Count>
                        <Function>
                        <TypeClass>Numeric</TypeClass>
                        <FunctionType>ExecuteWql</FunctionType>
                        <ReturnType>Numeric</ReturnType>
                        <Count>3</Count>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>Numeric</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>root\CIMV2</Value>
                        </Constant>
                        <Constant>
                        <TypeClass>String</TypeClass>
                        <ObjType>System.String</ObjType>
                        <Value>select EventCode from Win32_NTLogEvent where EventCode=6008 and Logfile="System"</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Function>
                        <Constant>
                        <TypeClass>Numeric</TypeClass>
                        <ObjType>System.Int32</ObjType>
                        <Value>0</Value>
                        </Constant>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'System Tables Do Not Allow Updates', @description=N'Confirms that the allow updates option is disabled on the instance of SQL Server.', @facet=N'IServerConfigurationFacet', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>AllowUpdates</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>False</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'TCP/IP Protocol Enabled and other protocols disabled', @description=N'', @facet=N'IServerSetupFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Bool</TypeClass>
      <Name>TcpEnabled</Name>
    </Attribute>
    <Function>
      <TypeClass>Bool</TypeClass>
      <FunctionType>True</FunctionType>
      <ReturnType>Bool</ReturnType>
      <Count>0</Count>
    </Function>
  </Operator>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Bool</TypeClass>
      <Name>NamedPipesEnabled</Name>
    </Attribute>
    <Function>
      <TypeClass>Bool</TypeClass>
      <FunctionType>False</FunctionType>
      <ReturnType>Bool</ReturnType>
      <Count>0</Count>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'TempDB', @description=N'Evaluates only on TempDB.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>String</TypeClass>
    <Name>Name</Name>
  </Attribute>
  <Constant>
    <TypeClass>String</TypeClass>
    <ObjType>System.String</ObjType>
    <Value>tempdb</Value>
  </Constant>
</Operator>', @is_name_condition=1, @obj_name=N'tempdb', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'TempDB Data File number is multiple of 4', @description=N'Checks if TempDB Data Files exist in multiples of 4, when more than 1 Data File exists.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>DECLARE @filecnt int SELECT @filecnt = COUNT(physical_name) FROM sys.master_files (NOLOCK) WHERE database_id = 2 AND type = 0 IF @filecnt > 1 BEGIN SELECT @filecnt % 4 END ELSE BEGIN SELECT 0 END</Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>0</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'TempDB Data File Sizes Match', @description=N'Checks if TempDB Data File sizes match, when more than 1 Data File exists.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>DECLARE @filecnt int SELECT @filecnt = COUNT(physical_name) FROM sys.master_files (NOLOCK) WHERE database_id = 2 AND type = 0 IF @filecnt &gt; 1 BEGIN SELECT COUNT(DISTINCT size) FROM sys.master_files WHERE database_id = 2 AND type = 0 END ELSE BEGIN SELECT 1 END</Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>1</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'TempDB Number of Files is Optimal', @description=N'Checks if TempDB Data Files to Online Schedulers is optimal. Number of Data Files is between 4 and 8, or if higher then at least half the online schedulers, and also if the number of Data Files is multiple of 4.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>DECLARE @tdb_files int, @online_count int SELECT @tdb_files = COUNT(physical_name) FROM sys.master_files (NOLOCK) WHERE database_id = 2 AND [type] = 0; SELECT @online_count = COUNT(cpu_id) FROM sys.dm_os_schedulers WHERE is_online = 1 AND scheduler_id &lt; 255 AND parent_node_id &lt; 64; SELECT CASE WHEN (@tdb_files &gt;= 4 AND @tdb_files &lt;= 8 AND @tdb_files % 4 = 0) OR (@tdb_files &gt;= (@online_count / 2) AND @tdb_files &gt;= 8 AND @tdb_files % 4 = 0) THEN 0 ELSE 1 END</Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>0</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Trustworthy', @description=N'Confirms that the database Trustworthy property is equal to true.', @facet=N'IDatabaseOptions', @expression=N'
                        <Operator>
                        <TypeClass>Bool</TypeClass>
                        <OpType>EQ</OpType>
                        <Count>2</Count>
                        <Attribute>
                        <TypeClass>Bool</TypeClass>
                        <Name>Trustworthy</Name>
                        </Attribute>
                        <Function>
                        <TypeClass>Bool</TypeClass>
                        <FunctionType>True</FunctionType>
                        <ReturnType>Bool</ReturnType>
                        <Count>0</Count>
                        </Function>
                        </Operator>
                      ', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'User or Model', @description=N'Confirms that the database is a user database or the Model database and that the database is online.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>AND</OpType>
  <Count>2</Count>
  <Group>
    <TypeClass>Bool</TypeClass>
    <Count>1</Count>
    <Operator>
      <TypeClass>Bool</TypeClass>
      <OpType>OR</OpType>
      <Count>2</Count>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>EQ</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>Bool</TypeClass>
          <Name>IsSystemObject</Name>
        </Attribute>
        <Function>
          <TypeClass>Bool</TypeClass>
          <FunctionType>False</FunctionType>
          <ReturnType>Bool</ReturnType>
          <Count>0</Count>
        </Function>
      </Operator>
      <Operator>
        <TypeClass>Bool</TypeClass>
        <OpType>EQ</OpType>
        <Count>2</Count>
        <Attribute>
          <TypeClass>String</TypeClass>
          <Name>Name</Name>
        </Attribute>
        <Constant>
          <TypeClass>String</TypeClass>
          <ObjType>System.String</ObjType>
          <Value>model</Value>
        </Constant>
      </Operator>
    </Operator>
  </Group>
  <Operator>
    <TypeClass>Bool</TypeClass>
    <OpType>EQ</OpType>
    <Count>2</Count>
    <Attribute>
      <TypeClass>Unsupported</TypeClass>
      <Name>Status</Name>
    </Attribute>
    <Function>
      <TypeClass>Numeric</TypeClass>
      <FunctionType>Enum</FunctionType>
      <ReturnType>Numeric</ReturnType>
      <Count>2</Count>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Microsoft.SqlServer.Management.Smo.DatabaseStatus</Value>
      </Constant>
      <Constant>
        <TypeClass>String</TypeClass>
        <ObjType>System.String</ObjType>
        <Value>Normal</Value>
      </Constant>
    </Function>
  </Operator>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Virtual Log Files', @description=N'Checks the number of Virtual Log Files.', @facet=N'Database', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>LE</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>CREATE TABLE #pbm_log_info (recoveryunitid int NULL, fileid tinyint, file_size bigint, start_offset bigint, FSeqNo int, [status] tinyint, parity tinyint, create_lsn numeric(25,0))&lt;?char 13?&gt;
IF CONVERT(int, (@@microsoftversion / 0x1000000) &amp; 0xff) &lt; 11&lt;?char 13?&gt;
BEGIN&lt;?char 13?&gt;
	INSERT INTO #pbm_log_info (fileid, file_size, start_offset, FSeqNo, [status], parity, create_lsn)&lt;?char 13?&gt;
	EXEC sp_executesql ''''DBCC LOGINFO WITH NO_INFOMSGS''''&lt;?char 13?&gt;
END&lt;?char 13?&gt;
ELSE&lt;?char 13?&gt;
BEGIN&lt;?char 13?&gt;
	INSERT INTO #pbm_log_info (recoveryunitid, fileid, file_size, start_offset, FSeqNo, [status], parity, create_lsn)&lt;?char 13?&gt;
	EXEC sp_executesql ''''DBCC LOGINFO WITH NO_INFOMSGS''''&lt;?char 13?&gt;
END&lt;?char 13?&gt;
SELECT COUNT(*) FROM #pbm_log_info&lt;?char 13?&gt;
DROP TABLE #pbm_log_info</Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>100</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Windows Authentication Mode', @description=N'Confirms that the server LoginMode is Windows integrated authentication.', @facet=N'IServerSecurityFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Numeric</TypeClass>
    <Name>LoginMode</Name>
  </Attribute>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>Enum</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Microsoft.SqlServer.Management.Smo.ServerLoginMode</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>Mixed</Value>
    </Constant>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'XP_CmdShell', @description=N'', @facet=N'IServerSecurityFacet', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Attribute>
    <TypeClass>Bool</TypeClass>
    <Name>XPCmdShellEnabled</Name>
  </Attribute>
  <Function>
    <TypeClass>Bool</TypeClass>
    <FunctionType>False</FunctionType>
    <ReturnType>Bool</ReturnType>
    <Count>0</Count>
  </Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id

GO


--- now get a schedule created that will replace the schedule id for all the following enabled policies dependent on a schedule

USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/29/2020 2:19:37 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'syspolicy_check_schedule_RonaLowes', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verify that automation is enabled.]    Script Date: 9/29/2020 2:19:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verify that automation is enabled.', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF (msdb.dbo.fn_syspolicy_is_automation_enabled() != 1)
        BEGIN
            RAISERROR(34022, 16, 1)
        END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Evaluate policies.]    Script Date: 9/29/2020 2:19:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Evaluate policies.', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'dir SQLSERVER:\SQLPolicy\W90990Ajuste\default\Policies | where { $_.ScheduleUid -eq "InputNewScheduleID" } |  where { $_.Enabled -eq 1} | where {$_.AutomatedPolicyEvaluationMode -eq 4} | Invoke-PolicyEvaluation -AdHocPolicyEvaluationMode 2 -TargetServerName W90990ADJUST', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'syspolicy_purge_history_schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20080101, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959,--- added in the schedule id
				@schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
--- see what this schedule ID is, and use if for all the following once the policy job has been created


---- REPLACE SCHEDULE ID, or all will fail (mny set to 0000000 so better :
-- add missing categories

EXEC msdb.dbo.sp_syspolicy_update_target_set @target_set_id=49, @enabled=True
EXEC msdb.dbo.sp_syspolicy_update_target_set_level @target_set_id=49, @type_skeleton=N'Server/Database/LogFile', @condition_name=N''
EXEC msdb.dbo.sp_syspolicy_update_target_set_level @target_set_id=49, @type_skeleton=N'Server/Database', @condition_name=N''


GO

EXEC msdb.dbo.sp_syspolicy_update_policy @policy_id=49, @execution_mode=4, @policy_category=N'Microsoft Best Practices: Performance', @schedule_uid=N'3b313f43-9db9-43d4-a5b2-767be352a7d3'

GO  
-- validate that the categories are ther, otherwise add them when policies fail to be added (conditions okay, 
-- just the last sp_syspolicy_add_policy might fail, and can be easily re-executed once the policy is added
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'XP_CmdShell Check_ObjectSet', @facet=N'IServerSecurityFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'XP_CmdShell Check_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'XP_CmdShell Check', @condition_name=N'XP_CmdShell', @policy_category=N'', @description=N'Redundant check since CMDshell Secured exists above', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'XP_CmdShell Check_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Last Successful Backup Date_ObjectSet_1', @facet=N'Database', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Last Successful Backup Date_ObjectSet_1', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Last Successful Backup Date', @condition_name=N'Safe Last Full or Diff Backup Date', @policy_category=N'SmartAdmin warnings', @description=N'Checks whether a database has recent backups. Scheduling regular backups is important for protecting your databases against data loss from a variety of failures.
The appropriate frequency for backing up data depends on the recovery model of the database, on business requirements regarding potential data loss, and on how frequently the database is updated. In a frequently updated database, the amount of work-loss exposure increases relatively quickly between backups.
The best practice is to perform backups frequently enough to protect databases against data loss. The simple recovery model and full recovery model both require data backups. The full recovery model also requires log backups, which should be taken more often than data backups. For either recovery model, you can supplement your full backups with differential backups to efficiently reduce the risk of data loss. For a database that uses the full recovery model, Microsoft recommends that you take frequent log backups. For a production database that contains critical data, log backups would typically be taken every one to fifteen minutes. Note: The recommended method for scheduling backups is a database maintenance plan.                    ', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116361', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Last Successful Backup Date_ObjectSet_1'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'LogFile Autogrowth too small_ObjectSet', @facet=N'LogFile', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'LogFile Autogrowth too small_ObjectSet', @type_skeleton=N'Server/Database/LogFile', @type=N'LOGFILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/LogFile', @level_name=N'LogFile', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'LogFile Autogrowth too small', @condition_name=N'LogFile Autogrowth Less than 8MB condition', @policy_category=N'Microsoft Best Practices: Performance', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'3b313f43-9db9-43d4-a5b2-767be352a7d3', @execution_mode=4, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'LogFile Autogrowth too small_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Surface Area Configuration for SOAP Endpoints_ObjectSet', @facet=N'Endpoint', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Surface Area Configuration for SOAP Endpoints_ObjectSet', @type_skeleton=N'Server/Endpoint', @type=N'ENDPOINT', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Endpoint', @level_name=N'Endpoint', @condition_name=N'Soap Endpoint', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Surface Area Configuration for SOAP Endpoints', @condition_name=N'Endpoint Disabled', @policy_category=N'Microsoft Off by Default: Surface Area Configuration', @description=N'Checks for disabled Simple Object Access Protocol(SOAP) endpoints on the instance of SQL Server. Native XML Web Services provide database access over HTTP by using SOAP messages. Enable HTTP endpoints only if your applications use them to communicate with the Database Engine.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=117327', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Surface Area Configuration for SOAP Endpoints_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Public Not Granted Server Permissions_ObjectSet', @facet=N'IServerSecurityFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Public Not Granted Server Permissions_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Public Not Granted Server Permissions', @condition_name=N'Public Server Role Has No Granted Permissions', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks that the server permission is not granted to the Public role.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116364', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Public Not Granted Server Permissions_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Surface Area Configuration for Service Broker Endpoints_ObjectSet', @facet=N'Endpoint', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Surface Area Configuration for Service Broker Endpoints_ObjectSet', @type_skeleton=N'Server/Endpoint', @type=N'ENDPOINT', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Endpoint', @level_name=N'Endpoint', @condition_name=N'Service Broker Endpoint', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Surface Area Configuration for Service Broker Endpoints', @condition_name=N'Endpoint Stopped', @policy_category=N'Microsoft Off by Default: Surface Area Configuration', @description=N'Checks for stopped Service Broker endpoint on the instance of SQL Server. Service Broker provides queuing and reliable messaging for the Database Engine. Service Broker uses a TCP endpoint for communication between instances of SQL Server. Enable Service Broker endpoint only if your applications use Service Broker to communicate between instances of SQL Server.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=117326', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Surface Area Configuration for Service Broker Endpoints_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Surface Area Configuration for Database Engine 2008 Features_ObjectSet', @facet=N'ISurfaceAreaFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Surface Area Configuration for Database Engine 2008 Features_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Surface Area Configuration for Database Engine Features', @condition_name=N'Surface Area Configuration for Database Engine Features', @policy_category=N'Microsoft Off by Default: Surface Area Configuration', @description=N'Checks for default surface area settings for Database Engine 2008 features. Only the features required by your application should be enabled. Disabling unused features helps protect your server by reducing the surface area.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=117323', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Surface Area Configuration for Database Engine 2008 Features_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Is SysAdmin Fixed Role Hardened_ObjectSet', @facet=N'User', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Is SysAdmin Fixed Role Hardened_ObjectSet', @type_skeleton=N'Server/Database/User', @type=N'USER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/User', @level_name=N'User', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Is master', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Is SysAdmin Fixed Role Hardened', @condition_name=N'Is Sysadmin Hardened', @policy_category=N'', @description=N'Trying to avoid too many users in the syadmin fixed server role, starting with the default nt services virtual service accounts that we do not use - explicit sql service on AD is given during installation.', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Is SysAdmin Fixed Role Hardened_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server 64-bit Affinity Mask Overlap_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server 64-bit Affinity Mask Overlap_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server 64-bit Affinity Mask Overlap', @condition_name=N'64-bit Affinity Mask Overlapped', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks an instance of SQL Server having processors that are assigned with both the affinity64 mask and the affinity64 I/O mask options. On a computer that has more than one processor, the affinity64 mask and the affinity64 I/O mask options are used to designate which CPUs are used by SQL Server. Enabling a CPU with both the affinity64 mask and the affinity64 I/O mask can slow performance by forcing the processor to be overused.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116381', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server 64-bit Affinity Mask Overlap_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Password Policy_ObjectSet', @facet=N'ILoginOptions', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Password Policy_ObjectSet', @type_skeleton=N'Server/Login', @type=N'LOGIN', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Login', @level_name=N'Login', @condition_name=N'SQL Server Authenticated Logins', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Password Policy', @condition_name=N'Password Policy Enforced', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks whether password policy enforcement on SQL Server logins is enabled. Password policy should be enforced for all SQL Server logins.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116331', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'SQL Server Password Policy_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Open Objects for SQL Server 2000_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Open Objects for SQL Server 2000_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Open Objects for SQL Server 2000', @condition_name=N'Auto-configured Open Objects', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks whether the open objects server option is set to 0, the optimal value on instances SQL Server 2000. Using a nonzero value can lead to errors when you are using SQL Server 2000. This value should not be changed from the default value of 0, unless you are working with Microsoft Customer Support Services (CSS) to solve a specific problem.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116334', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server Open Objects for SQL Server 2000_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server I/O Affinity Mask For Non-enterprise SQL Servers_ObjectSet', @facet=N'IServerConfigurationFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server I/O Affinity Mask For Non-enterprise SQL Servers_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server I/O Affinity Mask For Non-enterprise SQL Servers', @condition_name=N'I/O Affinity Mask Disabled', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks that the I/O Affinity Mask is disabled for non-enterprise editions.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116381', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'Not Enterprise Edition', @object_set=N'SQL Server I/O Affinity Mask For Non-enterprise SQL Servers_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Lightweight Pooling_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Lightweight Pooling_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Lightweight Pooling', @condition_name=N'Lightweight Pooling Disabled', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks whether lightweight pooling is disabled on the server. Setting lightweightpooling to 1 causes SQL Server to switch to fiber mode scheduling. Fiber mode is intended for certain situations when the context switching of the UMS workers are the critical bottleneck in performance. Because this situation is unusual, fiber mode rarely enhances performance or scalability on the typical system.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116350', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server Lightweight Pooling_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Login Mode_ObjectSet', @facet=N'IServerSecurityFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Login Mode_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Login Mode', @condition_name=N'Windows Authentication Mode', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks for Windows Authentication. When possible, Microsoft recommends using Windows Authentication. Windows Authentication uses Kerberos security protocol, provides password policy enforcement in terms of complexity validation for strong passwords (applies only to Windows Server 2003 and later), provides support for account lockout, and supports password expiration.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116369', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server Login Mode_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Max Degree of Parallelism_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Max Degree of Parallelism_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Max Degree of Parallelism for SQL Server 2000', @condition_name=N'Maximum Degree of Parallelism Optimized for SQL 2000', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks the max degree of parallelism option for the optimal value to avoid unwanted resource consumption and performance degradation. The recommended value of this option is 8 or less. Setting this option to a larger value often results in unwanted resource consumption and performance degradation.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116335', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server Max Degree of Parallelism_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server System Tables Updatable_ObjectSet', @facet=N'IServerConfigurationFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server System Tables Updatable_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server System Tables Updatable', @condition_name=N'System Tables Do Not Allow Updates', @policy_category=N'Microsoft Best Practices: Server Configuration', @description=N'Checks whether SQL Server 2000 system tables can be updated. We recommend that you do not allow system tables to be updated.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116352', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server System Tables Updatable_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Max Worker Threads for SQL Server 2005 and above_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Max Worker Threads for SQL Server 2005 and above_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Max Worker Threads for SQL Server 2005 and above', @condition_name=N'Auto-configured Maximum Worker Threads', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks the max work threads server option for potentially incorrect settings of an instance of SQL Server 2005. Setting the max worker threads option to a nonzero value will prevent SQL Server from automatically determining the proper number of active worker threads based on user requests.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116324', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'SQL Server Max Worker Threads for SQL Server 2005 and above_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Symmetric Key Encryption for User Databases_ObjectSet', @facet=N'SymmetricKey', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Symmetric Key Encryption for User Databases_ObjectSet', @type_skeleton=N'Server/Database/SymmetricKey', @type=N'SYMMETRICKEY', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/SymmetricKey', @level_name=N'SymmetricKey', @condition_name=N'Key Length Less Than 128 Bytes', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Symmetric Key Encryption for User Databases', @condition_name=N'Strongly Encrypted', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks that symmetric keys with a length less than 128 bytes do not use the RC2 or RC4 encryption algorithm. The best practice recommendation is to use AES 128 bit and above to create symmetric keys for data encryption. If AES is not supported by the version of your operating system, use 3DES.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116328', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Symmetric Key Encryption for User Databases_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Symmetric Key for System Databases_ObjectSet', @facet=N'SymmetricKey', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Symmetric Key for System Databases_ObjectSet', @type_skeleton=N'Server/Database/SymmetricKey', @type=N'SYMMETRICKEY', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/SymmetricKey', @level_name=N'SymmetricKey', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'System Databases Not Including Master', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Symmetric Key for System Databases', @condition_name=N'Fail For Any Symmetric Key', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks for user-created symmetric keys in the msdb, model, and tempdb databases. This is not recommended. This recommendation does not apply to the master database.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116329', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Symmetric Key for System Databases_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Backup and Data File Location_ObjectSet', @facet=N'IDatabaseMaintenanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Backup and Data File Location_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Backup and Data File Location', @condition_name=N'Data and Backup on Separate Drive', @policy_category=N'SmartAdmin warnings', @description=N'Checks if database and the backups are on separate backup devices. If they are on the same backup device, and the device that contains the database fails, your backups will be unavailable. Also, putting the data and backups on separate devices optimizes the I/O performance for both the production use of the database and writing the backups.

Note:  This policy cannot detect separate physical devices through mount points.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116373', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Backup and Data File Location_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log Disk Defragmentation_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log Disk Defragmentation_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log Disk Defragmentation', @condition_name=N'Disk Defragmentation Resulting Data Corruption', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N'This policy detects error message in System Log Detects an error message in the System Log that can result when the Windows 2000 disk defragmenter tool does not move a particular data element, and schedules Chkdsk.exe. In this condition, the error is a false positive. There is no loss of data, and, the integrity of the data is not affected.
http://support.microsoft.com/kb/885688
http://support.microsoft.com/kb/320866', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116353', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log Disk Defragmentation_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log Device Not Ready Error_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log Device Not Ready Error_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log Device Not Ready Error', @condition_name=N'Device Not Ready Error Check', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N'This policy detects for error messages in Detects error messages in the System Log that can be the result of SCSI host adapter configuration issues or related problems.
http://support.microsoft.com/kb/259237
http://support.microsoft.com/kb/154690', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116349', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log Device Not Ready Error_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'HighVLFs_ObjectSet', @facet=N'Database', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'HighVLFs_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'High VLFs', @condition_name=N'Virtual Log Files', @policy_category=N'SmartAdmin warnings', @description=N'The transaction log files are internally divided into sections called Virtual Log Files (VLFs) and the more transaction log file experiences the fragmentation, the more the VLFs created. Several VLFs are generated if the transaction log file is created by small initial size and small growth increments. Once the transaction log file builds more than 100 VLFs, you may start noticing the performance issues with the operations that use the transaction log file such as log reads for transactional replication, rollback, log backups and database recovery etc.
Create the transaction log file with an appropriate initial size, anticipate the future needs and set the auto growth to an adequate size. While sizing the transaction log file consider the factors like transaction size (long-running transactions cannot be cleared from the log until they complete) and log backup frequency (since this is what removes the inactive portion of the log).', @help_text=N'', @help_link=N'http://blogs.msdn.com/b/blogdoezequiel/archive/2010/05/31/sql-server-and-log-file-usage.aspx', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'HighVLFs_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log Cluster Disk Resource Corruption Error_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log Cluster Disk Resource Corruption Error_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log Cluster Disk Resource Corruption Error', @condition_name=N'Cluster Disk Resource Corruption Error Check', @policy_category=N'SmartAdmin errors', @description=N'Detects SCSI host adapter configuration issues or a malfunctioning device error message in the System Log.
http://support.microsoft.com/kb/311081', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116377', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log Cluster Disk Resource Corruption Error_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log Device Driver Control Error_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log Device Driver Control Error_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log Device Driver Control Error', @condition_name=N'Device Driver Control Error Check', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N'Detects Error EventID ñ11 in the System Log. This error could be because of a corrupted device driver, a hardware problem, a malfunctioning device, poor cabling, or termination issues.
http://support.microsoft.com/kb/259237
http://support.microsoft.com/kb/154690', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116371', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log Device Driver Control Error_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'TempDB_File_Sizes_ObjectSet', @facet=N'Database', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'TempDB_File_Sizes_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'TempDB', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'TempDB Data File Sizes Match', @condition_name=N'TempDB Data File Sizes Match', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Dividing TempDB into multiple data files of equal size provides a high degree of parallel efficiency in operations that use TempDB. These multiple files do not necessarily need to be on different disks or spindles unless you are also encountering I/O bottlenecks as well.
Be aware that if one of the data files is larger than the others, this mechanism will not be effective, so check if growth via AUTOGROW has happened on one file and broke the proportional fill.', @help_text=N'', @help_link=N'http://msdn2.microsoft.com/en-us/library/ms175527.aspx', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'TempDB_File_Sizes_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'TempDB_Data_File_number_multiple_of_4_ObjectSet', @facet=N'Database', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'TempDB_Data_File_number_multiple_of_4_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'TempDB', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'TempDB Data File number is multiple of 4', @condition_name=N'TempDB Data File number is multiple of 4', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Dividing TempDB into multiple data files of equal size provides a high degree of parallel efficiency in operations that use TempDB. These multiple files do not necessarily need to be on different disks or spindles unless you are also encountering I/O bottlenecks as well.
Having multiple TempDB data files can reduce contention and improve performance on active systems. This is because there will be one or more SGAM pages for each file, the main point of contention for mixed allocations. If there is a need to increase above the initial 8 files, do so by multiples of 4 files.', @help_text=N'', @help_link=N'http://support.microsoft.com/kb/2154845/en-us', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'TempDB_Data_File_number_multiple_of_4_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'TempDB_Configuration_is_Optimal_ObjectSet', @facet=N'Database', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'TempDB_Configuration_is_Optimal_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'TempDB', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'TempDB Data File Configuration is Optimal', @condition_name=N'TempDB Number of Files is Optimal', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Having multiple TempDB data files can reduce contention and improve performance on active systems. This is because there will be one or more SGAM pages for each file, the main point of contention for mixed allocations. If there is a need to increase above the initial 8 files, do so by multiples of 4 files.
Dividing TempDB into multiple data files of equal size provides a high degree of parallel efficiency in operations that use TempDB. These multiple files do not necessarily need to be on different disks or spindles unless you are also encountering I/O bottlenecks as well. 
One disadvantage of having too many TempDB files is that every object in TempDB will have multiple IAM pages. In addition, there will be more switching costs as objects are accessed as well as more managing overhead. On very large systems, 8 TempDB data files may be sufficient, but reconsider this based on the workload. If there is a need to increase above the initial 8 files, do so by multiples of 4 files.', @help_text=N'', @help_link=N'http://support.microsoft.com/kb/2154845/en-us', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'TempDB_Configuration_is_Optimal_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'DB owner as desired_ObjectSet', @facet=N'Database', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'DB owner as desired_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'DB owner as desired', @condition_name=N'Database owner is SA', @policy_category=N'SmartAdmin warnings', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'DB owner as desired_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Trustworthy Database_ObjectSet', @facet=N'IDatabaseSecurityFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Trustworthy Database_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Trustworthy', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Trustworthy Database', @condition_name=N'Database Owner Not sysadmin', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks whether the dbo or a db_owner is assigned to a fixed server sysadmin role for databases where the trustworthy bit is set to on. Database users with the appropriate level of permissions can elevate privileges to the sysadmin role. In this role, the user can create and execute unsafe assemblies that compromise the system. The best practice is to turn off the trustworthy bit or change the dbo and db_owner to a fixed server role other than sysadmin.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116327', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Trustworthy Database_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Network Packet Size_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Network Packet Size_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Network Packet Size', @condition_name=N'Network Packet Size Optimized', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks whether for the value specified for network packet size server option is set to the optimal value of 8060 bytes. If the network packet size of any logged-in user is more than 8060 bytes, SQL Server performs different memory allocation operations. This can cause an increase in the process virtual address space that is not reserved for the buffer pool.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116360', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server Network Packet Size_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'TCP\IP Enabled and Other Protocols Disabled_ObjectSet', @facet=N'IServerSetupFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'TCP\IP Enabled and Other Protocols Disabled_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'TCP\IP Enabled and Other Protocols Disabled', @condition_name=N'TCP/IP Protocol Enabled and other protocols disabled', @policy_category=N'', @description=N'SmartAdmin Warnings', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=1, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'TCP\IP Enabled and Other Protocols Disabled_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log Failed I/O Request Error_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log Failed I/O Request Error_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log Failed I/O Request Error', @condition_name=N'Failed I/O Request Check', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N' This policy detects a failed I/O request error message in the system log. This could be the result of a variety of things, including a firmware bug or faulty SCSI cables.
http://support.microsoft.com/kb/311081
http://support.microsoft.com/kb/885688', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116385', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log Failed I/O Request Error_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log I/O Delay Warning_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log I/O Delay Warning_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log I/O Delay Warning', @condition_name=N'I/O Delay Warning Check', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N'Detects Event ID 833 in the system log. This message indicates that SQL Server has issued a read or write request from disk, and that the request has taken longer than 15 seconds to return. This error is reported by SQL Server and indicates a problem with the disk I/O subsystem. Delays this long can severely limit the performance of your instance of SQL Server.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116375', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log I/O Delay Warning_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log Storage System I/O Timeout Error_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log Storage System I/O Timeout Error_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log Storage System I/O Timeout Error', @condition_name=N'Storage System I/O Timeout Error Check', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N'Detects Error EventID ñ9 in the System Log. This error indicates that I/O time-out has occurred within the storage system, as detected from the driver for the controller. 
http://support.microsoft.com/kb/259237  
http://support.microsoft.com/kb/154690', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116330', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log Storage System I/O Timeout Error_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Dynamic Locks_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Dynamic Locks_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Dynamic Locks', @condition_name=N'Auto-configured Dynamic Locks', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks whether the value of the locks option is the default setting of 0. This enables the Database Engine to allocate and deallocate lock structures dynamically, based on changing system requirements. If locks is nonzero, batch jobs will stop, and an out of locks error message will be generated when the value specified is exceeded.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116358', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'SQL Server Dynamic Locks_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Blocked Process Threshold_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Blocked Process Threshold_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Blocked Process Threshold', @condition_name=N'Blocked Process Threshold Optimized', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks whether the blocked process threshold option is set lower than 5 and is not disabled (0). Setting the blocked process threshold option to a value from 1 to 4 can cause the deadlock monitor to run constantly. Values 1 to 4 should only be used for troubleshooting and never long term or in a production environment without the assistance of Microsoft Customer Service and Support.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116356', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'SQL Server Blocked Process Threshold_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Are_MaintenanceJobs_Deployed_and_Enabled_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Are_MaintenanceJobs_Deployed_and_Enabled_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Are Maintenance Jobs Deployed and Enabled', @condition_name=N'Maintenance Jobs', @policy_category=N'SmartAdmin warnings', @description=N'Index fragmentation occurs naturally as changes are made to data. Leverage OLA Hellengren`s open source Maintenance Solution for DB integrity, backups (if necssary) and index defrag according to the objects needs, balancing index performance with minimal required time for this task, while being aware of all the common caveats linked to index defragmentation.
For recommendations on implementing automated maintenance tasks, see ola.hellengren.com or his github repo', @help_text=N'', @help_link=N'http://blogs.msdn.com/b/blogdoezequiel/archive/2012/09/18/about-maintenance-plans-grooming-sql-server.aspx', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Are_MaintenanceJobs_Deployed_and_Enabled_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Are there Disabled logins_ObjectSet', @facet=N'Login', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Are there Disabled logins_ObjectSet', @type_skeleton=N'Server/Login', @type=N'LOGIN', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Login', @level_name=N'Login', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Are there Disabled logins', @condition_name=N'Are there Disabled logins (sp_validateLogins)', @policy_category=N'SmartAdmin warnings', @description=N'Checks the condition equivalent out put of sp_vadlidatelogins - displays any where disabled equals true (conditoin is false to pass, and thus only a disabled dlogin will display for the if @isdisabledlogin equals false', @help_text=N'', @help_link=N'', @schedule_uid=N'3b313f43-9db9-43d4-a5b2-767be352a7d3', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Are there Disabled logins_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Asymmetric Key Encryption Algorithm_ObjectSet', @facet=N'AsymmetricKey', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Asymmetric Key Encryption Algorithm_ObjectSet', @type_skeleton=N'Server/Database/AsymmetricKey', @type=N'ASYMMETRICKEY', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/AsymmetricKey', @level_name=N'AsymmetricKey', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Asymmetric Key Encryption Algorithm', @condition_name=N'RSA 1024 or RSA 2048 Encrypted', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks whether asymmetric keys were created with 1024-bit or better.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116370', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Asymmetric Key Encryption Algorithm_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'CLR Is Disabled_ObjectSet', @facet=N'IServerConfigurationFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'CLR Is Disabled_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'CLR Is Disabled', @condition_name=N'CLR is Disabled', @policy_category=N'', @description=N'SCCM servers require CLR, so this condition is set to True to pass', @help_text=N'', @help_link=N'', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'CLR Is Disabled_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Data and Log File Location_ObjectSet', @facet=N'IDatabasePerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Data and Log File Location_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Data and Log File Location', @condition_name=N'Data and Log Files on Separate Drives', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks whether data and log files are placed on separate logical drives. Placing both data and log files on the same drive can cause contention for that drive and result in poor performance. Placing the files on separate drives allows the I/O activity to occur at the same time for both the data and log files. The best practice is to specify separate drives for the data and log when you create a new database. To move files after the database is created, the database must be taken offline. Move the files by using one of the following methods:

* Restore the database from backup by using the RESTORE DATABASE statement with the WITH MOVE option. 
* Detach and then re-attach the database specifying separate locations for the data and log devices. 
* Specify a new location by running the ALTER DATABASE statement with the MODIFY FILE option, and then restarting the instance of SQL Server. 

Note:  This policy cannot detect separate physical devices through mount points.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116362', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'Enterprise or Standard Edition', @object_set=N'Data and Log File Location_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Database Auto Close_ObjectSet', @facet=N'IDatabasePerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Database Auto Close_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Database Auto Close', @condition_name=N'Auto Close Disabled', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks that the AUTO_ CLOSE option is off for SQL Server Standard and Enterprise Editions. When set to on, this option can cause performance degradation on frequently accessed databases because of the increased overhead of opening and closing the database after each connection. AUTO_CLOSE also flushes the procedure cache after each connection.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116338', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'Enterprise or Standard Edition', @object_set=N'Database Auto Close_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Database Auto Shrink_ObjectSet', @facet=N'IDatabasePerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Database Auto Shrink_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Database Auto Shrink', @condition_name=N'Auto Shrink Disabled', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks that the AUTO_SHRINK option is off for user databases on SQL Server Standard and Enterprise Editions. Frequently shrinking and expanding a database can lead to poor performance because of physical fragmentation. Set the AUTO_SHRINK database option to OFF. If you know that the space that you are reclaiming will not be needed in the future, you can manually shrink the database.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116337', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'Enterprise or Standard Edition', @object_set=N'Database Auto Shrink_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Database Collation_ObjectSet', @facet=N'IDatabasePerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Database Collation_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Database Collation', @condition_name=N'Collation Matches master or model', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Looks for user-defined databases that have a collation different from the master or model databases. It is recommended that you not use this configuration because collation conflicts can occur that might prevent code from executing. For example, when a stored procedure joins one table to a temporary table, SQL Server might end the batch and return a collation conflict error if the collations of the user-defined database and the model database are different. This happens because temporary tables are created in tempdb, which obtains its collation based on that of the model database. If you experience collation conflict errors, consider one of the following solutions:
 * Export the data from the user database and import it into new tables that have the same collation as the master and model databases.
 * Rebuild the system databases to use a collation that matches the user database collation.
 * Modify any stored procedures that join user tables to tables in tempdb to create the tables in tempdb by using the collation of the user database. To do this, add the COLLATE database_default clause to the column definitions of the temporary table. For example: CREATE TABLE #temp1 ( c1 int, c2 varchar(30) COLLATE database_default )', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116336', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Database Collation_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Windows Event Log System Failure Error_ObjectSet', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Windows Event Log System Failure Error_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Windows Event Log System Failure Error', @condition_name=N'System Failure Error Check', @policy_category=N'Microsoft Best Practices: Windows Log File', @description=N'Detects Error Event ID 6008 in the System Log. This error indicates an unexpected system shutdown. The system might be unstable and might not provide the stability and integrity that is required to host an instance of SQL Server. If it is known, you should address the root cause of the unexpected server restarts. Otherwise, move the instance of SQL Server to another computer.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116326', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Windows Event Log System Failure Error_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Database Page Status_ObjectSet', @facet=N'IDatabaseMaintenanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Database Page Status_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Database Page Status', @condition_name=N'No Suspect Database Pages', @policy_category=N'SmartAdmin warnings', @description=N'Checks whether the database has suspect database pages.  A database page is set suspect by error 824. This error occurs when a logical consistency error is detected during a read operation, which frequently indicates data corruption caused by a faulty I/O subsystem component. When the SQL Server Database Engine detects a suspect page, the page ID is recorded in the msdbo.dbo.suspect_pages table. This is a severe error condition that threatens database integrity and must be corrected immediately.

Best Practices Recommendations:
* Review the SQL Server error log for the details of the 824 error for this database.
* Complete a full database consistency check (DBCC CHECKDB).
* Implement the user actions defined in MSSQLSERVER_824.
', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116379', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Database Page Status_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Database Status_ObjectSet', @facet=N'IDatabasePerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Database Status_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Database Status Check', @condition_name=N'Database Status', @policy_category=N'', @description=N'checks status of db', @help_text=N'', @help_link=N'', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Database Status_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'File Growth for SQL Server 2000_ObjectSet', @facet=N'DataFile', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'File Growth for SQL Server 2000_ObjectSet', @type_skeleton=N'Server/Database/FileGroup/File', @type=N'FILE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/FileGroup/File', @level_name=N'File', @condition_name=N'File is 1GB or Larger', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/FileGroup', @level_name=N'FileGroup', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'File Growth for SQL Server 2000', @condition_name=N'Growth Type Not Percent', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks an instance of SQL Server 2000(adjusted already for 205 and up ALSO). Warns if the data file is 1 GB or larger, and is set to autogrow by a percentage, instead of growing by a fixed size. Growing a data file by a percentage can cause SQL Server performance problems because of progressively larger growth increments. For an instance of SQL Server 2000, set the FILEGROWTH (autogrow) value to a fixed size to avoid escalating performance problems.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116378', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'File Growth for SQL Server 2000_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Guest Permissions_ObjectSet', @facet=N'User', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Guest Permissions_ObjectSet', @type_skeleton=N'Server/Database/User', @type=N'USER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/User', @level_name=N'User', @condition_name=N'Guest', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'User or Model', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Guest Permissions', @condition_name=N'Has No Database Access', @policy_category=N'Microsoft Best Practices: Security', @description=N'Checks if permission to access the database is enabled for guest user. Remove access to the guest user if it is not required. The guest user cannot be dropped, but a guest user account can be disabled by revoking its CONNECT permission. You do this by executing REVOKE CONNECT FROM GUEST from within any database other than master, msdb, or tempdb.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116354', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Guest Permissions_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Is SQL OLE Automation Disabled_ObjectSet', @facet=N'IServerConfigurationFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Is SQL OLE Automation Disabled_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Is SQL OLE Automation Disabled', @condition_name=N'SQL OLE  Automation Disabled', @policy_category=N'', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Is SQL OLE Automation Disabled_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Named Pipes Disabled_ObjectSet', @facet=N'IServerSetupFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Named Pipes Disabled_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Named Pipes Disabled', @condition_name=N'Named Pipes Disabled', @policy_category=N'', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Named Pipes Disabled_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Read-only Database Recovery Model_ObjectSet', @facet=N'IDatabaseMaintenanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Read-only Database Recovery Model_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Read-only', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Read-only Database Recovery Model', @condition_name=N'Recovery Model Simple', @policy_category=N'SmartAdmin warnings', @description=N'Checks whether the recovery model is set to simple for read only databases.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116383', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'SQL Server Version 2005 or a Later Version', @object_set=N'Read-only Database Recovery Model_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SA Account Disabled_ObjectSet', @facet=N'Login', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SA Account Disabled_ObjectSet', @type_skeleton=N'Server/Login', @type=N'LOGIN', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Login', @level_name=N'Login', @condition_name=N'', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SA Account Disabled', @condition_name=N'SA account Disabled', @policy_category=N'', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SA Account Disabled_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'SQL Server Affinity Mask_ObjectSet', @facet=N'IServerPerformanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'SQL Server Affinity Mask_ObjectSet', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id



GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Affinity Mask', @condition_name=N'Affinity Mask Default', @policy_category=N'Microsoft Best Practices: Performance', @description=N'Checks an instance of SQL Server for setting, affinity mask to its default value 0, since in most cases, the Microsoft Windows 2000 or Windows Server 2003 default affinity provides the best performance. 
Confirms whether the setting affinity mask of server is set to zero.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116357', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'SQL Server Affinity Mask_ObjectSet'
Select @policy_id


GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'Database Page Verification_ObjectSet', @facet=N'IDatabaseMaintenanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'Database Page Verification_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Online User Database', @target_set_level_id=0


GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Database Page Verification', @condition_name=N'Page Verify Checksum', @policy_category=N'SmartAdmin warnings', @description=N'Checks if the PAGE_VERIFY database option is not set to CHECKSUM to provide a high level of data-file integrity. When CHECKSUM is enabled for the PAGE_VERIFY database option, the SQL Server Database Engine calculates a checksum over the contents of the whole page, and stores the value in the page header when a page is written to disk. When the page is read from disk, the checksum is recomputed and compared to the checksum value that is stored in the page header. This helps provide a high level of data-file integrity.', @help_text=N'', @help_link=N'http://go.microsoft.com/fwlink/?LinkId=116333', @schedule_uid=N'9de82006-42a2-42db-9763-0222c45d5ce8', @execution_mode=4, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'Database Page Verification_ObjectSet'
Select @policy_id


GO

