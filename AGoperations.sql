--- sql cmd mode must be used (query options, checkbox sqlcmd mode)
 :connect DCPSPEKHOSQL,2100 --- fix timeout issue
USE [master]
GO
ALTER AVAILABILITY GROUP [AGEKHO1]
MODIFY REPLICA ON N'DCPSPEKHOSQL\SP114' WITH (SESSION_TIMEOUT = 30 
GO



-- on primary dcp
 :connect DCPSPEKHOSQL,2100
BACKUP DATABASE [Ekhosoft] TO 
 DISK = N'E:\MSSQLAgroInstances\SP114\MSSQL13.SP114\MSSQL\Backup\Ekhosoft.bak'
  WITH NOFORMAT, INIT,  NAME = N'Ekhosoft-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 5
GO
BACKUP LOG [Ekhosoft]
 TO  DISK = N'E:\MSSQLAgroInstances\SP114\MSSQL13.SP114\MSSQL\Backup\Ekhosoft.bak'
  WITH NOFORMAT, NOINIT,  NAME = N'Ekhosoft-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

-- restore to differnt folder on dcss
 :connect DCSSPEKHOSQL,2100
restore database ekhosoft
from disk = N'e:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Backup\Ekhosoft.bak' 
with file=2, norecovery, nounload,norewind, move 'ekhosoft' to 'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\DATA\ekhosoft.mdf',
move 'ekhosoft_log' to 'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\logs\ekhosoft_log.ldf',
stats=5

-- return to primary and re-add to group
  alter availability group AGEKHO1
add database Ekhosoft

 :connect DCPSPEKHOSQL,2100
 BACKUP DATABASE [Ekhosoft_DW_PROD] TO 
 DISK = N'E:\MSSQLAgroInstances\SP114\MSSQL13.SP114\MSSQL\Backup\Ekhosoft_DW_PROD.bak'
  WITH NOFORMAT, INIT,  NAME = N'Ekhosoft-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 5
GO
BACKUP LOG [Ekhosoft_DW_PROD]
 TO  DISK = N'E:\MSSQLAgroInstances\SP114\MSSQL13.SP114\MSSQL\Backup\Ekhosoft_DW_PROD.bak'
  WITH NOFORMAT, NOINIT,  NAME = N'Ekhosoft-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

-- restore to differnt folder on dcss
 :connect DCSSPEKHOSQL,2100

USE [master]
RESTORE DATABASE [Ekhosoft_DW_PROD] FROM  
DISK = N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Backup\Ekhosoft_DW_PROD.bak' 
WITH  FILE = 1,  MOVE N'Ekhosoft_DW' TO N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\DATA\Ekhosoft_DW.mdf',  
MOVE N'Ekhosoft_DW_log' TO N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Logs\Ekhosoft_DW_log.ldf',  
NORECOVERY,  NOUNLOAD,  STATS = 5
RESTORE LOG [Ekhosoft_DW_PROD] FROM  
DISK = N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Backup\Ekhosoft_DW_PROD.bak' 
WITH  FILE = 2,  NORECOVERY,  NOUNLOAD,  STATS = 5

GO
 :connect DCPSPEKHOSQL,2100

-- return to primary and re-add to group
  alter availability group AGEKHO1
add database [Ekhosoft_DW_PROD]



-- try again to reload the log, since first time it didn't catch up with the Log Sequence Number
BACKUP LOG [Ekhosoft_DW_PROD]
 TO  DISK = N'E:\MSSQLAgroInstances\SP114\MSSQL13.SP114\MSSQL\Backup\Ekhosoft_DW_PROD.bak'
  WITH NOFORMAT, --- change noinit to INIT
  INIT,  NAME = N'Ekhosoft-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

 :connect DCSSPEKHOSQL,2100

USE [master]
RESTORE LOG [Ekhosoft_DW_PROD] FROM  
DISK = N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Backup\Ekhosoft_DW_PROD.bak' 
WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5  -- but only file one this time, since overwritten
--- lsn too recent, so backup all again, and restore

 :connect DCSSPEKHOSQL,2100

USE [master]
RESTORE DATABASE [Ekhosoft_DW_PROD] FROM  
DISK = N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Backup\Ekhosoft_DW_PROD.bak' 
WITH  FILE = 1,replace, NORECOVERY,  NOUNLOAD,  STATS = 5
RESTORE LOG [Ekhosoft_DW_PROD] FROM  
DISK = N'E:\MSSQLAgroInstances\SP115\MSSQL13.SP115\MSSQL\Backup\Ekhosoft_DW_PROD.bak' 
WITH  FILE = 2,  NORECOVERY,  NOUNLOAD,  STATS = 5

-- second attempt to rejoin, add it again
 :connect DCPSPEKHOSQL,2100

-- return to primary and re-add to group
  alter availability group AGEKHO1
add database [Ekhosoft_DW_PROD]



--- failovers 

--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect DCpSPEKHOSQL,2100
--- for the reboot
ALTER AVAILABILITY GROUP [AGEKHO1] FAILOVER;

GO
-- after reboot
:Connect DCSSPEKHOSQL,2100
ALTER AVAILABILITY GROUP [AGEKHO1] FAILOVER;

GO

