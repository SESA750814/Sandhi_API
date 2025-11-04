
-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get finance validation repprt
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_GetFinanceValidationReport '2021-08-01','2022-01-11',NULL,NULL,NULL,'S'
--EXEC spSE_GetFinanceValidationReport '2021-08-01','2022-01-11',NULL,NULL,NULL,'D'
CREATE  PROCEDURE [dbo].[spSE_GetFinanceValidationReport]
(
	@pFromDate DateTime
	,@pToDate DateTime
	,@pCSS_Id BIGINT = NULL
	,@pRegion NVARCHAR(MAX) = NULL
	,@pBusinessUnit NVARCHAR(MAX) = NULL
	,@pFilterType CHAR(1) = NULL --D for css wise details / S for financeuser wise summary
)
AS
BEGIN
	
	DROP TABLE IF EXISTS #tempFinanceValidation;
	DECLARE @StatusType INT =  11;
	
	declare @fromDate		DateTime
	declare @toDate			DateTime
	SELECT @fromDate = DATEADD(mm, DATEDIFF(mm, 0, @pFromDate) , 0); --DATEADD(DD,-(DAY(@pFromDate)), @pFromDate) 
	SELECT @toDate = EOMONTH(@pToDate) --DATEADD(DD,-(DAY(@pToDate)), DATEADD(MM, 1, @pToDate)) 

	SELECT DISTINCT
		CM.CSS_Code
		,CM.Id AS CSS_Id
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		,INV.Month_Name AS [Month]
		,INV.WO_BusinessUnit AS BusinessUnit 
		,ASU.UserName AS FinanceValidaterName
		,DATEDIFF(MINUTE,INV.INV_GEN_DATE,INV.FIN_APPROVE_DATE) AS DiffHours
	INTO #tempFinanceValidation
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_CSS_INVOICE INV
		ON CM.Id = INV.CSS_Id 
	INNER JOIN SE_CSS_Invoice_Status INVS
		ON INV.Id = INVS.Inv_Id
	LEFT JOIN AspNetUsers ASU
		ON INVS.Updated_User = ASU.UserName
	WHERE CONVERT(DATE,INV.INV_DATE) between CONVERT(DATE,@fromDate) AND CONVERT(DATE,@toDate)
		AND CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND INV.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN INV.WO_BusinessUnit ELSE @pBusinessUnit END
		AND INVS.Status_Type = @StatusType
	GROUP BY
		CM.CSS_Code
		,CM.Id 
		,CM.CSS_Name_as_per_Oracle_SAP 
		,CM.Region
		,INV.Month_Name 
		,INV.WO_BusinessUnit
		,ASU.UserName
		,INV_GEN_DATE
		,FIN_APPROVE_DATE;

	IF(@pFilterType = 'D')
	BEGIN
		SELECT 			
			FinanceValidaterName
			,CSS_Code
			,CSS_Name
			,Region
			,[Month]
			,BusinessUnit 
			,COUNT(1) AS InvoiceCount
			,CAST(CAST(SUM(DiffHours/60) AS DECIMAL(18,5)) / CAST(COUNT(1) AS DECIMAL(18,5))*100.0 AS DECIMAL(18,2)) AS AVGTAT
		FROM #tempFinanceValidation
		GROUP BY
			FinanceValidaterName
			,CSS_Code
			,CSS_Name
			,Region
			,[Month]
			,BusinessUnit;
	END
	ELSE IF(@pFilterType = 'S')
	BEGIN
		SELECT 
			FinanceValidaterName
			,'' as CssCode
			,'' as CssName
			--,Css_Code + ' - ' + CSS_Name
			,Region
			,[Month]
			,BusinessUnit 
			,COUNT(1) AS InvoiceCount
			,CAST(CAST(SUM(DiffHours/60) AS DECIMAL(18,5)) / CAST(COUNT(1) AS DECIMAL(18,5)) AS DECIMAL(18,2)) AS AVGTAT
		FROM #tempFinanceValidation
		GROUP BY
			FinanceValidaterName
			--, css_code 
			--,CSS_Name
			,Region
			,[Month]
			,BusinessUnit ;
	END
END
