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
-- EXEC spSE_UpdateSafetyRatingScoreKPI

CREATE procedure [dbo].[spSE_UpdateSafetyRatingScoreKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--Get KPI for Safety Rating Score

		DROP TABLE IF EXISTS #tempSafetyRatingScore, #tempSafetyRatingScoreRowNumber
		DECLARE @TodayDateTime DATETIME =  GETDATE();

		SELECT
			CS.Id AS CSS_ID
			,SRS.CSS_Code
			,Percentage
			--,CAST(CAST(CONVERT(VARCHAR(MAX), DECRYPTBYPASSPHRASE(dbo.fn_GetEncryptValue(),SRS.Encrypt_Percentage)) AS DECIMAL(18,5)) AS DECIMAL(18,5)) Percentage
			,CASE 
				WHEN Percentage IS NULL THEN NULL
				--WHEN CAST(Percentage AS DECIMAL(18,5)) < 0 THEN NULL
				WHEN CAST(Percentage AS DECIMAL(18,5)) BETWEEN CAST(GKM.[From] AS DECIMAL(18,5)) AND CAST(GKM.[To] AS DECIMAL(18,5))
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempSafetyRatingScore
		FROM dbo.SafetyRatingScore SRS
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 1
		INNER JOIN SE_CSS_MASTER CS
			ON SRS.CSS_Code = CS.CSS_Code
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.SafetyRatingScore SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_ID, CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber
			,CSS_ID
			,CSS_Code
			,Percentage
			,GradeID
		INTO #tempSafetyRatingScoreRowNumber
		FROM #tempSafetyRatingScore

		INSERT INTO dbo.SafetyRatingScoreKPIHistories
		(
			SafetyRatingScoreKPID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,HistoryCreatedDateTime
			--,CSS_ID
			--,Encrypt_Percentage
			--,Encrypt_KPI
		)
		SELECT
			SafetyRatingScoreKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
			--,CSS_ID
			--,Encrypt_Percentage
			--,Encrypt_KPI
		FROM dbo.SafetyRatingScoreKPI

		TRUNCATE TABLE dbo.SafetyRatingScoreKPI

		INSERT INTO dbo.SafetyRatingScoreKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			--,CSS_ID
			--,Encrypt_Percentage
			--,Encrypt_KPI
		)
		SELECT
			SRSR.CSS_Code
			,SRSR.Percentage
			,SRSR.GradeID
			,@TodayDateTime
			--,SRSR.CSS_ID
			--,ENCRYPTBYPASSPHRASE(dbo.fn_GetEncryptValue(),CAST(SRSR.Percentage AS VARCHAR(MAX)))
			--,ENCRYPTBYPASSPHRASE(dbo.fn_GetEncryptValue(),CAST(SRSR.GradeID AS VARCHAR(MAX)))
		FROM #tempSafetyRatingScoreRowNumber SRSR
		LEFT JOIN dbo.SafetyRatingScoreKPI SRSK
			ON SRSR.CSS_Code = SRSK.CSSCode
		WHERE SRSK.CSSCode IS NULL AND RowNumber = 1
	
		--UPDATE SRSK SET
		--	SRSK.CssCode = SRSR.CSS_Code
		--	,SRSK.Percentage = SRSR.Percentage
		--	,SRSK.KPI = SRSR.GradeID
		--	,SRSK.UpdatedDateTime = @TodayDateTime
		--FROM dbo.SafetyRatingScoreKPI SRSK
		--INNER  JOIN #tempSafetyRatingScoreRowNumber SRSR
		--	ON SRSK.CssCode = SRSR.CSS_Code
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
