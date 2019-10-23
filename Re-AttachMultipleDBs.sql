USE [master]
GO
CREATE DATABASE [TheDBName] ON 
( FILENAME = N'F:\MSSQL\Data\TheDBName_Primary.mdf' ),
( FILENAME = N'l:\MSSQL\Data\TheDBName_Primary.ldf' )
 FOR ATTACH
GO
if exists (select name from master.sys.databases sd where name = N'TheDBName' and SUSER_SNAME(sd.owner_sid) = SUSER_SNAME() ) EXEC [TheDBName].dbo.sp_changedbowner @loginame=N'sa', @map=false
GO
USE [master]
GO
CREATE DATABASE [DBNameCPM] ON 
( FILENAME = N'F:\MSSQL\Data\DBNameCPM_Primary.mdf' ),
( FILENAME = N'l:\MSSQL\Data\DBNameCPM_log.ldf' )
 FOR ATTACH
GO
if exists (select name from master.sys.databases sd where name = N'DBNameCPM' and SUSER_SNAME(sd.owner_sid) = SUSER_SNAME() ) EXEC [DBNameCPM].dbo.sp_changedbowner @loginame=N'sa', @map=false
GO
USE [master]
GO
CREATE DATABASE [DBNameDataStore] ON 
( FILENAME = N'F:\MSSQL\Data\DBNameDataStore_Primary.mdf' ),
( FILENAME = N'l:\MSSQL\Data\DBNameDataStore_Primary.ldf' )
 FOR ATTACH
GO
if exists (select name from master.sys.databases sd where name = N'DBNameDataStore' and SUSER_SNAME(sd.owner_sid) = SUSER_SNAME() ) EXEC [DBNameDataStore].dbo.sp_changedbowner @loginame=N'sa', @map=false
GO
USE [master]
GO
CREATE DATABASE [DBNameIntelliSearch] ON 
( FILENAME = N'F:\MSSQL\Data\DBNameIntelliSearch.mdf' ),
( FILENAME = N'l:\MSSQL\Data\DBNameIntelliSearch_1.ldf')
 FOR ATTACH
GO
USE [master]
GO
CREATE DATABASE [DBNameInventoryManagement] ON 
( FILENAME = N'F:\MSSQL\Data\DBNameInventoryManagement_Primary.mdf' ),
( FILENAME = N'l:\MSSQL\Data\DBNameInventoryManagement_Primary.ldf')
 FOR ATTACH
GO
USE [master]
GO
CREATE DATABASE [DBNameKeywordsLearning] ON 
( FILENAME = N'F:\MSSQL\Data\DBNameKeywordsLearning.mdf' ),
( FILENAME = N'l:\MSSQL\Data\DBNameKeywordsLearning_1.ldf')
 FOR ATTACH
GO
USE [master]
GO
CREATE DATABASE [DBNameLogging] ON 
( FILENAME = N'F:\MSSQL\Data\DBNameLogging_Primary.mdf'),
( FILENAME = N'l:\MSSQL\Data\DBNameLogging_Primary.ldf')
 FOR ATTACH
GO
USE [master]
GO
CREATE DATABASE [DBNamemc] ON 
( FILENAME = N'F:\MSSQL\Data\DBNamemc_Primary.mdf'),
( FILENAME = N'l:\MSSQL\Data\DBNamemc_Primary.ldf')
 FOR ATTACH
GO
USE [master]
GO
CREATE DATABASE [DBNamemc_Products] ON 
( FILENAME = N'F:\MSSQL\Data\DBNamemc_Products_Primary.mdf'),
( FILENAME = N'l:\MSSQL\Data\DBNamemc_Products_Primary.ldf')
 FOR ATTACH
GO
