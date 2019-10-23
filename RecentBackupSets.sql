select @@servername [Server\Instance], a.DbName, a.recovery_model_desc, a.[isAG], b.nbr as NbFull, c.nbr as NbDiff, d.nbr as NbLogs, convert(varchar(10),getdate(),120) SnapDate

from 

    (select name AS "DbName", recovery_model_desc,case when replica_id is null then 'NO' else 'YES' END as [isAG] from sys.databases) a 

            full outer join 

    (SELECT

         [database_name] AS "DbName",

         count(1) nbr

     FROM msdb.dbo.backupset

     WHERE convert(varchar(10),[backup_start_date],120) >= convert(varchar(10),getdate()-7,120)

             and type = 'D' --Full

     GROUP BY [database_name]) b on a.DbName = b.DbName

            full outer join 

    (SELECT

         [database_name] AS "DbName",

         count(1) nbr

     FROM msdb.dbo.backupset

     WHERE convert(varchar(10),[backup_start_date],120) >= convert(varchar(10),getdate()-7,120)

             and type = 'I' --Diff

     GROUP BY [database_name]) c on a.DbName = c.DbName 

            full outer join 

    (SELECT

         [database_name] AS "DbName",

         count(1) nbr

     FROM msdb.dbo.backupset

     WHERE convert(varchar(10),[backup_start_date],120) >= convert(varchar(10),getdate()-7,120)

             and type = 'L' --Logs

     GROUP BY [database_name]) d on a.DbName = d.DbName 
