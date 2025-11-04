-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Attrition 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateAttritionKPI

CREATE procedure [dbo].[spSE_UpdateAttritionKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--Get KPI for Attrition

		DROP TABLE IF EXISTS #tempAttrition, #tempAttritionRowNumber;
		DECLARE @TodayDateTime DATETIME =  GETDATE();

		SELECT
			CSS_Code
			,CAST(CAST(Percentage AS DECIMAL(18,5)) AS DECIMAL(18,5)) Percentage
			,CASE 
				WHEN Percentage IS NULL THEN NULL
				--WHEN CAST(Percentage AS DECIMAL(18,5)) < 0 THEN NULL
				WHEN CAST(CAST(Percentage AS DECIMAL(18,2)) AS DECIMAL(18,5)) BETWEEN CAST(GKM.[From] AS DECIMAL(18,5)) AND CAST(GKM.[To] AS DECIMAL(18,5))
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempAttrition
		FROM dbo.Attrition
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 10
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.Attrition SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempAttritionRowNumber
		FROM #tempAttrition

		INSERT INTO AttritionKPIHistories
		(
			AttritionKPIID 
			,CssCode 
			,Percentage 
			,KPI 
			,UpdatedDateTime 
			,HistoryCreatedDateTime
		)
		SELECT
			AttritionKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.AttritionKPI

		TRUNCATE TABLE dbo.AttritionKPI

		INSERT INTO dbo.AttritionKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TA.CSS_Code
			,TA.Percentage
			,TA.GradeID
			,@TodayDateTime
		FROM #tempAttritionRowNumber TA
		LEFT JOIN dbo.AttritionKPI A
			ON TA.CSS_Code = A.CSSCode
		WHERE A.CSSCode IS NULL AND RowNumber = 1

		--UPDATE A SET
		--	A.CssCode = TA.CSS_Code
		--	,A.Percentage = TA.Percentage
		--	,A.KPI = TA.GradeID
		--	,UpdatedDateTime = @TodayDateTime
		--FROM dbo.AttritionKPI A
		--INNER  JOIN #tempAttritionRowNumber TA
		--	ON A.CssCode = TA.CSS_Code
		--WHERE RowNumber = 1

	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
