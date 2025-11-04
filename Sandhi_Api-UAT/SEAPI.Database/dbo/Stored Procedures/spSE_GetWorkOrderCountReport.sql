
-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get work order count
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_GetWorkOrderCountReport '2021-08-01','2022-01-11',NULL,'South','HBN' ---,'37B5B5A7-7D81-4F08-90DC-BC7783D8C0B2'

CREATE procedure [dbo].[spSE_GetWorkOrderCountReport]
(
	@pFromDate DateTime
	,@pToDate DateTime
	,@pCSS_Id BIGINT = NULL
	,@pRegion NVARCHAR(MAX) = NULL
	,@pBusinessUnit NVARCHAR(MAX) = NULL
	,@cssManagerUserId	NVarchar(max)=null
)
AS
BEGIN
	
	drop table if exists #tempWorkOrderCount, #tempPivotWorkOrderCount
	declare @fromDate		DateTime
	declare @toDate			DateTime
	SELECT @fromDate = DATEADD(mm, DATEDIFF(mm, 0, @pFromDate) , 0); --DATEADD(DD,-(DAY(@pFromDate)), @pFromDate) 
	SELECT @toDate = EOMONTH(@pToDate) --DATEADD(DD,-(DAY(@pToDate)), DATEADD(MM, 1, @pToDate)) 

	SELECT
		CM.CSS_Code
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region 
		,CM.Id AS CSS_Id
		,WO.Month_Name 
		,WO.WO_BusinessUnit
		,CASE WHEN WO.AMC_WARRANTY_FLAG IS NULL THEN 'NotCategorised' ELSE WO.AMC_WARRANTY_FLAG END AMC_WARRANTY_FLAG
		,COUNT(1) AS WorkOrderCount
	INTO #tempWorkOrderCount
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_Work_Order WO
		ON CM.Id = WO.CSS_Id 
	WHERE 
		--CAST(WO_Month AS INT) between CAST(Month(@pFromDate) AS INT) AND CAST(Month(@pToDate) AS INT)
		--AND CAST(WO_Year AS INT) between CAST(Year(@pFromDate) AS INT) AND CAST(Year(@pToDate) AS INT)
		Cast(CONCAT(wo_month,'/01/',wo_year) as DateTime) between @fromDate and @toDate
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND WO.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN WO.WO_BusinessUnit ELSE @pBusinessUnit END
		and CM.CSS_MGR_USER_ID = case when @cssManagerUserId is null then cm.CSS_MGR_USER_ID else @cssManagerUserId end 
	GROUP BY
		CM.CSS_Code
		,CM.Id 
		,WO.Month_Name 
		,WO.AMC_WARRANTY_FLAG
		,WO.WO_BusinessUnit
		,CM.CSS_Name_as_per_Oracle_SAP
		,CM.Region


	SELECT 
		*
	INTO #tempPivotWorkOrderCount
	FROM   
	
	(
		SELECT 
			CSS_Id,
			CSS_Code,
			CSS_Name,
			Region,
			Month_Name,
			WO_BusinessUnit,
			AMC_WARRANTY_FLAG,
			WorkOrderCount
		FROM #tempWorkOrderCount p
	) t 
	PIVOT(
		SUM(WorkOrderCount) 
		FOR AMC_WARRANTY_FLAG IN (
			[Warranty], 
			[AMC], 
			[NotCategorised])
	) AS pivot_table;

	SELECT
		CSS_Id	
		,CSS_Code	
		,CSS_Name
		,Region
		,Month_Name	
		,WO_BusinessUnit	
		,ISNULL(Warranty,0)	AS Warranty
		,ISNULL(AMC,0) AS AMC
		,ISNULL(NotCategorised,0) AS NotCategorised
		,(ISNULL(Warranty,0) + ISNULL(AMC,0) + ISNULL(NotCategorised,0)) AS Total
	FROM #tempPivotWorkOrderCount
	order by  Month_Name, Css_Code 
END
