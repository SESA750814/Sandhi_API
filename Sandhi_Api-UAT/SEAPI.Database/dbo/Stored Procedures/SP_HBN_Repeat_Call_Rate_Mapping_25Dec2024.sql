
-- =============================================
-- Author:		Niraj
-- Create date: <25-12-2024,,> 
-- Description:	<HBN Work Order Repeat Call marking Process,,>
-- =============================================

--exec SP_HBN_Repeat_Call_Rate_Mapping
CREATE procedure [dbo].[SP_HBN_Repeat_Call_Rate_Mapping_25Dec2024]
	-- Add the parameters for the stored procedure here
AS
BEGIN
-- Find Repeate Calls more than 1
IF OBJECT_ID(N'dbo.HBN_RepeatCalls', N'U') IS NOT NULL  
   drop table  [dbo].HBN_RepeatCalls; 
 -- Get records from HBN_Work_order which has more than one
print '***Inside Repeat Call - HBN_RepeatCalls Table dropped***'
SELECT * INTO [dbo].HBN_RepeatCalls 
 FROM HBN_Work_Order 
where IP_Serial_Number in
(select IP_Serial_Number
from HBN_Work_Order
group by IP_Serial_Number
having count(*) > 1) 
--AND Work_Order_Type in ( 'Repair')

print '***Inside Repeat Call - Record inserted from HBN_Work_Order into HBN_RepeatCalls***'
-- Get records from the last month with same ip_serial_number within a month
INSERT INTO HBN_RepeatCalls
([Work_Order_Number]
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
      ,[CSS_Status]
      ,[CSS_User]
      ,[CSS_Mgr_Status]
      ,[CSS_Remark]
      ,[CSS_Cost]
      ,[CSS_Mgr_Remark]
      ,[CSS_Mgr_Cost]
      ,[CSS_Mgr_User]
      ,[Actual_Cost]
      ,[WO_Process_Status]
      ,[CSS_Attachment]
      ,[User_ID]
      ,[Update_Date_Time]
      ,[Loaded_Date]
      ,[WO_Month]
      ,[WO_Year]
      ,[month_name]
      ,[Services_Business_Unit])

Select[Work_Order_Number]
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
      ,[CSS_Status]
      ,[CSS_User]
      ,[CSS_Mgr_Status]
      ,[CSS_Remark]
      ,[CSS_Cost]
      ,[CSS_Mgr_Remark]
      ,[CSS_Mgr_Cost]
      ,[CSS_Mgr_User]
      ,[Actual_Cost]
      ,[WO_Process_Status]
      ,[CSS_Attachment]
      ,[User_ID]
      ,[Update_Date_Time]
      ,[Loaded_Date]
      ,[WO_Month]
      ,[WO_Year]
      ,[month_name]
      ,[Services_Business_Unit]
from SE_WORK_ORDER where IP_Serial_Number in 
(select a.IP_Serial_Number from HBN_Work_Order a, SE_Work_Order b 
where a.IP_Serial_Number = b.IP_Serial_Number
--and a.Work_Order_Type in ('Repair')
and convert(DATETIME,a.WO_Completed_Timestamp,121) - Convert(DATETIME,b.CSS_UpdatedDate,121) < 30
and convert(DATETIME,a.WO_Completed_Timestamp,121) - Convert(DATETIME,b.CSS_UpdatedDate,121) > 0)

print '***Inside Repeat Call - Record inserted from SE_Work_order into HBN_RepeatCalls***'
--Declare Variables
DECLARE @WorkOrderNumber VARCHAR(100)
             ,@IPSerialNumber VARCHAR(100)
			 ,@WorkOrderType VARCHAR(100)
             ,@WOCompletedTimestamp VARCHAR(100)
			 ,@IsMaterialUsed bit
			 ,@ServiceTeam VARCHAR(200)
			 ,@InstalledAtAccount VARCHAR(200)
DECLARE @Counter INT
SET @Counter = 1
DECLARE @CurrIP VARCHAR(100), @CurrWorkOrderType VARCHAR(100), @CurrServiceTeam VARCHAR(200), @CurrInstalledAtAccount VARCHAR(200), @CurrTimeStamp VARCHAR(100), @REM VARCHAR(200), @CurrMaterialUsed bit

-- Declare a cusrsor
DECLARE RepeatOrders CURSOR READ_ONLY
FOR
      SELECT Work_Order_Number, IP_Serial_Number, Work_Order_Type, WO_Completed_Timestamp, IsMaterialUsed, Service_Team, Installed_At_Account
      FROM HBN_RepeatCalls
	  Order By IP_Serial_Number asc, Work_Order_Number asc

OPEN RepeatOrders

FETCH NEXT FROM RepeatOrders INTO  @WorkOrderNumber,@IPSerialNumber, @WorkOrderType, @WOCompletedTimestamp, @IsMaterialUsed, @ServiceTeam, @InstalledAtAccount
	WHILE @@FETCH_STATUS = 0  BEGIN
	IF (@Counter = 1)
		BEGIN
			SET @CurrIP = @IPSerialNumber
			SET @CurrWorkOrderType = @WorkOrderType
			SET @CurrServiceTeam = @ServiceTeam
			SET @CurrTimeStamp = @WOCompletedTimestamp
			SET @CurrMaterialUsed = @IsMaterialUsed
			SET @CurrInstalledAtAccount = @InstalledAtAccount
		END
	ELSE --Not first call
		BEGIN
			IF (@IPSerialNumber = @CurrIP)
				BEGIN
					IF (@ServiceTeam = @CurrServiceTeam)
						BEGIN
							IF (@InstalledAtAccount = @CurrInstalledAtAccount)
								BEGIN -- IF INSTALLED ACCOUNT IS SAME
									   -- Update work order as repeat order	    
									   IF (@IsMaterialUsed = 0) 
											BEGIN 
												If NOT ((@CurrWorkOrderType like '%Preventive Maintenance%') AND (@CurrWorkOrderType like '%Battery Installation%'))
													BEGIN
														SET @REM = 'This is a repeat Call, This call - Material Not Used, Previous Call ON : ' + @CurrTimeStamp 
														Update HBN_Work_Order
														SET
															Repeat_Yes_No = 'YES',
															Remarks = @REM,
															Claim = 0
														Where
															Work_Order_Number = @WorkOrderNumber
													END
											END
										ELSE
											BEGIN
												SET @REM = 'Repeat Call but material used, First Call ON: ' + @CurrTimeStamp + ' - Material Used' 
												Update HBN_Work_Order
												SET
													Repeat_Yes_No = 'NO',
													Remarks = @REM
												Where
													Work_Order_Number = @WorkOrderNumber
											END
								END 
							ELSE --IF INSTALLED ACCOUNT IS NOT SAME
								BEGIN
									SET @REM = 'Repeat Call at different customer, First Call ON: ' + @CurrTimeStamp + ' But differnt service team :' + @ServiceTeam
									Update HBN_Work_Order
									SET
										Repeat_Yes_No = 'NO',
										Remarks = @REM
									Where
										Work_Order_Number = @WorkOrderNumber
								END
						END
					ELSE -- If service team is not same
						BEGIN
								    SET @REM = 'Repeat Call by different service team, First Call ON: ' + @CurrTimeStamp + ' But differnt service team :' + @ServiceTeam
									Update HBN_Work_Order
									SET
										Repeat_Yes_No = 'NO',
										Remarks = @REM
									Where
										Work_Order_Number = @WorkOrderNumber
						END
				END
			ELSE
				BEGIN
					SET @CurrIP = @IPSerialNumber
					SET @CurrWorkOrderType = @WorkOrderType
					SET @CurrServiceTeam = @ServiceTeam
					SET @CurrTimeStamp = @WOCompletedTimestamp
					SET @CurrMaterialUsed = @IsMaterialUsed
					SET @CurrInstalledAtAccount = @InstalledAtAccount
					SET @Counter = 1
				END
		END -- Not first call ends here
		SET @Counter = @Counter + 1
		FETCH NEXT FROM RepeatOrders INTO  @WorkOrderNumber,@IPSerialNumber, @WorkOrderType, @WOCompletedTimestamp, @IsMaterialUsed, @ServiceTeam, @InstalledAtAccount
	END -- Fetch while ends here
print '***Inside Repeat Call - End***'
End
