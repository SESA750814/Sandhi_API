-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Lead Generation
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateLeadGenerationKPI

CREATE procedure [dbo].[spSE_UpdateLeadGenerationKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)

		--Get KPI for Lead Generation

		DROP TABLE IF EXISTS #tempLeadGeneration, #tempLeadGenerationRowNumber;
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
		INTO #tempLeadGeneration
		FROM dbo.LeadGeneration
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 12
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.LeadGeneration SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempLeadGenerationRowNumber
		FROM #tempLeadGeneration

		INSERT INTO LeadGenerationKPIHistories
		(
			LeadGenerationKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime 
			,HistoryCreatedDateTime 
		)
		SELECT
			LeadGenerationKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.LeadGenerationKPI

		TRUNCATE TABLE dbo.LeadGenerationKPI

		INSERT INTO dbo.LeadGenerationKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TLG.CSS_Code
			,TLG.Percentage
			,TLG.GradeID
			,@TodayDateTime
		FROM #tempLeadGenerationRowNumber TLG
		LEFT JOIN dbo.LeadGenerationKPI LG
			ON TLG.CSS_Code = LG.CSSCode
		WHERE LG.CSSCode IS NULL AND RowNumber = 1

		--UPDATE LG SET
		--	LG.CssCode = TLG.CSS_Code
		--	,LG.Percentage = TLG.Percentage
		--	,LG.KPI = TLG.GradeID
		--	,UpdatedDateTime =  @TodayDateTime
		--FROM dbo.LeadGenerationKPI LG
		--INNER  JOIN #tempLeadGenerationRowNumber TLG
		--	ON LG.CssCode = TLG.CSS_Code
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
