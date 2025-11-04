-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 22-01-2022
-- Description  : Get work order count
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_GetCssMonthInvoiceReport '2021-01-01','2022-01-01',NULL,NULL,NULL

CREATE PROCEDURE [dbo].[spSE_GetCssMonthInvoiceReport]
(
	@pFromDate DateTime
	,@pToDate DateTime
	,@pCSS_Id BIGINT = NULL
	,@pRegion NVARCHAR(MAX) = NULL
	,@pBusinessUnit NVARCHAR(MAX) = NULL
)
AS
BEGIN
	
	DROP TABLE IF EXISTS #tempCSSMonthInvoiceAmount
	declare @fromDate		DateTime
	declare @toDate			DateTime
	SELECT @fromDate = DATEADD(mm, DATEDIFF(mm, 0, @pFromDate) , 0); --DATEADD(DD,-(DAY(@pFromDate)), @pFromDate) 
	SELECT @toDate = EOMONTH(@pToDate) --DATEADD(DD,-(DAY(@pToDate)), DATEADD(MM, 1, @pToDate)) 

	SELECT
		CM.CSS_Code AS CSSCode
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		--,CM.Id AS CSS_Id
		,CSSIN.Month_Name AS [Month]
		--,CSSIN.AMC_WARRANTY_FLAG
		,CSSIN.WO_BusinessUnit AS BusinessUnit
		--,CASE WHEN INV_TYPE = 'All' THEN 'N/A' ELSE INV_TYPE END  AS InvoiceType
		,INV_TYPE AS InvoiceType
		,INV_AMT AS InvoiceAmount
	INTO #tempCSSMonthInvoiceAmount
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_CSS_INVOICE CSSIN
		ON CM.Id = CSSIN.CSS_Id 
	WHERE CONVERT(DATE,INV_DATE) between CONVERT(DATE,@fromDate) AND CONVERT(DATE,@toDate) 
		--AND CAST(WO_Year AS INT) between CAST(Year(@pFromDate) AS INT) AND CAST(Year(@pToDate) AS INT)
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND CSSIN.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN CSSIN.WO_BusinessUnit ELSE @pBusinessUnit END
 
		
	SELECT 
		*
	INTO #tempPivotInvoice
	FROM   
	
	(
		SELECT 
			--CSS_Id,
			CSSCode,
			Css_Name,
			Region,
			[Month],
			BusinessUnit,
			InvoiceType,
			InvoiceAmount
		FROM #tempCSSMonthInvoiceAmount p
	) t 
	PIVOT(
		SUM(InvoiceAmount) 
		FOR InvoiceType IN (
			[All], 
			[Labour], 
			[Supply])
	) AS pivot_table;


	--INSERT INTO CSSInvoiceAmount
	--(
	--	Guid 
	--	,CSS_Id
	--	,Month_Name 
	--	,WO_BusinessUnit 
	--	,InvoiceAmount 
	--	,Labour_Amount 
	--	,Supply_Amount 
	--	,FromDate 
	--	,ToDate 
	--	,UpdatedDateTime 
	--)
	--SELECT
	--	@pGuid
	--	,CSS_Id
	--	,Month_Name
	--	,WO_BusinessUnit
	--	,[All]
	--	,[Labour]
	--	,[Supply]
	--	,@pFromDate
	--	,@pToDate
	--	,GETDATE()
	--FROM #tempPivotInvoice

	SELECT
		CSSCode
		,Css_Name
		,Region
		,Month
		,BusinessUnit
		,ISNULL([Labour],0) AS Labour_Amount
		,ISNULL([Supply],0) AS Supply_Amount
		,CASE 
			WHEN BusinessUnit = 'Cooling'
			THEN  coalesce([Labour],0) + coalesce([Supply],0)
			ELSE [All]
		END AS InvoiceAmount
	FROM #tempPivotInvoice

END
