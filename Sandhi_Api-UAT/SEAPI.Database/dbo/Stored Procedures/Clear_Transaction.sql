-- =============================================
-- Author:		<Muthukrishnan marimuthu>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[Clear_Transaction] 
AS
BEGIN

delete from HBN_RAW_DUMP
delete From PSI_RAW_DUMP
Delete from Cooling_RAW_DUMP

delete from HBN_Work_Order
delete from HBN_RepeatCalls

delete from PSI_Work_Order

delete from Cooling_Expense
delete from Cooling_Work_Order



END
