-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Customer Survey Response Rate
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateCustomerSurveyResponseRateKPI

CREATE procedure [dbo].[spSE_UpdateCustomerSurveyResponseRateKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		-- 3. Get KPI for Customer Survey Response Rate

		DROP TABLE IF EXISTS #tempCustomerSurveyResponseRate, #tempCustomerSurveyResponseRateGrade, #tempCustomerSurveyResponseRateRowNumber
		DECLARE @TodayDateTime DATETIME =  GETDATE();

		SELECT
			CSS_Code
			,CASE 
				WHEN Services_Business_Unit = 'Industrial Automation' THEN 'Industry'
				WHEN Services_Business_Unit = 'Power Products' THEN 'Power Product'
				WHEN Services_Business_Unit = 'Secure Power - cooling ' THEN 'Cooling'
				WHEN Services_Business_Unit = 'Secure power - HBN' THEN 'HBN'
				ELSE Services_Business_Unit
			END BusinessUnit
			,CAST(CAST(Percentage AS DECIMAL(18,5)) AS DECIMAL(18,5)) Percentage
		INTO #tempCustomerSurveyResponseRate
		FROM dbo.CustomerSurveyResponseRate 
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > GETDATE()

		SELECT
			CSRR.CSS_Code
			,CSRR.BusinessUnit
			,CSRR.Percentage
			,CASE 
				WHEN CSRR.Percentage IS NULL THEN NULL
				--WHEN CAST(CSRR.Percentage AS DECIMAL(18,5)) < 0 THEN NULL
				WHEN CAST(CAST(CSRR.Percentage AS DECIMAL(18,5)) AS DECIMAL(18,5)) BETWEEN CAST(GKM.[From] AS DECIMAL(18,5)) AND CAST(GKM.[To] AS DECIMAL(18,5))
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempCustomerSurveyResponseRateGrade
		FROM #tempCustomerSurveyResponseRate CSRR
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON CSRR.BusinessUnit = GKM.BusinessUnit
			AND GKM.ParameterGroup = 3
	
		UPDATE dbo.CustomerSurveyResponseRate SET UpdatePercentageDateTime = GETDATE() WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > GETDATE()

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, BusinessUnit, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,BusinessUnit
			,Percentage
			,GradeID
		INTO #tempCustomerSurveyResponseRateRowNumber
		FROM #tempCustomerSurveyResponseRateGrade
	
		INSERT INTO dbo.CustomerSurveyResponseRateKPIHistories
		(
			CustomerSurveyResponseRateKPIID
			,CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime 
			,HistoryCreatedDateTime
		)
		SELECT
			CustomerSurveyResponseRateKPIID
			,CssCode
			,BusinessUnit 
			,Percentage 
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.CustomerSurveyResponseRateKPI

		TRUNCATE TABLE dbo.CustomerSurveyResponseRateKPI

		INSERT INTO dbo.CustomerSurveyResponseRateKPI
		(
			CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			CSRR.CSS_Code
			,CSRR.BusinessUnit
			,CSRR.Percentage
			,CSRR.GradeID
			,@TodayDateTime
		FROM #tempCustomerSurveyResponseRateRowNumber CSRR
		LEFT JOIN dbo.CustomerSurveyResponseRateKPI CSRRK
			ON CSRR.CSS_Code = CSRRK.CSSCode
			AND CSRR.BusinessUnit = CSRRK.BusinessUnit
		WHERE CSRRK.CSSCode IS NULL AND RowNumber = 1

		--UPDATE CSRRK SET
		--	CSRRK.CssCode = CSRR.CSS_Code
		--	,CSRRK.Percentage = CSRR.Percentage
		--	,CSRRK.KPI = CSRR.GradeID
		--  ,UpdatedDateTime = @TodayDateTime
		--FROM dbo.CustomerSurveyResponseRateKPI CSRRK
		--INNER  JOIN #tempCustomerSurveyResponseRateRowNumber CSRR
		--	ON CSRRK.CssCode = CSRR.CSS_Code
		--	AND CSRRK.BusinessUnit = CSRR.BusinessUnit
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
