
-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get work order semi draft report
-- =============================================

-- EXEC spSE_GetWorkOrderSemiDraftReport '2021-08-01','2021-12-11',80785,NULL,NULL

CREATE procedure [dbo].[spSE_GetWorkOrderSemiDraftReport]
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
	
	DROP TABLE IF EXISTS #tempWorkOrderSemiDraft

	declare @fromDate		DateTime
	declare @toDate			DateTime
	SELECT @fromDate = DATEADD(mm, DATEDIFF(mm, 0, @pFromDate) , 0); 
	SELECT @toDate = EOMONTH(@pToDate);

	SELECT 
		CM.CSS_Code
		,CM.Id AS CSS_Id
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		,WO.Month_Name 
		,WO.WO_BusinessUnit AS BusinessUnit
		,WOS.Status_Type
		,WO.Work_Order_Number
		--,CASE 
		--	WHEN WOS.Status_Type = -99 THEN 'Imported'
		--	WHEN WOS.Status_Type = 0 THEN 'Central Approved'
		--	WHEN WOS.Status_Type = 1 THEN 'Central Rejected'
		--	WHEN WOS.Status_Type = 2 THEN 'CSS Validated'
		--	WHEN WOS.Status_Type = 3 THEN 'CSS Approved'
		--	WHEN WOS.Status_Type = 4 THEN 'CSS Discrepancy'
		--	WHEN WOS.Status_Type = 5 THEN 'CSS Manager Approved'
		--	WHEN WOS.Status_Type = 6 THEN 'CSS Manager Discrepancy'
		--	WHEN WOS.Status_Type = 7 THEN 'CSS Manager Approved Discrepancy'
		--	WHEN WOS.Status_Type = 8 THEN 'PRF Raised'
		--	WHEN WOS.Status_Type = 9 THEN 'Waiting for PO'
		--	WHEN WOS.Status_Type = 10 THEN 'Invoice Raised'
		--	WHEN WOS.Status_Type = 11 THEN 'Invoice Validated'
		--	WHEN WOS.Status_Type = 12 THEN 'Invoice Rejected'
		--	WHEN WOS.Status_Type = 13 THEN 'GRN Clarification'
		--	WHEN WOS.Status_Type = 14 THEN 'GRN Raised'
		--	WHEN WOS.Status_Type = 15 THEN 'Invoice Paid'
		--END Status_Type
		--,IIF(CSS_Status = 1 , 'Approved' ,'Rejected') CSS_Status
		--,IIF(Central_Status = 1 , 'Approved' ,'Rejected') Central_Status
		--,CSS_UpdatedDate
	INTO #tempWorkOrderSemiDraft
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_Work_Order WO
		ON CM.Id = WO.CSS_Id 
	INNER JOIN SE_WORK_ORDER_STATUS WOS
		ON WO.Id = WOS.Work_Order_Id
	WHERE WOS.Status_Type > 1 
		--AND CAST(WO_Month AS INT) between CAST(Month(@pFromDate) AS INT) AND CAST(Month(@pToDate) AS INT)
		--AND CAST(WO_Year AS INT) between CAST(Year(@pFromDate) AS INT) AND CAST(Year(@pToDate) AS INT)
		AND Cast(CONCAT(wo_month,'/01/',wo_year) as DateTime) between @fromDate and @toDate
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND WO.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN WO.WO_BusinessUnit ELSE @pBusinessUnit END

	SELECT DISTINCT
		CSS_Code
		,CSS_Id
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		,Month_Name 
		,WO.WO_BusinessUnit AS BusinessUnit
		,COUNT(1) AS WorkOrderCount
	INTO #tempWorkOrderCount
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_Work_Order WO
		ON CM.Id = WO.CSS_Id 
	WHERE CONVERT(DATE, Cast(CONCAT(wo_month,'/01/',wo_year) as DateTime)) between CONVERT(DATE,@fromDate) and CONVERT(DATE,@toDate)
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND WO.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN WO.WO_BusinessUnit ELSE @pBusinessUnit END
	GROUP BY
		CSS_Code
		,CSS_Id
		,CM.CSS_Name_as_per_Oracle_SAP 
		,CM.Region
		,Month_Name 
		,WO.WO_BusinessUnit

	SELECT
		CSS_Code
		,CSS_Id
		,Month_Name 
		,BusinessUnit
		,COUNT(1) AS CSSValidatedCount
	INTO #tempCSSValidatedCount
	FROM (
		SELECT
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
			--,COUNT(1) AS CSSValidatedCount
		FROM #tempWorkOrderSemiDraft
		WHERE Status_Type = 2
		GROUP BY
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
		)A
		GROUP BY
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit

	SELECT
		CSS_Code
		,CSS_Id
		,Month_Name 
		,BusinessUnit
		,COUNT(1) AS CSSApprovedCount
	INTO #tempCSSApprovedCount
	FROM (
		SELECT
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
			--,COUNT(1) AS CSSApprovedCount
		FROM #tempWorkOrderSemiDraft
		WHERE Status_Type = 3
		GROUP BY
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
	)A
	GROUP BY
		CSS_Code
		,CSS_Id
		,Month_Name 
		,BusinessUnit

	SELECT
		CSS_Code
		,CSS_Id
		,Month_Name 
		,BusinessUnit
		,COUNT(1) AS CSSDiscrepancyCount
	INTO #tempCSSDiscrepancyCount
	FROM (
		SELECT
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
			--,COUNT(1) AS CSSDiscrepancyCount
		--INTO #tempCSSDiscrepancyCount
		FROM #tempWorkOrderSemiDraft
		WHERE Status_Type = 4
		GROUP BY
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
	)A
	GROUP BY
		CSS_Code
		,CSS_Id
		,Month_Name 
		,BusinessUnit

	SELECT
		CSS_Code
		,CSS_Id
		,Month_Name 
		,BusinessUnit
		,COUNT(1) AS CSSManagerApprovedDiscrepancyCount
	INTO #tempCSSManagerApprovedDiscrepancyCount
	FROM (
		SELECT
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
		--	,COUNT(1) AS CSSManagerApprovedDiscrepancyCount
		--INTO #tempCSSManagerApprovedDiscrepancyCount
		FROM #tempWorkOrderSemiDraft
		WHERE Status_Type = 7
		GROUP BY
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit
			,Work_Order_Number
		)A
		GROUP BY
			CSS_Code
			,CSS_Id
			,Month_Name 
			,BusinessUnit

	--INSERT INTO WorkOrderSemiDraft
	--(
	--	Guid
	--	,CSS_Id
	--	,Month_Name
	--	,WO_BusinessUnit
	--	,Status_Type
	--	,CSS_Status 
	--	,Central_Status 
	--	,CSS_UpdatedDate
	--	,FromDate
	--	,ToDate
	--	,UpdatedDateTime
	--)
	--SELECT
	--	@pGuid
	--	,CSS_Id
	--	,Month_Name
	--	,WO_BusinessUnit
	--	,Status_Type
	--	,CSS_Status 
	--	,Central_Status 
	--	,CSS_UpdatedDate
	--	,@pFromDate
	--	,@pToDate
	--	,GETDATE()
	--FROM #tempWorkOrderSemiDraft

	SELECT DISTINCT
		WO.CSS_Code
		,WO.CSS_Name
		,WO.Region
		,WO.Month_Name
		,WO.BusinessUnit
		,ISNULL(WO.WorkOrderCount,0) AS WorkOrderCount
		,ISNULL(CV.CSSValidatedCount,0) AS CSSValidatedCount
		,ISNULL(CA.CSSApprovedCount,0) AS CSSApprovedCount
		,ISNULL(CD.CSSDiscrepancyCount,0) AS CSSDiscrepancyCount
		,ISNULL(CMAD.CSSManagerApprovedDiscrepancyCount,0) AS CSSManagerApprovedDiscrepancyCount
	FROM #tempWorkOrderCount WO
	LEFT JOIN #tempCSSValidatedCount CV
		ON WO.CSS_Id = CV.CSS_Id
		AND WO.Month_Name = CV.Month_Name
		AND WO.BusinessUnit = CV.BusinessUnit
	LEFT JOIN #tempCSSApprovedCount CA
		ON WO.CSS_Id = CA.CSS_Id
		AND WO.Month_Name = CA.Month_Name
		AND WO.BusinessUnit = CA.BusinessUnit
	LEFT JOIN #tempCSSDiscrepancyCount CD
		ON WO.CSS_Id = CD.CSS_Id
		AND WO.Month_Name = CD.Month_Name
		AND WO.BusinessUnit = CD.BusinessUnit
	LEFT JOIN #tempCSSManagerApprovedDiscrepancyCount CMAD
		ON WO.CSS_Id = CMAD.CSS_Id
		AND WO.Month_Name = CMAD.Month_Name
		AND WO.BusinessUnit = CMAD.BusinessUnit

END
