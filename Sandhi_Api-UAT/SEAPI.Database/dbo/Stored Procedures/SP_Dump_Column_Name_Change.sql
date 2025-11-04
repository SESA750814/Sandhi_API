-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- EXEC [SP_Dump_Column_Name_Change]
CREATE procedure [dbo].[SP_Dump_Column_Name_Change]	
AS
BEGIN
	IF COL_LENGTH('RAW_DUMP_HBN_PSI_Cooling', 'Work_Order_Work_Order_Number') IS NOT NULL
BEGIN
     exec sp_rename 'RAW_DUMP_HBN_PSI_Cooling.Work_Order_Work_Order_Number', 'Work_Order_Number', 'COLUMN';
END

IF COL_LENGTH('Cooling_RAW_DUMP_Expense', 'Work_Order_Work_Order_Number') IS NOT NULL
BEGIN
     exec sp_rename 'Cooling_RAW_DUMP_Expense.Work_Order_Work_Order_Number', 'Work_Order_Number', 'COLUMN';
END

END
