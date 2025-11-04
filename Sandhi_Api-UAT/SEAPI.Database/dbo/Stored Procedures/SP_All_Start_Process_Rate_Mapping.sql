-- =============================================
-- Author:		<Muthukrishnan Marimuthu,,Name>
-- Create date: <Create Date,,>
-- Description:	<Parse and loading corresponding HBN,PSI,Cooling, Cooling Expense Table and Map Rate Calculation 
-- and Load in to SE Work Order >
-- =============================================
--exec SP_All_Start_Process_Rate_Mapping
CREATE procedure [dbo].[SP_All_Start_Process_Rate_Mapping]
	
AS
BEGIN

begin transaction
begin try
 
-- Clear transaction 

EXEC Clear_Transaction
print '***Clear_Transaction Successfull***'
EXEC xp_logevent 60000, '***Clear_Transaction Successfull***', informational;

-- Dump Column name Change

--EXEC SP_Dump_Column_Name_Change

--print '***Dump Column Name Change Successfull ***'

-- Load data from Raw dumb to each HBN, PSI and Cooling Dumb


EXEC SE_SP_SEDumpFilter_To_HBNandPSI

print '***SE_SP_SEDumpFilter_To_HBNandPSI Successfull***'
EXEC xp_logevent 60000, '***SE_SP_SEDumpFilter_To_HBNandPSI Successfull***', informational;

print '***start SP_Existing_Month_Validation_Aganist_new_Dump***'
EXEC xp_logevent 60000, '***start SP_Existing_Month_Validation_Aganist_new_Dump***', informational;

EXEC SP_Existing_Month_Validation_Aganist_new_Dump

print '***SP_Existing_Month_Validation_Aganist_new_Dump Successfull***'
EXEC xp_logevent 60000, '***SP_Existing_Month_Validation_Aganist_new_Dump Successfull***', informational;

-- Insert SE_CSS_Master
EXEC SP_Insert_CSS_Master
print '***SP_Insert_CSS_Master Successfull***'
EXEC xp_logevent 60000, '***SP_Insert_CSS_Master Successfull***', informational;

-- HBN

print '***HBN PROCESSING STARTED Successfull***'
EXEC xp_logevent 60000, '***HBN PROCESSING STARTED Successfull***', informational;

EXEC SP_HBN_Insert_Transaction
print '***SP_HBN_Insert_Transaction Successfull***'
EXEC xp_logevent 60000, '***SP_HBN_Insert_Transaction Successfull***', informational;

EXEC SP_HBN_Rate_Mapping
print '***SP_HBN_Rate_Mapping Successfull***'
EXEC xp_logevent 60000, '***SP_HBN_Rate_Mapping Successfull***', informational;

--EXEC SP_HBN_Repeat_Call_Mapping_26042022
EXEC SP_HBN_Repeat_Call_Rate_Mapping_25Dec2024
print '***SP_HBN_Repeat_Call_Rate_Mapping Successfull***'
EXEC xp_logevent 60000, '***SP_HBN_Repeat_Call_Rate_Mapping_25Dec2024 Successfull***', informational;

--EXEC SP_HBN_Repeat_Call_Rate_Mapping
--EXEC SP_HBN_Repeat_Call_Fix
print '***HBN PROCESSING  Successfull***'
EXEC xp_logevent 60000, '***HBN PROCESSING  Successfull***', informational;


-- PSI

print '***PPI PROCESSING STARTED***'
EXEC xp_logevent 60000, '***PPI PROCESSING STARTED***', informational;
EXEC SP_PSI_Insert_Transaction
print '***PPI Insert_Transaction Successfull***'
EXEC xp_logevent 60000, '***PPI Insert_Transaction Successfull***', informational;
EXEC SP_PSI_Rate_Mapping
print '***PPI Rate_Mapping Successfull***'
EXEC xp_logevent 60000, '***PPI Rate_Mapping Successfull***', informational;
--EXEC SP_PSI_Repeat_Call_Rate_Mapping
--print '***SP_PSI_Repeat_Call_Rate_Mapping Successfull***'

print '***PPI PROCESSING Successfull***'
EXEC xp_logevent 60000, '***PPI PROCESSING Successfull***', informational;
print '***Cooling PROCESSING STARTED***'
EXEC xp_logevent 60000, '***Cooling PROCESSING STARTED***', informational;
--Cooling
EXEC SP_Cooling_Insert_Expense
print '***Cooling_Insert_Expense Successfull***'
EXEC xp_logevent 60000, '***Cooling_Insert_Expense Successfull***', informational;
EXEC SP_Cooling_Insert_Transaction
print '***Cooling_Insert_Transaction Successfull***'
EXEC xp_logevent 60000, '***Cooling_Insert_Transaction Successfull***', informational;
EXEC SP_Cooling_Rate_Expense_Mapping_23Dec2024
print '***Cooling Processed Successfull***'
EXEC xp_logevent 60000, '***Cooling Processed Successfull***', informational;
-- Export data to SE_Work_Order
exec usp_ImportMainData
print '***usp_ImportMainData Successfull***'
EXEC xp_logevent 60000, '***usp_ImportMainData Successfull***', informational;
 commit transaction
 raiserror('******All Done Sucessfully*******', 10, 0)
 EXEC xp_logevent 60000, '***All Done Successfully***', informational;
end try
begin catch
 DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
  
    SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  rollback transaction
  EXEC xp_logevent 60000, @ErrorMessage, informational;
  raiserror('Failed and Roll Back', 11, 0)
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               ); 
  EXEC xp_logevent 60000, @ErrorMessage, informational;
end catch

END
