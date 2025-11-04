-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delete_SE_WorkOrder]
	as
BEGIN

	 -- Select WO_Month,WO_Year, * from SE_Work_Order where WO_Month = 1 and WO_year = 2022

Declare @W_month     int ;
Declare @W_Year int;

Set @W_month = 8
set @W_Year = 2022

--Select WO_Month,WO_Year, * from SE_Work_Order where WO_Month = @W_month and WO_year = @W_Year
exec Clear_Transaction
Delete from SE_Work_Order_Status where work_order_id in (Select id from SE_Work_Order where WO_Month = @W_month and WO_Year = @W_Year )

Delete from SE_Work_Order where WO_Month = @W_month and WO_Year = @W_Year

END
