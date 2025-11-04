-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Add updateddattime in 14 tables 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdatePercentage

CREATE procedure [dbo].[spSE_UpdatePercentage]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)

		--1. Safety Rating Score
		UPDATE SafetyRatingScore SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END

		--2. Customer Satisfaction Score (NSS)
		UPDATE CustomerSatisfactionScoreNSS SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END
	
		--3. Customer Survey response rate
		UPDATE CustomerSurveyResponseRate SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END
	
		--6. Preventive Maintainance compliance % - Cooling
		UPDATE PreventiveMaintainanceComplianceCooling 
			SET Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END
	
		--7. Defective Return - HBN
		UPDATE DefectiveReturnHBN SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END

		--8. Defective return rate % - PP&I
		UPDATE DefectiveReturnRatePPAndI SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END

		--9. NPF - HBN
		UPDATE NPFHBN SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END

		--10. Attrition
		UPDATE Attrition SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END
	
		--11. FSR Competency
		UPDATE FSRCompetency SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END

		--12. Lead Generation
		UPDATE LeadGeneration SET
			 Percentage = CASE WHEN Percentage IS NULL THEN NULL
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
								THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
								WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
								THEN NULL 
							END
	
		--13. IB Tracking
		UPDATE IBTracking SET
			Percentage = CASE WHEN Percentage IS NULL THEN NULL
							WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 1
							THEN convert(decimal(18,2),cast(Percentage as Float)) * 100.0
							WHEN ISNUMERIC(convert(decimal(18,2),cast(Percentage as Float))) = 0
							THEN NULL 
						END
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH
END
