--select * from SE_WORK_ORDER where  WO_BusinessUnit like 'Cooling'
 --select Cooling_Mileage_Actual_Expenses from Cooling_Work_Order where Cooling_Mileage_Actual_Expenses is null
--exec usp_ImportMainData
-- delete from SE_WORK_ORDER
-- select Work_Order_number from SE_Work_Order group by Work_Order_number having Count(*) > 1
-- select * from SE_Work_order where Work_Order_Number = 'WO-08889515'
--select * from SE_Work_order where WO_BusinessUnit='Cooling'
CREATE procedure [dbo].[usp_ImportMainData]
AS
begin
 

delete from SE_WORK_ORDER 
	where 
		month_name in 
			(
				Select 
					DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),WO_MONTH), '2020-12-01')) + '-' + wo_Year
				FROM [dbo].[HBN_Work_Order]
			) 
			and wo_businessunit='HBN'
  
	insert into SE_WORK_ORDER(
	WO_BusinessUnit ,[Work_Order_Number]
      ,[Case]
      ,[PRF_Number]
      ,[First_Assigned_DateTime]
      ,[Customer_Requested_Date]
      ,[FSR_Internal_Comments]
      ,[WO_Created_Date_Time]
      ,[Main_Installed_Product]
      ,[Product]
      ,[Product_Commercial_Reference]
      ,[Product_Grouping]
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
      ,[Partner_Account_Rv]
      ,[Work_Performed]
      ,[Work_Order_Type]
      ,[Contact]
      ,[Contact_Phone]
      ,[Work_Order_Sub_Type]
      ,[Work_Order_Status]
      ,[WO_Completed_Timestamp]
      ,[Comments_to_Planner]
      ,[Special_Instructions]
      ,[Actual_Expense_converted]
      ,[Actual_Expense_converted_Currency]
      ,[Actual_Expense]
      ,[Claim_Type]
      ,[CSS_ID]
      ,[Branch_Code]
      ,[Payout_Type]
      ,[Region]
      ,[Call_type]
      ,[Call_type_rv]
      ,[IsMaterialUsed]
      ,[PRODUCT_CATEGORY]
      ,[Distance_Slab]
      ,[Repeat_Yes_No]
      ,[Claim]
      ,[Remarks]
    
      ,[Bill_Cycle]
      ,[Business_Unit]
      ,[DS_Code]
      ,[MaterialUsed]    
      ,[Actual_Cost]      
      ,[User_ID]
      ,[Update_Date_Time]
      ,[Loaded_Date]
      ,[WO_Month]
      ,[WO_Year]
       ,[MONTH_NAME]
	   ,Services_Business_Unit
	   ,Is_RepeatCall_NonMaterial
	    ,[AMC_WARRANTY_FLAG]
		,WO_Process_Status
	)

	SELECT 'HBN'
      ,a.[Work_Order_Number]
      ,a.[Case]
      ,a.[PRF_Number]
      ,a.[First_Assigned_DateTime]
      ,a.[Customer_Requested_Date]
      ,a.[FSR_Internal_Comments]
      ,a.[WO_Created_Date_Time]
      ,a.[Main_Installed_Product]
      ,a.[Product]
      ,a.[Product_Commercial_Reference]
      ,a.[Product_Grouping]
      ,a.[IP_Serial_Number]
      ,a.[Work_Order_Reason]
      ,a.[Work_Order_Created_Date]
      ,a.[Completed_On]
      ,a.[Is_Billable]
     
      ,a.[Non_Billing_Reason]
      ,a.[Installed_At_Account]
      ,a.[Street]
      ,a.[City]
      ,a.[Zip]
      ,a.[State]
      ,a.[Service_Team]
      ,a.[Primary_FSR]
      ,a.[Partner_Account]
      ,a.[Partner_Account_Rv]
      ,a.[Work_Performed]
      ,a.[Work_Order_Type]
      ,a.[Contact]
      ,a.[Contact_Phone]
      ,a.[Work_Order_Sub_Type]
      ,a.[Work_Order_Status]
      ,a.[WO_Completed_Timestamp]
      ,a.[Comments_to_Planner]
      ,a.[Special_Instructions]
      ,a.[Actual_Expense_converted]
      ,a.[Actual_Expense_converted_Currency]
      ,a.[Actual_Expense]
      ,a.[Claim_Type]
      ,b.ID
      ,a.[Branch_Code]
      ,a.[Payout_Type]
      ,a.[Region]
      ,a.[Call_type]
      ,a.[Call_type_rv]
      ,a.[IsMaterialUsed]
      ,a.[PRODUCT_CATEGORY]
      ,a.[Distance_Slab]
      ,a.[Repeat_Yes_No]
      ,a.[Claim]
      ,a.[Remarks]
     
      ,a.[Bill_Cycle]
      ,a.[Business_Unit]
      ,a.[DS_Code]
      ,a.[MaterialUsed]
      ,a.[Claim]
      ,a.[User_ID]
      ,a.[Update_Date_Time]
      ,a.[Loaded_Date]
      ,a.[WO_Month]
      ,a.[WO_Year]
      ,DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),WO_MONTH), '2020-12-01')) + '-' + wo_Year
	  ,a.Services_Business_Unit
	  ,a.Is_RepeatCall_NonMeterial
	  ,a.[Claim_Type]
	  ,-99
  FROM [dbo].[HBN_Work_Order] a 
  inner join dbo.[SE_CSS_MASTER] b on a.css_code = b.css_code 

  
	delete from SE_WORK_ORDER 
	where 
		month_name in 
			(
				Select 
					DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),WO_MONTH), '2020-12-01')) + '-' + wo_Year
				FROM [dbo].[PSI_Work_Order]
			) 
			and wo_businessunit='PPI'


	insert into SE_WORK_ORDER(
	WO_BusinessUnit ,[Work_Order_Number]
      ,[Case]
      ,[PRF_Number]
      ,[First_Assigned_DateTime]
      ,[Customer_Requested_Date]
      ,[FSR_Internal_Comments]
      ,[WO_Created_Date_Time]
      ,[Main_Installed_Product]
      ,[Product]
      ,[Product_Commercial_Reference]
      ,[Product_Grouping]
      ,[IP_Serial_Number]
      ,[Work_Order_Reason]
      ,[Work_Order_Created_Date]
      ,[Completed_On]
      ,[Is_Billable]
      ,[Is_RepeatCall_NonMaterial]
      ,[Non_Billing_Reason]
      ,[Installed_At_Account]
      ,[Street]
      ,[City]
      ,[Zip]
      ,[State]
      ,[Service_Team]
      ,[Primary_FSR]
      ,[Partner_Account]
      ,[Partner_Account_Rv]
      ,[Work_Performed]
      ,[Work_Order_Type]
      ,[Contact]
      ,[Contact_Phone]
      ,[Work_Order_Sub_Type]
      ,[Work_Order_Status]
      ,[WO_Completed_Timestamp]
      ,[Comments_to_Planner]
      ,[Special_Instructions]
      ,[Actual_Expense_converted]
      ,[Actual_Expense_converted_Currency]
      ,[Actual_Expense]
      ,[Claim_Type]
      ,[CSS_ID]
      ,[Branch_Code]
      ,[Payout_Type]
      ,[Region]
      ,[Call_type]
      ,[Call_type_rv]
      ,[IsMaterialUsed]
      ,[PRODUCT_CATEGORY]
      ,[Distance_Slab]
      ,[Repeat_Yes_No]
      ,[Claim]
      ,[Remarks]
      ,[Region_Remarks]
      ,[Bill_Cycle]
      ,[Business_Unit]
      ,[DS_Code]
      ,[MaterialUsed]    
      ,[Actual_Cost]      
      ,[User_ID]
      ,[Update_Date_Time]
      ,[Loaded_Date]
      ,[WO_Month]
      ,[WO_Year]
       ,[MONTH_NAME]
	   ,Services_Business_Unit
	   ,[AMC_WARRANTY_FLAG]	
	   ,WO_Process_Status
	)

	SELECT 'PPI'
      ,a.[Work_Order_Number]
      ,a.[Case]
      ,a.[PRF_Number]
      ,a.[First_Assigned_DateTime]
      ,a.[Customer_Requested_Date]
      ,a.[FSR_Internal_Comments]
      ,a.[WO_Created_Date_Time]
      ,a.[Main_Installed_Product]
      ,a.[Product]
      ,a.[Product_Commercial_Reference]
      ,a.[Product_Grouping]
      ,a.[IP_Serial_Number]
      ,a.[Work_Order_Reason]
      ,a.[Work_Order_Created_Date]
      ,a.[Completed_On]
      ,a.[Is_Billable]
      ,a.[Is_RepeatCall_NonMeterial]
      ,a.[Non_Billing_Reason]
      ,a.[Installed_At_Account]
      ,a.[Street]
      ,a.[City]
      ,a.[Zip]
      ,a.[State]
      ,a.[Service_Team]
      ,a.[Primary_FSR]
      ,a.[Partner_Account]
      ,a.[Partner_Account_Rv]
      ,a.[Work_Performed]
      ,a.[Work_Order_Type]
      ,a.[Contact]
      ,a.[Contact_Phone]
      ,a.[Work_Order_Sub_Type]
      ,a.[Work_Order_Status]
      ,a.[WO_Completed_Timestamp]
      ,a.[Comments_to_Planner]
      ,a.[Special_Instructions]
      ,a.[Actual_Expense_converted]
      ,a.[Actual_Expense_converted_Currency]
      ,a.[Actual_Expense]
      ,a.[Claim_Type]
      ,b.ID
      ,a.[Branch_Code]
      ,a.[Payout_Type]
      ,a.[Region]
      ,a.[Call_type]
      ,a.[Call_type_rv]
      ,a.[IsMaterialUsed]
      ,a.[PRODUCT_CATEGORY]
      ,a.[Distance_Slab]
      ,a.[Repeat_Yes_No]
      ,a.[Claim]
      ,a.[Remarks]
      ,a.[Region_Remarks_If_Any_on_Additional_payout_Repeat_cases_Re]
      ,a.[Bill_Cycle]
      ,a.[Business_Unit]
      ,a.[DS_Code]
      ,a.[MaterialUsed]
      ,a.[Claim]
      ,a.[User_ID]
      ,a.[Update_Date_Time]
      ,a.[Loaded_Date]
      ,a.[WO_Month]
      ,a.[WO_Year]
      ,DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),WO_MONTH), '2020-12-01')) + '-' + wo_Year
	  ,a.Services_Business_Unit
	  ,a.[Claim_Type]
	  ,-99
  FROM [dbo].[PSI_Work_Order] a 
  inner join dbo.[SE_CSS_MASTER] b on a.css_code = b.css_code 

  -- Load cooling data to SE_Work_Order

  delete from SE_WORK_ORDER 
	where 
		month_name in 
			(
				Select 
					DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),WO_MONTH), '2020-12-01')) + '-' + wo_Year
				FROM [dbo].[Cooling_Work_Order]
			) 
			and wo_businessunit='Cooling'

   
	insert into SE_WORK_ORDER(
	WO_BusinessUnit ,[Work_Order_Number]
      ,[Case]
      ,[PRF_Number]
      ,[First_Assigned_DateTime]
      ,[Customer_Requested_Date]
      ,[FSR_Internal_Comments]
      ,[WO_Created_Date_Time]
      ,[Main_Installed_Product]
      ,[Product]
      ,[Product_Commercial_Reference]
      ,[Product_Grouping]
      ,[IP_Serial_Number]
      ,[Work_Order_Reason]
      ,[Work_Order_Created_Date]
      ,[Completed_On]
      ,[Is_Billable]
      ,[Is_RepeatCall_NonMaterial]
      ,[Non_Billing_Reason]
      ,[Installed_At_Account]
      ,[Street]
      ,[City]
      ,[Zip]
      ,[State]
      ,[Service_Team]
      ,[Primary_FSR]
      ,[Partner_Account]
      ,[Partner_Account_Rv]
      ,[Work_Performed]
      ,[Work_Order_Type]
      ,[Contact]
      ,[Contact_Phone]
      ,[Work_Order_Sub_Type]
      ,[Work_Order_Status]
      ,[WO_Completed_Timestamp]
      ,[Comments_to_Planner]
      ,[Special_Instructions]
      ,[Actual_Expense_converted]
      ,[Actual_Expense_converted_Currency]
      ,[Actual_Expense]
      ,[Claim_Type]
      ,[CSS_ID]
      ,[Branch_Code]
      ,[Payout_Type]
      ,[Region]
      ,[Call_type]
      ,[Call_type_rv]
     
      ,[PRODUCT_CATEGORY]
      ,[Distance_Slab]
   
   
      ,[Remarks]
      ,[Region_Remarks]
      ,[Bill_Cycle]
      ,[Business_Unit]
      ,[DS_Code]
      ,[MaterialUsed]    
        
      ,[User_ID]
      ,[Update_Date_Time]
      ,[Loaded_Date]
      ,[WO_Month]
      ,[WO_Year]
       ,[MONTH_NAME]
	

	
	,[Actual_Expenses_Mileage] 
	
	,[Actual_Expenses_Gas] 
	
	,[Actual_Expenses_Supplies] 
	
	,[LABOUR_COST]		
	,[SUPPLY_COST]			
	
	,[AMC_WARRANTY_FLAG]				
	,Claim
	,[Actual_Cost]
	,LABOUR_DESC
	,SUPPLY_DESC
	,MILEAGE_DESC
	,Services_Business_Unit
	,WO_Process_Status

	)

	SELECT 'Cooling'
      ,a.[Work_Order_Number]
      ,a.[Case]
      ,a.[PRF_Number]
      ,a.[First_Assigned_DateTime]
      ,a.[Customer_Requested_Date]
      ,a.[FSR_Internal_Comments]
      ,a.[WO_Created_Date_Time]
      ,a.[Main_Installed_Product]
      ,a.[Product]
      ,a.[Product_Commercial_Reference]
      ,a.[Product_Grouping]
      ,a.[IP_Serial_Number]
      ,a.[Work_Order_Reason]
      ,a.[Work_Order_Created_Date]
      ,a.[Completed_On]
      ,a.[Is_Billable]
      ,a.[Is_RepeatCall_NonMeterial]
      ,a.[Non_Billing_Reason]
      ,a.[Installed_At_Account]
      ,a.[Street]
      ,a.[City]
      ,a.[Zip]
      ,a.[State]
      ,a.[Service_Team]
      ,a.[Primary_FSR]
      ,a.[Partner_Account]
      ,a.[Partner_Account_Rv]
      ,a.[Work_Performed]
      ,a.[Work_Order_Type]
      ,a.[Contact]
      ,a.[Contact_Phone]
      ,a.[Work_Order_Sub_Type]
      ,a.[Work_Order_Status]
      ,a.[WO_Completed_Timestamp]
      ,a.[Comments_to_Planner]
      ,a.[Special_Instructions]
      ,a.[Actual_Expense_converted]
      ,a.[Actual_Expense_converted_Currency]
      ,a.[Actual_Expense]
      ,a.[Claim_Type]
      ,b.ID
      ,a.[Branch_Code]
      ,a.[Payout_Type]
      ,a.[Region]
      ,a.[Call_type]
      ,a.[Call_type_rv]
     
      ,a.[PRODUCT_CATEGORY]
      ,a.[Distance_Slab]
     
 
      ,a.[Remarks]
      ,a.[Region_Remarks_If_Any_on_Additional_payout_Repeat_cases_Re]
      ,a.[Bill_Cycle]
      ,a.[Business_Unit]
      ,a.[DS_Code]
      ,a.[MaterialUsed]
    
      ,a.[User_ID]
      ,a.[Update_Date_Time]
      ,a.[Loaded_Date]
      ,a.[WO_Month]
      ,a.[WO_Year]
      ,DATENAME(MONTH, DATEADD(MONTH, convert(Decimal(18,0),WO_MONTH), '2020-12-01')) + '-' + wo_Year

	,a.[Cooling_Mileage_Actual_Expenses]
	--,cast(a.[Cooling_Mileage_Actual_Expenses] as decimal(5,2))
	,a.[Cooling_Gas_Actual_Expenses]
	--,cast(a.[Cooling_Gas_Actual_Expenses] as decimal(5,2)) 
	,a.[Cooling_Supplies_Actual_Expenses]
	--,cast(a.[Cooling_Supplies_Actual_Expenses] as decimal(5,2)) 
	
	,cast(a.[Cooling_Labour_Cost] as decimal(18,2))
	,cast(a.[Cooling_Supply_Cost] as decimal(18,2))		
	
	,a.[Claim_Type]				
	,cast(a.[Cooling_Total_Cost] as decimal(18,2))	
	,cast(a.[Cooling_Total_Cost] as decimal(20,2))	
	,a.Cooling_Supplies_Work_Description
	,a.Cooling_Gas_Work_Description
	,a.Cooling_Mileage_Work_Description
	,a.Services_Business_Unit
	,-99
	
  FROM [dbo].[Cooling_Work_Order] a 
  inner join dbo.[SE_CSS_MASTER] b on a.css_code = b.css_code 

--  update SE_Work_Order
--set 
-- = -99

end
