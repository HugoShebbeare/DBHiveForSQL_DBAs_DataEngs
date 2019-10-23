USE [Shoprite]
GO

/****** Object:  StoredProcedure [dbo].[PurgeInactiveCustomer_ListItems]    Script Date: 4/9/2018 7:12:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--EXEC dbo.[PurgeInactiveCustomer_ListItems]
create PROCEDURE [dbo].[PurgeInactiveCustomer_ListItems] 
--(
-- -- @Top INT --how many records to be deleted in a batch
--)
-- Description:  
-- ================================================================================================================== 
-- Remove listitems for ShopRite V5 users who haven't logged into the site in the last two years.
-- ================================================================================================================== 
-- Modifications:  
-- ==================================================================================================================
-- 2018-02-05 Alina Pop: Created	
-- ==================================================================================================================
AS
BEGIN
  --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET NOCOUNT ON

  DECLARE @Rowcount INT,
		  @Top  INT
  
  
  CREATE TABLE #tmpList

	(ListID uniqueidentifier not null Primary Key
	);

  declare @List table
	(
	ListID uniqueidentifier not null Primary Key
	)
	
 	   
 set @Top = dbo.ufnGetNumberToPurge(GETDATE())

 
  -- load temp table do the join once
  Insert into #tmpList
   select L.ListID
		from [Shopping].[List] L 
		inner join [Shopping].[ExpiredListCustomers] LC on L.ListOwnerID =LC.CustomerGuid		 
  order by L.ListID
	--700k
 
  --------************** mdc
  -- load temp table to do first cycle
  Insert into @List
  select top (@Top) ListID
  from #tmpList
  order by ListID

  set @Rowcount = @@RowCount

	  WHILE @Rowcount > 0
	  BEGIN
			print GetDate()

			DELETE [Shopping].[ListItem]
			FROM [Shopping].[ListItem] LI
			INNER JOIN @List L ON L.ListID = LI.ListID 

			
			DELETE [Shopping].[List]
			FROM  [Shopping].[List] SL
			INNER JOIN @List L ON L.ListID = SL.ListID
			
			-- Clean that batch from temp table
			DELETE #tmpList
			FROM #tmpList tL
			inner join @List LId on LId.ListID = tL.ListID

			-- clean up for next loop
			delete from @List
			 
			set @Top = dbo.ufnGetNumberToPurge(GETDATE())
			
			-- load next loop
			 Insert into @List
			 select top (@Top) ListID
			 from #tmpList
			 order by ListID

			SET @rowcount = @@rowcount
	  END
END 

drop table #tmpList
GO

