-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Update invoice amount
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_UpdateCSSInvoiceAmount

CREATE procedure [dbo].[spSE_UpdateCSSInvoiceAmount]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)

		--DROP TABLE IF EXISTS #tempCSSAmount, #tempCSSPercentage

		--SELECT
		--	TCG.Id AS InvoiceId
		--	,CSS_ID
		--	,AMOUNT
		--	,FINAL_GRADE
		--	,GRADATION_TYPE
		--	,CSS_PAYOUT
		--	,GRADE_PERCENT
		--INTO #tempCSSAmount
		--FROM
		--(
		--	SELECT
		--		CI.Id
		--		,CI.CSS_ID
		--		,FINAL_GRADE
		--		,WO_AMT AS AMOUNT
		--	FROM SE_CSS_INVOICE CI
		--	INNER JOIN SE_CSS_GRADATION CG
		--		ON CI.CSS_ID = CG.CSS_ID
		--) TCG
		--INNER JOIN SE_CSS_Master CM
		--	ON TCG.CSS_ID = CM.Id
		--INNER JOIN SE_GRADATION_MASTER GM
		--	ON CM.Pay_out_Structure = GM.CSS_PAYOUT
		--	AND TCG.FINAL_GRADE = GM.GRADE

		--UPDATE CI SET
		--	BASE_PAYOUT = (A.AMOUNT * A.GRADE_PERCENT)/100
		--FROM SE_CSS_INVOICE CI
		--INNER JOIN #tempCSSAmount A
		--	ON CI.Id = A.InvoiceId
		--WHERE GRADATION_TYPE = 'Base payout'

		--UPDATE CI SET
		--	INCENTIVE_AMT = (CI.BASE_PAYOUT * A.GRADE_PERCENT)/100
		--FROM SE_CSS_INVOICE CI
		--INNER JOIN #tempCSSAmount A
		--	ON CI.Id = A.InvoiceId
		--WHERE GRADATION_TYPE = 'Incentive benefit'

		--UPDATE CI SET
		--	INV_AMT = BASE_PAYOUT + INCENTIVE_AMT
		--FROM SE_CSS_INVOICE CI

		--UPDATE CI SET
		--	TAX_AMT = (INV_AMT * 18)/100
		--FROM SE_CSS_INVOICE CI

		--UPDATE CI SET
		--	INC_TAX_AMT = INV_AMT + TAX_AMT
		--FROM SE_CSS_INVOICE CI

		UPDATE CM SET
			CM.Grade = A.FINAL_GRADE
		FROM SE_CSS_MASTER CM
		INNER JOIN (
					SELECT 
						CSS_ID
						,FINAL_GRADE
					FROM dbo.SE_CSS_GRADATION CG
					WHERE CONVERT(DATE,GETDATE()) BETWEEN CONVERT(DATE,CG.VALID_FROM) AND CONVERT(DATE,CG.VALID_TILL)
					)A
			ON CM.Id = A.CSS_ID

		SELECT DISTINCT
			CM.Id AS CSS_ID
			,GM.GRADATION_TYPE
			,GM.CSS_PAYOUT
			,GM.GRADE_PERCENT
			,GM.GRADE
			,CRN.FINAL_GRADE
		INTO #tempCSSPercentage
		FROM SE_CSS_Master CM
		INNER JOIN SE_CSS_GRADATION CRN
			ON CM.Id = CRN.CSS_ID
		INNER JOIN SE_GRADATION_MASTER GM
			ON CM.Pay_out_Structure = GM.CSS_PAYOUT
			AND CRN.FINAL_GRADE = GM.GRADE

		UPDATE CM SET
			CM.Base_Payout_Percentage = CA.GRADE_PERCENT
		FROM SE_CSS_MASTER CM
		INNER JOIN #tempCSSPercentage CA
			ON CM.Id = CA.CSS_ID
		WHERE GRADATION_TYPE = 'Base payout'

		UPDATE CM SET
			CM.Incentive_Percentage = CA.GRADE_PERCENT
		FROM SE_CSS_MASTER CM
		INNER JOIN #tempCSSPercentage CA
			ON CM.Id = CA.CSS_ID
		WHERE GRADATION_TYPE = 'Incentive benefit'

		UPDATE CG SET
			CG.Grade = CASE WHEN FG.GradationEligibility = 'No' THEN 'Not Applicable' ELSE CG.Grade END,
			cg.Base_Payout_Percentage= CASE WHEN FG.GradationEligibility = 'No' THEN 100 ELSE CG.Base_Payout_Percentage END,
			cg.Incentive_Percentage= CASE WHEN FG.GradationEligibility = 'No' THEN 0 ELSE CG.Incentive_Percentage END
		FROM dbo.SE_CSS_Master CG
		INNER JOIN dbo.ThresHold FG
			ON CG.CSS_Code = FG.CssCode
		WHERE FG.UpdatedDateTime IS NULL

		UPDATE dbo.ThresHold SET UpdatedDateTime = GETDATE() WHERE UpdatedDateTime IS NULL
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH
END
