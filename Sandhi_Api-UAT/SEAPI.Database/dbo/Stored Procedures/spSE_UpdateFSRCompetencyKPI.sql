-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for FSR Competency 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateFSRCompetencyKPI

CREATE procedure [dbo].[spSE_UpdateFSRCompetencyKPI]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--Get KPI for FSR Competency

		DROP TABLE IF EXISTS #tempFSRCompetency, #tempFSRCompetencyRowNumber;
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
		INTO #tempFSRCompetency
		FROM dbo.FSRCompetency
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 11
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.FSRCompetency SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempFSRCompetencyRowNumber
		FROM #tempFSRCompetency

		INSERT INTO FSRCompetencyKPIHistories
		(
			FSRCompetencyKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,HistoryCreatedDateTime
		)
		SELECT
			FSRCompetencyKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.FSRCompetencyKPI

		TRUNCATE TABLE dbo.FSRCompetencyKPI

		INSERT INTO dbo.FSRCompetencyKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TFSR.CSS_Code
			,TFSR.Percentage
			,TFSR.GradeID
			,@TodayDateTime
		FROM #tempFSRCompetencyRowNumber TFSR
		LEFT JOIN dbo.FSRCompetencyKPI FSR
			ON TFSR.CSS_Code = FSR.CSSCode
		WHERE FSR.CSSCode IS NULL AND RowNumber = 1

		--UPDATE FSR SET
		--	FSR.CssCode = TFSR.CSS_Code
		--	,FSR.Percentage = TFSR.Percentage
		--	,FSR.KPI = TFSR.GradeID
		--	,UpdatedDateTime = @TodayDateTime
		--FROM dbo.FSRCompetencyKPI FSR
		--INNER  JOIN #tempFSRCompetencyRowNumber TFSR
		--	ON FSR.CssCode = TFSR.CSS_Code
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH
END
