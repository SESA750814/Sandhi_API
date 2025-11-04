-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,>
-- Description:	<PSI Work Order Process,,>
-- =============================================
CREATE procedure [dbo].[SP_PSI_Insert_Transaction]
	-- Add the parameters for the stored procedure here
AS
BEGIN




Declare @W_month  nvarchar(2)
Declare @W_Year nvarchar(4)
--select @W_month = month(format(try_convert(datetime,Completed_On),'dd/MM/yyyy '))
--,@W_Year = year(format(try_convert(datetime,Completed_On),'dd/MM/yyyy '))   from PSI_RAW_DUMP 
--where month(format(try_convert(datetime,Completed_On),'dd/MM/yyyy ')) is not null and  month(format(try_convert(datetime,Completed_On),'dd/MM/yyyy ')) <> ''
----print @W_month
--print @W_Year
select @W_month=cmonth,@W_Year = cyear from month_year
--print @W_month
--print @W_Year


INSERT INTO [dbo].[PSI_Work_Order] 
           ([Work_Order_Number]
           ,[Case]
           ,[First_Assigned_DateTime]
           ,[Customer_Requested_Date]
           ,[FSR_Internal_Comments]
           ,[WO_Created_Date_Time]
           ,[Main_Installed_Product]
           ,[Product]
           ,[Product_Commercial_Reference]
           ,[IP_Serial_Number]
           ,[Work_Order_Reason]
           ,[Work_Order_Created_Date]
           ,[Completed_On]
           ,[Is_Billable]
           ,[Non_Billing_Reason]
           ,[Installed_At_Account]
           ,[Street]
           ,[City]
           ,[Zip]
           ,[State]
           ,[Service_Team]
           ,[Primary_FSR]
           ,[Partner_Account]
           ,[Work_Performed]
           ,[Work_Order_Type]
           ,[Contact]
           ,[Contact_Phone]
           ,[Work_Order_Sub_Type]
           ,[Work_Order_Status]
           ,[WO_Completed_Timestamp]
           ,[Comments_to_Planner]
           ,[Special_Instructions]
		   ,[Distance_Slab]
           ,[Actual_Expense_converted]
           ,[Actual_Expense_converted_Currency]
           ,[Actual_Expense] 
		   ,PRODUCT_CATEGORY
		   ,Loaded_Date
		   ,WO_Month
		   ,WO_Year
		   ,Month_Name
		   ,Services_Business_Unit)  
     Select 
            [Work_Order_Work_Order_Number]
           ,[Case]
           ,[First_Assigned_DateTime]
           ,[Customer_Requested_Date]
           ,[FSR_Internal_Comments]
           ,[WO_Created_Date_Time]
           ,[Main_Installed_Product]
           ,[Product]
           ,[Product_Commercial_Reference]
           ,[IP_Serial_Number]
           ,[Work_Order_Reason]
           ,[Work_Order_Created_Date]
           ,[Completed_On]
           ,[Is_Billable]
           ,[Non_Billing_Reason]
           ,[Installed_At_Account]
           ,[Street]
           ,[City]
           ,[Zip]
           ,[State]
           ,[Service_Team]
           ,[Primary_FSR]
           ,[Partner_Account]
           ,[Work_Performed]
           ,[Work_Order_Type]
           ,''
           ,''
           ,[Work_Order_Sub_Type]
           ,[Work_Order_Status]
           ,[WO_Completed_Timestamp]
           ,[Comments_to_Planner]
           ,[Special_Instructions]
		   ,NULL -- Distance Slab
           ,CONVERT(INT, ROUND([Actual_Expense_converted],0)) as [Actual_Expense_converted]
           ,[Actual_Expense_converted_Currency]
           ,[Actual_Expense] 
		   ,'PSI'
			 , GETDATE()
		   ,@W_month
		   ,@W_Year
		   ,DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),Month(DATEADD(month, -1, GETDATE()))), '2020-12-01')) + '-' + cast(Year(DATEADD(Year, 0,GETDATE())) as varchar(10))
		   ,Services_Business_Unit
		   from [dbo].[PSI_RAW_DUMP]  Where Is_Billable like 'NO'
		   and Work_Order_Status like  '%8- Service Completed%'
			or Work_Order_Status like  '%9- Service Validated%'
			or Work_Order_Status like  '%10- Closed%'
END
