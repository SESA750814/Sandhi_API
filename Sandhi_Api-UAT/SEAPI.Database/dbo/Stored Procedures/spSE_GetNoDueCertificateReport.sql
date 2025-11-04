-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 22-01-2022
-- Description  : Get no due certificate
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_GetNoDueCertificateReport null,NULL,NULL

CREATE PROCEDURE [dbo].[spSE_GetNoDueCertificateReport]
(
	@pCSS_Id BIGINT = NULL
	,@pRegion NVARCHAR(MAX) = NULL
	,@pBusinessUnit NVARCHAR(MAX) = NULL
)
AS
BEGIN
	
	DROP TABLE IF EXISTS #tempLastSubmittedDate, #tempDateSubmitted, #tempPendingDate

	SELECT DISTINCT
		CM.Id AS CSSId
		,CM.CSS_Code AS CSSCode
		,CM.CSS_Name_as_per_Oracle_SAP as CSS_Name
		,CM.Region
		,CM.Business_Unit 
		,MAX(NO_DUE_DATE) AS LastSubmittedDate
	INTO #tempLastSubmittedDate
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_CSS_INVOICE CI
		ON CM.Id = CI.CSS_Id 
	WHERE CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND CI.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN CI.WO_BusinessUnit ELSE @pBusinessUnit END
	GROUP BY
		CM.Id
		,CM.CSS_Code 
		,CM.CSS_Name_as_per_Oracle_SAP 
		,CM.Region
		, CM.Business_Unit

	SELECT DISTINCT
		CM.Id AS CSSId
		,CM.CSS_Code AS CSSCode
		,STUFF((SELECT  DISTINCT ','+CAST(Month_Name AS VARCHAR(100)) FROM SE_CSS_INVOICE SCI WHERE CI.CSS_ID = SCI.CSS_ID FOR XML PATH('')),1,1,'') AS DateSubmitted
	INTO #tempDateSubmitted
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_CSS_INVOICE CI
		ON CM.Id = CI.CSS_Id 
	WHERE CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND CI.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN CI.WO_BusinessUnit ELSE @pBusinessUnit END
		AND NO_DUE_DATE IS NOT NULL

	SELECT DISTINCT
		CM.Id AS CSSId
		,CM.CSS_Code AS CSSCode
		,STUFF((SELECT DISTINCT ','+CAST(Month_Name AS VARCHAR(100)) FROM SE_CSS_INVOICE SCI WHERE CI.CSS_ID = SCI.CSS_ID FOR XML PATH('')),1,1,'') AS PendingDate
	INTO #tempPendingDate
	FROM SE_CSS_MASTER CM		
	INNER JOIN SE_CSS_INVOICE CI
		ON CM.Id = CI.CSS_Id 
	WHERE CM.Id = CASE WHEN @pCSS_Id IS NULL THEN CM.Id ELSE @pCSS_Id END
		AND CM.Region = CASE WHEN @pRegion IS NULL THEN CM.Region ELSE @pRegion END
		AND CI.WO_BusinessUnit = CASE WHEN @pBusinessUnit IS NULL THEN CI.WO_BusinessUnit ELSE @pBusinessUnit END
		AND NO_DUE_DATE IS NULL

	SELECT 
		TLS.CSSCode
		,CSS_Name
		,Region
		,TLS.LastSubmittedDate
		,TDS.DateSubmitted as SubmittedMonths
		,TPD.PendingDate as PendingMonths
		, Business_Unit
	FROM #tempLastSubmittedDate TLS
	LEFT JOIN #tempDateSubmitted TDS
		ON TLS.CSSId = TDS.CSSId
	LEFT JOIN #tempPendingDate TPD
		ON TLS.CSSId = TPD.CSSId

END







