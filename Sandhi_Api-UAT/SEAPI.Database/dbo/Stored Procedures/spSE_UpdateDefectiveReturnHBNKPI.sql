-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Defective Return HBN
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateDefectiveReturnHBNKPI

CREATE procedure [dbo].[spSE_UpdateDefectiveReturnHBNKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--Get KPI for Defective Return HBN

		DROP TABLE IF EXISTS #tempDefectiveReturnHBN, #tempDefectiveReturnHBNRowNumber
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
		INTO #tempDefectiveReturnHBN
		FROM dbo.DefectiveReturnHBN DR
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 7
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.DefectiveReturnHBN SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempDefectiveReturnHBNRowNumber
		FROM #tempDefectiveReturnHBN

		INSERT INTO DefectiveReturnHBNKPIHistories
		(
			DefectiveReturnHBNKPIID 
			,CssCode
			,Percentage 
			,KPI 
			,UpdatedDateTime 
			,HistoryCreatedDateTime 
		)
		SELECT
			DefectiveReturnHBNKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.DefectiveReturnHBNKPI

		TRUNCATE TABLE dbo.DefectiveReturnHBNKPI

		INSERT INTO dbo.DefectiveReturnHBNKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TDR.CSS_Code
			,TDR.Percentage
			,TDR.GradeID
			,@TodayDateTime
		FROM #tempDefectiveReturnHBNRowNumber TDR
		LEFT JOIN dbo.DefectiveReturnHBNKPI DR
			ON TDR.CSS_Code = DR.CSSCode
		WHERE DR.CSSCode IS NULL AND RowNumber = 1

		--UPDATE DR SET
		--	DR.CssCode = TDR.CSS_Code
		--	,DR.Percentage = TDR.Percentage
		--	,DR.KPI = TDR.GradeID
		--	,DR.UpdatedDateTime = @TodayDateTime
		--FROM dbo.DefectiveReturnHBNKPI DR
		--INNER  JOIN #tempDefectiveReturnHBNRowNumber TDR
		--	ON DR.CssCode = TDR.CSS_Code
		--WHERE RowNumber = 1

	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
