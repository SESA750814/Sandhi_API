-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Defective Return Rate PP And I
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateDefectiveReturnRatePPAndIKPI

CREATE procedure [dbo].[spSE_UpdateDefectiveReturnRatePPAndIKPI]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		-- 8. Get KPI for Defective Return Rate PP And I

		DROP TABLE IF EXISTS #tempDefectiveReturnRatePPAndI, #tempDefectiveReturnRatePPAndIGrade, #tempDefectiveReturnRatePPAndIRowNumber
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
		INTO #tempDefectiveReturnRatePPAndI
		FROM dbo.DefectiveReturnRatePPAndI
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime
 
		SELECT
			CSS_Code
			,DRR.BusinessUnit
			,Percentage
			,CASE 
				WHEN Percentage IS NULL THEN NULL
				--WHEN CAST(Percentage AS DECIMAL(18,5)) < 0 THEN NULL
				WHEN CAST(CAST(Percentage AS DECIMAL(18,5)) AS DECIMAL(18,5)) BETWEEN CAST(GKM.[From] AS DECIMAL(18,5)) AND CAST(GKM.[To] AS DECIMAL(18,5))
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempDefectiveReturnRatePPAndIGrade
		FROM #tempDefectiveReturnRatePPAndI DRR
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON DRR.BusinessUnit = GKM.BusinessUnit
			AND GKM.ParameterGroup = 8
	
		UPDATE dbo.DefectiveReturnRatePPAndI SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, BusinessUnit, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,BusinessUnit
			,Percentage
			,GradeID
		INTO #tempDefectiveReturnRatePPAndIRowNumber
		FROM #tempDefectiveReturnRatePPAndIGrade
	
		INSERT INTO DefectiveReturnRatePPAndIKPIHistories
		(
			DefectiveReturnRatePPAndIKPIID
			,CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
			,HistoryCreatedDateTime 
		)
		SELECT
			DefectiveReturnRatePPAndIKPIID
			,CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.DefectiveReturnRatePPAndIKPI

		TRUNCATE TABLE dbo.DefectiveReturnRatePPAndIKPI

		INSERT INTO dbo.DefectiveReturnRatePPAndIKPI
		(
			CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TDRR.CSS_Code
			,TDRR.BusinessUnit
			,TDRR.Percentage
			,TDRR.GradeID
			,@TodayDateTime
		FROM #tempDefectiveReturnRatePPAndIRowNumber TDRR
		LEFT JOIN dbo.DefectiveReturnRatePPAndIKPI DRRK
			ON TDRR.CSS_Code = DRRK.CSSCode
			AND TDRR.BusinessUnit = DRRK.BusinessUnit
		WHERE DRRK.CSSCode IS NULL AND RowNumber = 1

		--UPDATE DRR SET
		--	DRR.CssCode = TDRR.CSS_Code
		--	,DRR.Percentage = TDRR.Percentage
		--	,DRR.KPI = TDRR.GradeID
		--	,UpdatedDateTime = @TodayDateTime
		--FROM dbo.DefectiveReturnRatePPAndIKPI DRR
		--INNER  JOIN #tempDefectiveReturnRatePPAndIRowNumber TDRR
		--	ON DRR.CssCode = TDRR.CSS_Code
		--	AND DRR.BusinessUnit = TDRR.BusinessUnit
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
