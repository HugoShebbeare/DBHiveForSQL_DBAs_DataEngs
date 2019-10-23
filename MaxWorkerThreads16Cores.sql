EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE ;  
GO  
EXEC sp_configure 'max worker threads', 735 ;  
GO
RECONFIGURE WITH OVERRIDE;  
  