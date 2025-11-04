
-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get work order discrepency report
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_GetWorkOrderDiscrepencyReport '2021-08-01','2021-12-11',NULL,NULL,NULL

CREATE procedure [dbo].[spSE_GetWorkOrderDiscrepencyReport]
(
	@pFromDate DateTime
	,@pToDate DateTime
	,@pCSS_Id BIGINT = NULL
	,@pRegion NVARCHAR(MAX) = NULL
	,@pBusinessUnit NVARCHAR(MAX) = NULL
)
AS
BEGIN
	
	DECLARE @Reason VARCHAR(2000);
	DECLARE @PivotReason VARCHAR(2000);
	DECLARE @Query NVARCHAR(MAX);
	declare @fromDate		DateTime
	declare @toDate			DateTime
	declare @StatusType INT = 4;
	SELECT @fromDate = DATEADD(mm, DATEDIFF(mm, 0, @pFromDate) , 0); --DATEADD(DD,-(DAY(@pFromDate)), @pFromDate) 
	SELECT @toDate = EOMONTH(@pToDate) --DATEADD(DD,-(DAY(@pToDate)), DATEADD(MM, 1, @pToDate)) 

	DROP TABLE IF EXISTS #tmpReason, #tempWorkOrderCount, #tempReasonDiscrepencyCount

	CREATE TABLE #tempWorkOrderCount
	(
		ReasonDetails VARCHAR(MAX)
		,CSS_Code VARCHAR(MAX)
		,CSS_Id BIGINT
		,CSS_Name VARCHAR(MAX)
		,Region VARCHAR(MAX)
		,[Month] VARCHAR(MAX)
		,BusinessUnit VARCHAR(MAX)
		,WorkOrderCount INT
	)

	INSERT INTO #tempWorkOrderCount
	(
		CSS_Code
		,CSS_Id
		,CSS_Name
		,Region 
		,[Month] 
		,BusinessUnit 
		,WorkOrderCount
	)
	SELECT
		CM.CSS_Code
		,CM.Id AS CSS_Id
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		,WO.Month_Name 
		,WO.WO_BusinessUnit
		--,WOS.Reason
		,COUNT(1) AS WorkOrderCount
	--INTO #tempWorkOrderCount
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_Work_Order WO
		ON CM.Id = WO.CSS_Id 
	--INNER JOIN SE_WORK_ORDER_STATUS WOS
	--	ON WO.Id = WOS.Work_Order_Id
	WHERE Cast(CONCAT(wo_month,'/01/',wo_year) as DateTime) between @fromDate and @toDate
		--CAST(WO_Month AS INT) between CAST(Month(@pFromDate) AS INT) AND CAST(Month(@pToDate) AS INT)
		--AND CAST(WO_Year AS INT) between CAST(Year(@pFromDate) AS INT) AND CAST(Year(@pToDate) AS INT)
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND WO.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN WO.WO_BusinessUnit ELSE @pBusinessUnit END
	GROUP BY
		CM.CSS_Code
		,CM.Id 
		,CM.CSS_Name_as_per_Oracle_SAP
		,CM.Region
		,WO.Month_Name 
		,WO.WO_BusinessUnit
		--,WOS.Reason

	SELECT
		CM.Id AS CSS_Id
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		,WO.Month_Name 
		,WO.WO_BusinessUnit
		,WOS.Reason
		,COUNT(1) AS ReasonDiscrepencyCount
	INTO #tempReasonDiscrepencyCount
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_Work_Order WO
		ON CM.Id = WO.CSS_Id 
	INNER JOIN SE_WORK_ORDER_STATUS WOS
		ON WO.Id = WOS.Work_Order_Id
	WHERE WOS.Status_Type = @StatusType
		AND Cast(CONCAT(wo_month,'/01/',wo_year) as DateTime) between @fromDate and @toDate 
		--AND CAST(WO_Month AS INT) between CAST(Month(@pFromDate) AS INT) AND CAST(Month(@pToDate) AS INT)
		--AND CAST(WO_Year AS INT) between CAST(Year(@pFromDate) AS INT) AND CAST(Year(@pToDate) AS INT)
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND WO.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN WO.WO_BusinessUnit ELSE @pBusinessUnit END
	GROUP BY
		CM.CSS_Code
		,CM.Id 
		,CM.CSS_Name_as_per_Oracle_SAP 
		,CM.Region
		,WO.Month_Name 
		,WO.WO_BusinessUnit
		,WOS.Reason

	SELECT distinct 
		@Reason = STUFF((SELECT ','+ Reason FROM #tempReasonDiscrepencyCount T1 where trim(coalesce(Reason,''))<>''  GROUP BY Reason  ORDER BY Reason ASC
		FOR XML PATH('')),1,1,'')
	FROM #tempReasonDiscrepencyCount T2 

	SELECT distinct 
		@PivotReason = STUFF((SELECT ','+ CONCAT('[',Reason,']') FROM #tempReasonDiscrepencyCount T1 where trim(coalesce(Reason,''))<>'' GROUP BY Reason ORDER BY Reason ASC
		FOR XML PATH('')),1,1,'')
	FROM #tempReasonDiscrepencyCount T2

	print @reason

	print @PivotReason
	UPDATE #tempWorkOrderCount SET ReasonDetails = @Reason

	SET @Query = 'SELECT 
					*
				FROM   
				(
					SELECT 
						ReasonDetails
						,TWOC.CSS_Code
						,TWOC.CSS_Name
						,TWOC.[Month]
						,TWOC.BusinessUnit
						,TWOC.Region
						,Reason
						,WorkOrderCount
						,ISNULL(ReasonDiscrepencyCount,0) AS ReasonDiscrepencyCount
					FROM #tempWorkOrderCount TWOC
					INNER JOIN #tempReasonDiscrepencyCount TWODC
						ON TWOC.CSS_Id = TWODC.CSS_Id
				) t 
				PIVOT(
					SUM(ReasonDiscrepencyCount) 
					FOR Reason IN (
						'+ @PivotReason +')
				) AS pivot_table;'

	EXEC(@Query)

	--INSERT INTO WorkOrderDiscrepencyReport
	--(
	--	Guid
	--	,CSS_Id
	--	,Month_Name
	--	,WO_BusinessUnit
	--	,WorkOrderCount
	--	,DiscrepencyCount
	--	,Percentage
	--	,FromDate
	--	,ToDate
	--	,UpdatedDateTime
	--)
	--SELECT
	--	@pGuid
	--	,TWOC.CSS_Id
	--	,TWOC.Month_Name
	--	,TWOC.WO_BusinessUnit
	--	,WorkOrderCount
	--	,WorkOrderDiscrepencyCount
	--	,CAST(WorkOrderDiscrepencyCount AS DECIMAL(18,5)) / CAST(WorkOrderCount AS DECIMAL(18,5))*100.0 
	--	,@pFromDate
	--	,@pToDate
	--	,GETDATE()
	--FROM #tempWorkOrderCount TWOC
	--INNER JOIN #tempWorkOrderDiscrepencyCount TWODC
	--	ON TWOC.CSS_Id = TWODC.CSS_Id

	--SELECT
	--	TWOC.CSS_Code
	--	,TWOC.CSS_Name
	--	,TWOC.Region
	--	,TWOC.Month_Name
	--	,TWOC.WO_BusinessUnit
	--	,Reason
	--	,WorkOrderCount
	--	,ReasonDiscrepencyCount
	--	,CAST(CAST(ReasonDiscrepencyCount AS DECIMAL(18,5)) / CAST(WorkOrderCount AS DECIMAL(18,5))*100.0 AS DECIMAL(18,2)) AS Percentage
	--	,@Reason ReasonDetails
	--FROM #tempWorkOrderCount TWOC
	--INNER JOIN #tempReasonDiscrepencyCount TWODC
	--	ON TWOC.CSS_Id = TWODC.CSS_Id

END
