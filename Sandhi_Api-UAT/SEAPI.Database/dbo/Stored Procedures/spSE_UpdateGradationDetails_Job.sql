-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Update gradation details in respective tables
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateGradationDetails_Job

CREATE procedure [dbo].[spSE_UpdateGradationDetails_Job]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		, @StartDateTime DATETIME, @EndDateTime DATETIME

		--Alter script 14 tables
		SET @StartDateTime = GETDATE();
		EXEC spSE_AlterGradationScript
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_AlterGradationScript', @StartDateTime, @EndDateTime, NULL

		--Update percentage all table
		SET @StartDateTime = GETDATE();  
		EXEC spSE_UpdatePercentage
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdatePercentage', @StartDateTime, @EndDateTime, NULL
	
		--1 Parameter Get KPI for Safety Rating Score
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateSafetyRatingScoreKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateSafetyRatingScoreKPI', @StartDateTime, @EndDateTime, NULL

		--2 Parameter Get KPI for Customer Satisfaction Score NSS
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateCustomerSatisfactionScoreNSSKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateCustomerSatisfactionScoreNSSKPI', @StartDateTime, @EndDateTime, NULL

		--3 Parameter Get KPI for Customer Survey Response Rate
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateCustomerSurveyResponseRateKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateCustomerSurveyResponseRateKPI', @StartDateTime, @EndDateTime, NULL

		-- 4 Parameter Get KPI for work order response
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateWorkOrderResponseKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateWorkOrderResponseKPI', @StartDateTime, @EndDateTime, NULL

		--5 Parameter Get KPI for Work_order_MTTRv
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateWorkOrderMTTRvKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateWorkOrderMTTRvKPI', @StartDateTime, @EndDateTime, NULL

		--6 Parameter Get KPI for Preventive Maintainance Compliance Cooling
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdatePreventiveMaintainanceComplianceCoolingKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdatePreventiveMaintainanceComplianceCoolingKPI', @StartDateTime, @EndDateTime, NULL

		--7 Parameter Get KPI for Defective Return HBN
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateDefectiveReturnHBNKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateDefectiveReturnHBNKPI', @StartDateTime, @EndDateTime, NULL

		--8 Parameter Get KPI for Defective Return Rate PP And I
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateDefectiveReturnRatePPAndIKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateDefectiveReturnRatePPAndIKPI', @StartDateTime, @EndDateTime, NULL

		--9 Parameter Get KPI for NPF HBN 
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateNPFHBNKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateNPFHBNKPI', @StartDateTime, @EndDateTime, NULL

		--10 Parameter Get KPI for Attrition 
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateAttritionKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateAttritionKPI', @StartDateTime, @EndDateTime, NULL

		--11 Parameter Get KPI for FSR Competency 
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateFSRCompetencyKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateFSRCompetencyKPI', @StartDateTime, @EndDateTime, NULL

		--12 Parameter Get KPI for Lead Generation 
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateLeadGenerationKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateLeadGenerationKPI', @StartDateTime, @EndDateTime, NULL

		--13 Parameter Get KPI for IB Tracking 
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateIBTrackingKPI
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateIBTrackingKPI', @StartDateTime, @EndDateTime, NULL

		--14 Parameter Get KPI for IB Tracking 
		--EXEC spSE_UpdateThresHoldInputFile

		--Final Grade Calculation
		SET @StartDateTime = GETDATE();
		ExEC spSE_InsertCssCodeGrade
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_InsertCssCodeGrade', @StartDateTime, @EndDateTime, NULL

		--Calculate invoice amount
		SET @StartDateTime = GETDATE();
		EXEC spSE_UpdateCSSInvoiceAmount
		SET @EndDateTime = GETDATE();
		EXEC spSE_PostSPLoadLogs 'spSE_UpdateCSSInvoiceAmount', @StartDateTime, @EndDateTime, NULL

	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
