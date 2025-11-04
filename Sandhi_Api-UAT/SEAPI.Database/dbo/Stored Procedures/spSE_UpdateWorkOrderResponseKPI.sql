-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Update gradation details in respective tables
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateWorkOrderResponseKPI

CREATE procedure [dbo].[spSE_UpdateWorkOrderResponseKPI]
	
AS
BEGIN
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000), @Holiday VARCHAR(MAX);
		--Get KPI for work order response

		DROP TABLE IF EXISTS #tempWork_Order_Response, #tempWorkResponseAVG, #tempWorkResponseRowNumber;
		DECLARE @TodayDateTime DATETIME =  GETDATE();

		SELECT 
			@Holiday = STRING_AGG(CONVERT(NVARCHAR(max), Holiday), ',')   
		FROM dbo.GradationHolidays
		WHERE IsActive = 1

		SELECT
			Id
			,CSS_Code
			,_Work_Order_Number
			,Category_r
			,dbo.fn_GetHoursAndMinutes(CONVERT(DATETIME,Partner_Assigned_Date_Time,101), CONVERT(DATETIME,First_Assigned_DateTime,101), @Holiday) HoursAndMinutes
			,dbo.fn_GetMinutes(CONVERT(DATETIME,Partner_Assigned_Date_Time,101), CONVERT(DATETIME,First_Assigned_DateTime,101), @Holiday) Minutes
		INTO #tempWork_Order_Response
		FROM dbo.Work_Order_Response
		WHERE HoursMinutes IS NULL
		AND (UpdateHoursMinutesDateTime IS NULL OR UpdateHoursMinutesDateTime > @TodayDateTime)

		UPDATE WOR SET
			WOR.HoursMinutes = CASE WHEN TWOR.Minutes > 0 THEN TWOR.HoursAndMinutes END
			,UpdateHoursMinutesDateTime = @TodayDateTime
			,TotalMinutes = CASE WHEN TWOR.Minutes > 0 THEN TWOR.Minutes END
		FROM dbo.Work_Order_Response WOR
		INNER JOIN #tempWork_Order_Response TWOR
			ON WOR.Id = TWOR.Id
			--AND WOR.CSS_Code = TWOR.CSS_Code
			--AND WOR.Category_r = TWOR.Category_r

	
		SELECT DISTINCT
			CSS_Code
			,Category_r
			,NoOfRecords
			,Total 
			,WorkOrderAVG AS Minutes
			,CAST(WorkOrderAVG AS DECIMAL(10,2))/60.0 AS WorkOrderAVG
			,CASE 
				WHEN WorkOrderAVG BETWEEN gkm.FromMinutes AND gkm.ToMinutes 
				THEN GradeID 
				ELSE 1
			END AS GradeID
		INTO #tempWorkResponseAVG
		FROM (
			SELECT 
				CSS_Code
				,Category_r
				,COUNT(1) AS NoOfRecords
				,dbo.fn_MinutesToHoursAndMinutes(SUM(CAST(Minutes AS INT))) Total
				,AVG(CAST(Minutes AS INT)) WorkOrderAVG
			FROM #tempWork_Order_Response
			WHERE Minutes> 0
			GROUP BY
				CSS_Code
				,Category_r
			)a
		inner join Gradation_KPI_Metrics gkm
			ON gkm.ParameterGroup = 4

		SELECT 
		   ROW_NUMBER() OVER (PARTITION BY CSS_Code, Category_r ORDER BY GradeID DESC) RowNumber,
			CSS_Code
			,Category_r
			,NoOfRecords
			,Total 
			,Minutes
			,WorkOrderAVG
			,GradeID
		INTO #tempWorkResponseRowNumber
		FROM #tempWorkResponseAVG

		INSERT INTO dbo.Work_Order_Response_KPIHistories
		(
			Work_Order_Response_KPIID 
			,CSSCode
			,Category_BU
			,NoOfRecords
			,Total
			,AVG
			,KPI
			,[Minutes]
			,AVGHoursMinutes
			,UpdatedDateTIme
			,HistoryCreatedDate
		)
		SELECT 
			Work_Order_Response_KPIID
			,CSSCode
			,Category_BU
			,NoOfRecords
			,Total
			,AVG
			,KPI
			,[Minutes]
			,AVGHoursMinutes
			,UpdatedDateTIme
			,@TodayDateTime
		FROM dbo.Work_Order_Response_KPI

		TRUNCATE TABLE dbo.Work_Order_Response_KPI

		INSERT INTO dbo.Work_Order_Response_KPI
		(
			CSSCode
			,Category_BU
			,NoOfRecords
			,Total
			,Minutes
			,AVG
			,KPI
			,AVGHoursMinutes
			,UpdatedDateTIme
		)
		SELECT
			TWR.CSS_Code
			,TWR.Category_r
			,TWR.NoOfRecords
			,TWR.Total 
			,TWR.Minutes
			,CAST(TWR.WorkOrderAVG AS DECIMAL(10,2))/60.0 AS WorkOrderAVG
			,TWR.GradeID
			,[dbo].[fn_MinutesToHoursAndMinutes](TWR.Minutes)
			,@TodayDateTime
		FROM #tempWorkResponseRowNumber TWR
		LEFT JOIN dbo.Work_Order_Response_KPI WOR
			ON TWR.CSS_Code = WOR.CSSCode
			AND TWR.Category_r = WOR.Category_BU
		WHERE WOR.Category_BU IS NULL AND RowNumber = 1

		--UPDATE WOR SET
		--	WOR.NoOfRecords = TWR.NoOfRecords
		--	,WOR.Total = TWR.Total
		--	,WOR.Minutes = TWR.Minutes
		--	,WOR.AVG = TWR.WorkOrderAVG
		--	,WOR.KPI = TWR.GradeID
		--	,WOR.UpdatedDateTIme = @TodayDateTime
		--FROM dbo.Work_Order_Response_KPI WOR
		--INNER  JOIN #tempWorkResponseRowNumber TWR
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
