
USE master;  
GO
DROP LOGIN [Server2] 
go
DROP CERTIFICATE Server2;
go
CREATE CERTIFICATE Server2
--   AUTHORIZATION [Server2]  
 FROM FILE = 't:\temp\Server2.cer'  
 USE [master]
GO

/****** Object:  Login [Server2]    Script Date: 12/31/2017 4:16:30 PM ******/
CREATE LOGIN [Server2] FROM CERTIFICATE [Server1]
-- on 167
GO


 USE [MediaOptimise2]
GO
DROP USER [Server1]
CREATE USER [Server1] FOR CERTIFICATE [Server1]
GO
USE [master]
GO
CREATE LOGIN [Server1] FROM CERTIFICATE [Server1]
GO
ALTER SERVER ROLE [ServerRole-MirrorEndPointMembers] ADD MEMBER [Server1]
GO
ALTER SERVER ROLE [ServerRole-MirrorEndPointMembers] ADD MEMBER [Server2]
USE [MediaOptimise2]
GO
--CREATE USER [Server1] FOR LOGIN [Server1]
GO
USE [MediaOptimise2]
GO
ALTER ROLE [db_owner] ADD MEMBER [Server1]
GO


CREATE CERTIFICATE [Server1] WITH SUBJECT 'Principal Mirror Cert'; 
WITH SUBJECT 'Principal mirror Partner';
-- users created on each server.
:CONNECT [...\instance]
USE [master]
GO
CREATE LOGIN [Server2] FROM CERTIFICATE [Server1]
GO
:CONNECT [...\instance]
USE [master]
GO
CREATE LOGIN [Server1] FROM CERTIFICATE [Server2]
GO
CREATE LOGIN [Server2] FROM CERTIFICATE [Server1]

--couldn't get this towork
create ENDPOINT [MoMirror] 
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER,-- AUTHENTICATION = CERTIFICATE Server2,
 ENCRYPTION = REQUIRED ALGORITHM AES)
GO

Grant Connect on EndPoint::MoMirror to Server1

Grant Connect on EndPoint::MoMirror to Server2

DROP ENDPOINT MoMirror;
	--  alter endpoint
	--http://dbhive.blogspot.ca/2010/12/
	--inbound first  https://docs.microsoft.com/en-us/sql/database-engine/database-mirroring/use-certificates-for-a-database-mirroring-endpoint-transact-sql
	--https://docs.microsoft.com/en-us/sql/database-engine/database-mirroring/database-mirroring-use-certificates-for-inbound-connections

