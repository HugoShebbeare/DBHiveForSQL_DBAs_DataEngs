CREATE procedure [dbo].[USP_LongRunningTrans]
      @WaitTime     VARCHAR(10)= NULL,      -- long running threshold 
      @Alert        varchar(3) = NULL,      -- turn on/off alert logging
      @LogInfo      varchar(3) = NULL       -- return status even if nothing found
as

-- identify long running transactions, updating Daniel Migotto's code

DECLARE @intWaitTime INT;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
---SET NOCOUNT ON;  - when it becomes a stored proc

-- Remove any leading/trailing spaces from parameters
SET @WaitTime = LTRIM(RTRIM(@WaitTime));

IF ISNUMERIC(@WaitTime) = 1
BEGIN
    SELECT @intWaitTime = CONVERT(INT, @WaitTime);
    IF @intWaitTime < 0
        SELECT @intWaitTime = 0;
END;
ELSE
    SET @intWaitTime = 1; -- default to one minute

IF EXISTS
(
    SELECT *
    FROM master.dbo.sysprocesses WITH (NOLOCK)
    WHERE net_address <> ''
          AND spid <> @@SPID
          AND program_name NOT LIKE 'SQLAgent%'
          AND program_name NOT LIKE 'Lumigent%'
          AND program_name NOT IN ( 'Microsoft SQL Server', 'SQL Profiler' )
          AND cmd <> 'AWAITING COMMAND'
          AND last_batch > login_time
          AND last_batch <> '1900-01-01 00:00:00.000'
          AND DATEDIFF(MINUTE, last_batch, GETDATE()) > @intWaitTime
)
BEGIN
    SELECT CONVERT(CHAR(23), GETDATE(), 121),
           'Long running Transaction encountered: ';
    SELECT DISTINCT
        'SPID' = STR(spid, 5),
        'Status' = CONVERT(CHAR(10), status),
        open_tran,
        waittype,
        Duration = RIGHT(CONVERT(CHAR(3), DATEDIFF(ss, last_batch, GETDATE()) / 3600 + 100), 2) + ':'
                   + RIGHT(CONVERT(
                                      CHAR(3),
                                      (DATEDIFF(ss, last_batch, GETDATE())
                                       - (DATEDIFF(ss, last_batch, GETDATE()) / 3600 * 3600)
                                      ) / 60 + 100
                                  ), 2) + ':'
                   + RIGHT(CONVERT(
                                      CHAR(3),
                                      DATEDIFF(ss, last_batch, GETDATE())
                                      - ((DATEDIFF(ss, last_batch, GETDATE()) / 60) * 60) + 100
                                  ), 2),
        last_batch = CONVERT(CHAR(25), last_batch, 121),
        'Blk' = STR(blocked, 5),
        'HostName' = CONVERT(VARCHAR(20), COALESCE(NULLIF(hostname, ''), net_address)),
        'User' = CONVERT(CHAR(15), loginame),
        'DBName' = CONVERT(CHAR(30), DB_NAME(dbid)),
        'Program' = CONVERT(CHAR(20), program_name),
        'COMMAND' = CONVERT(CHAR(16), cmd),
        '    CPU' = STR(cpu, 8),
        '     IO' = STR(physical_io, 9),
        'Waittime' = STR(waittime, 8)
    FROM master.dbo.sysprocesses WITH (NOLOCK)
    WHERE net_address <> ''
          AND SPID <> @@SPID
          AND program_name NOT LIKE 'SQLAgent%'
          AND program_name NOT LIKE 'Lumigent%'
          AND program_name NOT IN ( 'Microsoft SQL Server', 'SQL Profiler' )
          AND cmd <> 'AWAITING COMMAND'
          AND last_batch > login_time
          AND last_batch <> '1900-01-01 00:00:00.000'
          AND DATEDIFF(MINUTE, last_batch, GETDATE()) > @intWaitTime
    ORDER BY 1;
	-- shall we add this to a policy instead?
    IF UPPER(SUBSTRING(@Alert, 1, 1)) = 'Y'
    --BEGIN
    --    RAISERROR(50002, 10, 1, @intWaitTime);
    --END;

END;

ELSE
BEGIN
    IF UPPER(SUBSTRING(@LogInfo, 1, 1)) = 'Y'
        SELECT CONVERT(CHAR(23), GETDATE(), 121),
               'There are NO long running transactions at this time.';
END;

RETURN;
GO