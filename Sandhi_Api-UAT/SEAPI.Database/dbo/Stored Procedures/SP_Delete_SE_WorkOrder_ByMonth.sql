-- =============================================
-- Author:		Ganesan Mani
-- Create date: 25/10/22
-- Description:	Created for clear transaction based on the month.
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delete_SE_WorkOrder_ByMonth]
@W_month int,
@W_Year int
	as
BEGIN

	 -- Select WO_Month,WO_Year, * from SE_Work_Order where WO_Month = 1 and WO_year = 2022

--Declare @W_month     int ;
--Declare @W_Year int;

--Set @W_month = 3
--set @W_Year = 2022
EXECUTE [dbo].[Clear_Transaction] ;

--Select WO_Month,WO_Year, * from SE_Work_Order where WO_Month = @W_month and WO_year = @W_Year

Delete from SE_Work_Order_Status where work_order_id in (Select id from SE_Work_Order where WO_Month = @W_month and WO_Year = @W_Year )

Delete from SE_Work_Order where WO_Month = @W_month and WO_Year = @W_Year

END
