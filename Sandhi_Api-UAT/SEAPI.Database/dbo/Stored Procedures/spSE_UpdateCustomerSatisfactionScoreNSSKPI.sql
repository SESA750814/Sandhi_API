-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for Customer Satisfaction Score NSS
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateCustomerSatisfactionScoreNSSKPI

CREATE procedure [dbo].[spSE_UpdateCustomerSatisfactionScoreNSSKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		-- 2. Get KPI for Customer Satisfaction Score (NSS)

		DROP TABLE IF EXISTS #tempCustomerSatisfactionScoreNSS, #tempCustomerSatisfactionScoreNSSGrade, #tempCustomerSatisfactionScoreNSSRowNumber
		DECLARE @TodayDateTime DATETIME = GETDATE();

		SELECT
			CSS_Code
			,CASE 
				WHEN CSFS.Services_Business_Unit = 'Industrial Automation' THEN 'Industry'
				WHEN CSFS.Services_Business_Unit = 'Power Products' THEN 'Power Product'
				WHEN CSFS.Services_Business_Unit = 'Secure Power - cooling ' THEN 'Cooling'
				WHEN CSFS.Services_Business_Unit = 'Secure power - HBN' THEN 'HBN'
				ELSE CSFS.Services_Business_Unit
			END BusinessUnit
			,CAST(CAST(Percentage AS DECIMAL(18,5)) AS DECIMAL(18,5)) Percentage
		INTO #tempCustomerSatisfactionScoreNSS
		FROM dbo.CustomerSatisfactionScoreNSS CSFS
		WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime
 
		SELECT
			CSS_Code
			,CSFS.BusinessUnit
			,Percentage
			,CASE 
				WHEN Percentage IS NULL THEN NULL
				--WHEN CAST(Percentage AS DECIMAL(18,5)) < 0 THEN NULL
				WHEN CAST(CAST(Percentage AS DECIMAL(18,5)) AS DECIMAL(18,5)) BETWEEN CAST(GKM.[From] AS DECIMAL(18,5)) AND CAST(GKM.[To] AS DECIMAL(18,5))
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempCustomerSatisfactionScoreNSSGrade
		FROM #tempCustomerSatisfactionScoreNSS CSFS
		INNER JOIN dbo.Gradation_KPI_Metrics GKM
			ON CSFS.BusinessUnit = GKM.BusinessUnit
			AND GKM.ParameterGroup = 2
	
		UPDATE dbo.CustomerSatisfactionScoreNSS SET UpdatePercentageDateTime = @TodayDateTime WHERE UpdatePercentageDateTime IS NULL OR UpdatePercentageDateTime > @TodayDateTime

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, BusinessUnit, Percentage ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,BusinessUnit
			,Percentage
			,GradeID
		INTO #tempCustomerSatisfactionScoreNSSRowNumber
		FROM #tempCustomerSatisfactionScoreNSSGrade

		INSERT INTO dbo.CustomerSatisfactionScoreNSSKPIHistories
		(
			CustomerSatisfactionScoreNSSKPIID
			,CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
			,HistoryCreatedDateTime
		)
		SELECT 
			CustomerSatisfactionScoreNSSKPIID
			,CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.CustomerSatisfactionScoreNSSKPI
	
		TRUNCATE TABLE dbo.CustomerSatisfactionScoreNSSKPI

		INSERT INTO dbo.CustomerSatisfactionScoreNSSKPI
		(
			CssCode
			,BusinessUnit
			,Percentage
			,KPI
			,UpdatedDateTime
		)
		SELECT
			TCSFS.CSS_Code
			,TCSFS.BusinessUnit
			,TCSFS.Percentage
			,TCSFS.GradeID
			,@TodayDateTime
		FROM #tempCustomerSatisfactionScoreNSSRowNumber TCSFS
		LEFT JOIN dbo.CustomerSatisfactionScoreNSSKPI CSFS
			ON TCSFS.CSS_Code = CSFS.CSSCode
			AND TCSFS.BusinessUnit = CSFS.BusinessUnit
		WHERE CSFS.CSSCode IS NULL AND RowNumber = 1

		--UPDATE CSFS SET
		--	CSFS.CssCode = TCSFS.CSS_Code
		--	,CSFS.Percentage = TCSFS.Percentage
		--	,CSFS.KPI = TCSFS.GradeID
		--	,UpdatedDateTime = @TodayDateTime  
		--FROM dbo.CustomerSatisfactionScoreNSSKPI CSFS
		--INNER  JOIN #tempCustomerSatisfactionScoreNSSRowNumber TCSFS
		--	ON CSFS.CssCode = TCSFS.CSS_Code
		--	AND CSFS.BusinessUnit = TCSFS.BusinessUnit
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH
END
