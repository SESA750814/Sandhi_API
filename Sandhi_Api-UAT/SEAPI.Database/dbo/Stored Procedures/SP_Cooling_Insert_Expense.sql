-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,>
-- Description:	<Cooling Work Order Process,,>
-- =============================================
--delete from Cooling_Expense
--exec SP_Cooling_Insert_Expense
CREATE procedure [dbo].[SP_Cooling_Insert_Expense]
	-- Add the parameters for the stored procedure here
AS
BEGIN



delete from Cooling_Expense
INSERT INTO [dbo].[Cooling_Expense]
           ([Work_Order_Number]
           ,[Work_Detail_Type]
         --  ,[Price_Per_Unit_Currency]
          -- ,[Price_Per_Unit]
           ,[Line_Price_Per_Unit_Currency]
           ,[Line_Price_Per_Unit]
           ,[Expense_Quantity]
           ,[Work_Description]
           ,[Total_Expense_Currency]
           ,[Total_Expense]
           ,[Work_Order_Type]
           ,[Main_Installed_Product]
           ,[Product_Range]
           ,[Service_Team]
           ,[Primary_FSR]
           ,[Work_Detail_Line_Number]
		   ,Month_Name)
		  select
            Work_Order_Work_Order_Number
           ,Work_Detail_Type 
         --  ,Price_Per_Unit_Currency
          -- ,Price_Per_Unit 
           ,Line_Price_Per_Unit_Currency 
           ,Line_Price_Per_Unit
           ,Expense_Quantity 
           ,Work_Description 
           ,Total_Expense_Currency
           ,Total_Expense
           ,Work_Order_Type
           ,Main_Installed_Product
           ,Product_Range
           ,Service_Team
           ,Primary_FSR
           ,Work_Detail_Line_Number
		   ,DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),Month(DATEADD(month, -1, GETDATE()))), '2020-12-01')) + '-' + cast(Year(DATEADD(Year, 0,GETDATE())) as varchar(10))

		   
		   from RAW_DUMP_Cooling_Expense

End
