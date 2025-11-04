-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for IB Tracking
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateIBTrackingKPI

CREATE procedure [dbo].[spSE_UpdateIBTrackingKPI]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)

		--Get KPI for IB Tracking

		DROP TABLE IF EXISTS #tempIBTracking, #tempIBTrackingRowNumber;
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
		INTO #tempIBTracking
		FROM dbo.IBTracking
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON GKM.ParameterGroup = 13
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		UPDATE dbo.IBTracking SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Percentage
			,GradeID
		INTO #tempIBTrackingRowNumber
		FROM #tempIBTracking

		INSERT INTO IBTrackingKPIHistories
		(
			IBTrackingKPIID 
			,CssCode
			,Percentage 
			,KPI 
			,UpdatedDateTime
			,HistoryCreatedDateTime
		)
		SELECT
			IBTrackingKPIID
			,CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.IBTrackingKPI

		TRUNCATE TABLE dbo.IBTrackingKPI

		INSERT INTO dbo.IBTrackingKPI
		(
			CssCode
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TIB.CSS_Code
			,TIB.Percentage
			,TIB.GradeID
			,@TodayDateTime
		FROM #tempIBTrackingRowNumber TIB
		LEFT JOIN dbo.IBTrackingKPI IB
			ON TIB.CSS_Code = IB.CSSCode
		WHERE IB.CSSCode IS NULL AND RowNumber = 1

		--UPDATE IB SET
		--	IB.CssCode = TIB.CSS_Code
		--	,IB.Percentage = TIB.Percentage
		--	,IB.KPI = TIB.GradeID
		--	,UpdatedDateTime = @TodayDateTime
		--FROM dbo.IBTrackingKPI IB
		--INNER  JOIN #tempIBTrackingRowNumber TIB
		--	ON IB.CssCode = TIB.CSS_Code
		--WHERE RowNumber = 1

	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
