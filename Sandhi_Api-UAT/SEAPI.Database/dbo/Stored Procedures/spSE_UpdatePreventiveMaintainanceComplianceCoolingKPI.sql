-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Safety Rating Score 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdatePreventiveMaintainanceComplianceCoolingKPI

CREATE procedure [dbo].[spSE_UpdatePreventiveMaintainanceComplianceCoolingKPI]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--Get KPI for Safety Rating Score

		DROP TABLE IF EXISTS #tempSafetyRatingScore, #tempSafetyRatingScoreRowNumber
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
		INTO #tempPreventiveMaintainanceComplianceCooling
		FROM dbo.PreventiveMaintainanceComplianceCooling PMCC
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 6
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.PreventiveMaintainanceComplianceCooling SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempPreventiveMaintainanceComplianceCoolingRowNumber
		FROM #tempPreventiveMaintainanceComplianceCooling

		INSERT INTO PreventiveMaintainanceComplianceCoolingKPIHistories
		(
			PreventiveMaintainanceComplianceCoolingKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,HistoryCreatedDateTime
		)
		SELECT
			PreventiveMaintainanceComplianceCoolingKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.PreventiveMaintainanceComplianceCoolingKPI

		TRUNCATE TABLE dbo.PreventiveMaintainanceComplianceCoolingKPI

		INSERT INTO dbo.PreventiveMaintainanceComplianceCoolingKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TPMCC.CSS_Code
			,TPMCC.Percentage
			,TPMCC.GradeID
			,@TodayDateTime
		FROM #tempPreventiveMaintainanceComplianceCoolingRowNumber TPMCC
		LEFT JOIN dbo.PreventiveMaintainanceComplianceCoolingKPI PMCC
			ON TPMCC.CSS_Code = PMCC.CSSCode
		WHERE PMCC.CSSCode IS NULL AND RowNumber = 1

		--UPDATE PMCC SET
		--	PMCC.CssCode = TPMCC.CSS_Code
		--	,PMCC.Percentage = TPMCC.Percentage
		--	,PMCC.KPI = TPMCC.GradeID
		--	,PMCC.UpdatedDateTime = @TodayDateTime
		--FROM dbo.PreventiveMaintainanceComplianceCoolingKPI PMCC
		--INNER  JOIN #tempPreventiveMaintainanceComplianceCoolingRowNumber TPMCC
		--	ON PMCC.CssCode = TPMCC.CSS_Code
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
