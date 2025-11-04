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
-- EXEC spSE_UpdateThresHoldInputFile

CREATE procedure [dbo].[spSE_UpdateThresHoldInputFile]
	
AS
BEGIN
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
	
		DROP TABLE IF EXISTS #tempThresHoldInputFile, #tempClassAAverage, #tempClassBAverage, #tempClassCAverage

		SELECT 
			THIF.CSSCode,
			THIF.Category_r,
			CSS.CSS_City_Class,
			COUNT(1) AS COUNTS
		INTO #tempThresHoldInputFile
		FROM dbo.ThresHoldInputFile THIF
		INNER JOIN dbo.SE_CSS_MASTER CSS
			ON THIF.CSSCode = CSS.CSS_Code
		GROUP BY
			THIF.CSSCode,
			THIF.Category_r,
			CSS.CSS_City_Class

		SELECT 
			CSS_City_Class,
			AVG(COUNTS) AS AVG
		INTO #tempClassAAverage
		FROM #tempThresHoldInputFile 
		WHERE CSS_City_Class = 'Class A'
		GROUP BY
			CSS_City_Class

		SELECT 
			CSS_City_Class,
			AVG(COUNTS) AS AVG
		INTO #tempClassBAverage
		FROM #tempThresHoldInputFile 
		WHERE CSS_City_Class = 'Class B'
		GROUP BY
			CSS_City_Class

		SELECT 
			CSS_City_Class,
			AVG(COUNTS) AS AVG
		INTO #tempClassCAverage
		FROM #tempThresHoldInputFile 
		WHERE CSS_City_Class = 'Class C'
		GROUP BY
			CSS_City_Class

		INSERT INTO ThresHold
		(
			CssCode
			,CityClass
			,BusinessUnit
			,NoOfRecords 
			,GradationEligibility
		)
		SELECT 
			THIF.CSSCode	
			,THIF.Category_r	
			,THIF.CSS_City_Class	
			,THIF.COUNTS
			,CASE	
				WHEN  CA.AVG < THIF.COUNTS THEN 'Yes'
				ELSE 'No'
			END
		FROM #tempThresHoldInputFile THIF
		INNER JOIN #tempClassAAverage CA
			ON THIF.CSS_City_Class = CA.CSS_City_Class
		WHERE THIF.CSS_City_Class = 'Class A'

		INSERT INTO ThresHold
		(
			CssCode
			,CityClass
			,BusinessUnit
			,NoOfRecords 
			,GradationEligibility
		)
		SELECT 
			THIF.CSSCode	
			,THIF.Category_r	
			,THIF.CSS_City_Class	
			,THIF.COUNTS
			,CASE	
				WHEN  CA.AVG < THIF.COUNTS THEN 'Yes'
				ELSE 'No'
			END
		FROM #tempThresHoldInputFile THIF
		INNER JOIN #tempClassBAverage CA
			ON THIF.CSS_City_Class = CA.CSS_City_Class
		WHERE THIF.CSS_City_Class = 'Class B'
	
		INSERT INTO ThresHold
		(
			CssCode
			,CityClass
			,BusinessUnit
			,NoOfRecords 
			,GradationEligibility
		)
		SELECT 
			THIF.CSSCode	
			,THIF.Category_r	
			,THIF.CSS_City_Class	
			,THIF.COUNTS
			,CASE	
				WHEN  CA.AVG < THIF.COUNTS THEN 'Yes'
				ELSE 'No'
			END
		FROM #tempThresHoldInputFile THIF
		INNER JOIN #tempClassCAverage CA
			ON THIF.CSS_City_Class = CA.CSS_City_Class
		WHERE THIF.CSS_City_Class = 'Class C'

	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
