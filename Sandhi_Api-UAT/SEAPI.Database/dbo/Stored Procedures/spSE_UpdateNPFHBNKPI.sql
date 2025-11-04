-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for NPFH BNK
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateNPFHBNKPI

CREATE procedure [dbo].[spSE_UpdateNPFHBNKPI]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--Get KPI for NPFH BNK

		DROP TABLE IF EXISTS #tempNPFHBN, #tempNPFHBNRowNumber
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
		INTO #tempNPFHBN
		FROM dbo.NPFHBN SRS
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 9
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.NPFHBN SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempNPFHBNRowNumber
		FROM #tempNPFHBN

		INSERT INTO NPFHBNKPIHistories
		(
			NPFHBNKPIID
			,CssCode
			,Percentage 
			,KPI
			,UpdatedDateTime
			,HistoryCreatedDateTime 
		)
		SELECT
			NPFHBNKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.NPFHBNKPI

		TRUNCATE TABLE NPFHBNKPI

		INSERT INTO dbo.NPFHBNKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TNPF.CSS_Code
			,TNPF.Percentage
			,TNPF.GradeID
			,@TodayDateTime
		FROM #tempNPFHBNRowNumber TNPF
		LEFT JOIN dbo.NPFHBNKPI NPF
			ON TNPF.CSS_Code = NPF.CSSCode
		WHERE NPF.CSSCode IS NULL AND RowNumber = 1

		--UPDATE NPF SET
		--	NPF.CssCode = TNPF.CSS_Code
		--	,NPF.Percentage = TNPF.Percentage
		--	,NPF.KPI = TNPF.GradeID
		--	,UpdatedDateTime = @TodayDateTime
		--FROM dbo.NPFHBNKPI NPF
		--INNER  JOIN #tempNPFHBNRowNumber TNPF
		--	ON NPF.CssCode = TNPF.CSS_Code
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH
END
