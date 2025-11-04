-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Update KPI for Work Order MTTRv
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateWorkOrderMTTRvKPI

CREATE procedure [dbo].[spSE_UpdateWorkOrderMTTRvKPI]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000), @Holiday VARCHAR(MAX);

		DROP TABLE IF EXISTS #tempWork_order_MTTRv, #tempWorkOrderMTTRAVG, #tempWorkOrderMTTRowNumber
		DECLARE @TodayDateTime DATETIME =  GETDATE();
	
		--Get KPI for Work_order_MTTRv

		SELECT 
			@Holiday = STRING_AGG(CONVERT(NVARCHAR(max), Holiday), ',')   
		FROM dbo.GradationHolidays
		WHERE IsActive = 1
	
		SELECT
			Id
			,CSS_Code
			,Work_Order_Number
			,Category_r
			,dbo.fn_GetDaysAndHoursAndMinutes(try_CONVERT(DATETIME,Partner_Assigned_Date_Time), CASE WHEN ISDATE(try_CONVERT(DATETIME,Completed_On)) = 1 THEN try_CONVERT(DATETIME,Completed_On) ELSE try_convert(DateTime, cast(Completed_On as Float),121) END, @Holiday) DaysAndHoursAndMinutes
			,dbo.fn_GetExcludeWeekEndAndHolidayMinutes(try_CONVERT(DATETIME,Partner_Assigned_Date_Time), CASE WHEN ISDATE(try_CONVERT(DATETIME,Completed_On)) = 1 THEN try_CONVERT(DATETIME,Completed_On) ELSE try_convert(DateTime, cast(Completed_On as Float),121) END, @Holiday) Minutes
		INTO #tempWork_order_MTTRv
		FROM dbo.Work_order_MTTRv
		WHERE DaysHoursMinutes IS NULL
		AND (UpdateDaysHoursMinutesDateTime IS NULL OR UpdateDaysHoursMinutesDateTime > GETDATE())

		UPDATE WOM SET
			WOM.DaysHoursMinutes = CASE WHEN TWOM.Minutes > 0 THEN TWOM.DaysAndHoursAndMinutes END
			,UpdateDaysHoursMinutesDateTime = GETDATE()
			,TotalMinutes = CASE WHEN TWOM.Minutes > 0 THEN TWOM.Minutes END
		FROM dbo.Work_order_MTTRv WOM
		INNER JOIN #tempWork_order_MTTRv TWOM
			ON WOM.Id = TWOM.Id
		
		SELECT DISTINCT
			CSS_Code
			,CSS_City_Class
			,Category_r
			,NoOfRecords
			,Total 
			,MTTRAVG AS Minutes
			,(CAST(MTTRAVG AS DECIMAL(10,2))/60.0)/24.0 AS MTTRAVG
			,CASE 
				WHEN MTTRAVG BETWEEN gkm.FromMinutes AND gkm.ToMinutes 
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempWorkOrderMTTRAVG
		FROM (
			SELECT 
				MTTV.CSS_Code
				,CSSM.CSS_City_Class
				,MTTV.Category_r
				,COUNT(1) AS NoOfRecords
				,dbo.fn_MinutesToDaysAndHoursAndMinutes(SUM(CAST(MTTV.Minutes AS INT))) Total
				,AVG(CAST(MTTV.Minutes AS INT)) MTTRAVG
			FROM #tempWork_order_MTTRv MTTV
			INNER JOIN CSS_List_Payout_Slab_CSS_Manager_Details CSSM
				ON MTTV.CSS_Code = CSSM.CSS_Code
			WHERE Minutes> 0 
			GROUP BY
				MTTV.CSS_Code
				,MTTV.Category_r
				,CSSM.CSS_City_Class
			)a
		inner join Gradation_KPI_Metrics gkm
			ON a.CSS_City_Class = gkm.CityClassGroup 
			AND a.Category_r = gkm.BusinessUnit
			AND gkm.ParameterGroup = 5

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Category_r, CSS_City_Class ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,CSS_City_Class
			,Category_r
			,NoOfRecords
			,Total 
			,Minutes
			,MTTRAVG
			,GradeID
		INTO #tempWorkOrderMTTRowNumber
		FROM #tempWorkOrderMTTRAVG

		 INSERT INTO dbo.Work_order_MTTRv_KPIHistories
		(
			Work_order_MTTRv_KPIID
			,CSSCode
			,CityClass 
			,Category_BU	
			,NoOfRecords	
			,Total
			,AVG	
			,KPI	
			,Minutes	
			,AVGDaysHoursMinutes
			,UpdatedDateTime 
			,HistoryCreatedTime 
		)
		SELECT
			Work_order_MTTRv_KPIID
			,CSSCode
			,CityClass
			,Category_BU
			,NoOfRecords
			,Total
			,AVG
			,KPI
			,Minutes
			,AVGDaysHoursMinutes
			,UpdatedDateTime
			,@TodayDateTime
		FROM dbo.Work_order_MTTRv_KPI

		TRUNCATE TABLE dbo.Work_order_MTTRv_KPI

		INSERT INTO dbo.Work_order_MTTRv_KPI
		(
			CSSCode
			,CityClass
			,Category_BU
			,NoOfRecords
			,Total
			,AVG
			,KPI
			,Minutes
			,AVGDaysHoursMinutes
			,UpdatedDateTime
		
		)
		SELECT
			TWR.CSS_Code
			,TWR.CSS_City_Class
			,TWR.Category_r
			,TWR.NoOfRecords
			,TWR.Total 
			,CAST(TWR.MTTRAVG AS DECIMAL(10,2))/60.0 AS MTTRAVG
			,TWR.GradeID
			,TWR.Minutes
			,[dbo].[fn_MinutesToDaysAndHoursAndMinutes](TWR.Minutes)
			,@TodayDateTime
		FROM #tempWorkOrderMTTRowNumber TWR
		LEFT JOIN dbo.Work_order_MTTRv_KPI WOR
			ON TWR.CSS_Code = WOR.CSSCode
			AND TWR.Category_r = WOR.Category_BU
		WHERE WOR.Category_BU IS NULL AND RowNumber = 1

		--UPDATE WOR SET
		--	WOR.NoOfRecords = TWR.NoOfRecords
		--	,WOR.Total = TWR.Total
		--	,WOR.Minutes = TWR.Minutes
		--	,WOR.AVG = TWR.MTTRAVG
		--	,WOR.KPI = TWR.GradeID
		--	,WOR.UpdatedDateTime = @TodayDateTime
		--FROM dbo.Work_order_MTTRv_KPI WOR
		--INNER  JOIN #tempWorkOrderMTTRowNumber TWR
		--	ON TWR.CSS_Code = WOR.CSSCode
		--	AND TWR.Category_r = WOR.Category_BU
		--WHERE RowNumber = 1
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
