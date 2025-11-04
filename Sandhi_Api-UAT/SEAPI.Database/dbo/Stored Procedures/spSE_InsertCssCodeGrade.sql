-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Get KPI for NPFH BNK
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_InsertCssCodeGrade

CREATE procedure [dbo].[spSE_InsertCssCodeGrade]
	
AS
BEGIN

	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		DROP TABLE IF EXISTS #tempSE_CSS_GRADATION, #tempSE_CSS_GRADATION_DETAIL, #tmpSafetyRatingScoreKPI, #tmpCustomerSatisfactionScoreNSSKPI, #tmpCustomerSurveyResponseRateKPI, #tmpWork_Order_Response_KPI
		,#tmpWork_order_MTTRv_KPI, #tmpPreventiveMaintainanceComplianceCoolingKPI, #tmpDefectiveReturnHBNKPI, #tmpDefectiveReturnRatePPAndIKPI, #tmpNPFHBNKPI, #tmpAttritionKPI, #tmpFSRCompetencyKPI
		,#tmpLeadGenerationKPI, #tmpIBTrackingKPI,#tmpFinalGrade

		DECLARE @TodayDateTime DATETIME =  GETDATE();

		CREATE TABLE #tempSE_CSS_GRADATION
		(
			CSS_ID	BIGINT
			,VALID_FROM	DATETIME 
			,VALID_TILL	DATETIME
			,SRS_GRADE	VARCHAR(100)
			,NSS_GRADE	VARCHAR(100)
			,CSR_GRADE	VARCHAR(100)
			,WOR_GRADE	VARCHAR(100)
			,MTTR_GRADE	VARCHAR(100)
			,PMC_GRADE	VARCHAR(100)
			,DFR_HBN_GRADE	VARCHAR(100)
			,DFR_PPI_GRADE	VARCHAR(100)
			,NPF_GRADE	VARCHAR(100)
			,ATTR_GRADE	VARCHAR(100)
			,FRS_GRADE	VARCHAR(100)
			,LEAD_GRADE	VARCHAR(100)
			,IB_GRADE	VARCHAR(100)
			,FINAL_GRADE	VARCHAR(100)
			,Updated_User	VARCHAR(100)
			,Updated_Date	DATETIME
			,GradationEligibility VARCHAR(100)
		)

		CREATE TABLE #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID	BIGINT
			,GRADATION_ID BIGINT
			,GRADE_TYPE	VARCHAR(100)
			,CITY_CLASS	VARCHAR(100)
			,BUSINESS_UNIT VARCHAR(100)
			,GRADE_SCORE VARCHAR(100)	--NUMERIC(18,2)
			,GRADEID INT
			,GRADE	VARCHAR(100)
			,Updated_User	VARCHAR(100)
			,Updated_Date	DATETIME
		)

		INSERT INTO #tempSE_CSS_GRADATION
		(CSS_ID, VALID_FROM, VALID_TILL,Updated_Date)
		SELECT
			Id
			,DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime), 0) --@TodayDateTime-DAY(@TodayDateTime)+1
			,DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime) +1, 0))--EOMONTH(@TodayDateTime)
			,@TodayDateTime
		FROM SE_CSS_Master

		-- 1 Sheet SRS_GRADE Start
		SELECT DISTINCT
			TSRS.CSS_ID
			,'SRS_GRADE' AS GRADE_TYPE 
			,TSRS.CssCode
			,TSRS.Percentage
			,TSRS.GradeID
			,TSRS.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpSafetyRatingScoreKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY SRK.CSSCode ORDER BY SRK.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,SRK.CSSCode
				,SRK.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.SafetyRatingScoreKPI SRK
			INNER JOIN dbo.SE_CSS_Master CSS
				ON SRK.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON SRK.KPI = G.GradeID
			) TSRS
		INNER JOIN dbo.SafetyRatingScoreKPI SRS
			ON TSRS.CSSCode = SRS.CSSCode 
			AND TSRS.RowNumber = 1

		UPDATE CG SET
			CG.SRS_GRADE = SR.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpSafetyRatingScoreKPI SR
			ON CG.CSS_ID = SR.CSS_ID
			AND SR.GRADE_TYPE = 'SRS_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpSafetyRatingScoreKPI

		--1 Sheet SRS_GRADE End

		-- 2 Sheet NSS_GRADE Start

		SELECT DISTINCT
			TCSN.CSS_ID
			,'NSS_GRADE' AS GRADE_TYPE 
			,TCSN.CssCode
			,TCSN.BusinessUnit
			,TCSN.Percentage
			,TCSN.GradeID
			,TCSN.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpCustomerSatisfactionScoreNSSKPI
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY TCSN.CSSCode ORDER BY TCSN.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,TCSN.CSSCode
				,TCSN.Percentage
				,TCSN.BusinessUnit
				,KPI AS GradeID
				,G.Grade
			FROM dbo.CustomerSatisfactionScoreNSSKPI TCSN
			INNER JOIN SE_CSS_Master CSS
				ON TCSN.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON TCSN.KPI = G.GradeID
			) TCSN
		INNER JOIN CustomerSatisfactionScoreNSSKPI SRS
			ON TCSN.CSSCode = SRS.CSSCode 
			AND TCSN.RowNumber = 1

		UPDATE CG SET
			CG.NSS_GRADE = TCSFS.Grade 
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpCustomerSatisfactionScoreNSSKPI TCSFS
			ON CG.CSS_ID = TCSFS.CSS_ID
			AND TCSFS.GRADE_TYPE = 'NSS_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,BusinessUnit
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpCustomerSatisfactionScoreNSSKPI

		--2 Sheet NSS_GRADE End

		--3 Sheet CSR_GRADE Start
	
		SELECT DISTINCT
			TCSRR.CSS_ID
			,'CSR_GRADE' AS GRADE_TYPE 
			,TCSRR.CssCode
			,TCSRR.BusinessUnit
			,TCSRR.Percentage
			,TCSRR.GradeID
			,TCSRR.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpCustomerSurveyResponseRateKPI
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY CSRR.CSSCode ORDER BY CSRR.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,CSRR.CSSCode
				,CSRR.Percentage
				,CSRR.BusinessUnit
				,CSRR.KPI AS GradeID
				,G.Grade
			FROM dbo.CustomerSurveyResponseRateKPI CSRR
			INNER JOIN SE_CSS_Master CSS
				ON CSRR.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON CSRR.KPI = G.GradeID
			) TCSRR
		INNER JOIN CustomerSurveyResponseRateKPI SRS
			ON TCSRR.CSSCode = SRS.CSSCode 
			AND TCSRR.RowNumber = 1

		UPDATE CG SET
			CG.CSR_GRADE = TCSRR.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpCustomerSurveyResponseRateKPI TCSRR
			ON CG.CSS_ID = TCSRR.CSS_ID
			AND TCSRR.GRADE_TYPE = 'CSR_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,BusinessUnit
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpCustomerSurveyResponseRateKPI

		--3 Sheet CSR_GRADE End

		--4 Sheet WOR Start

		SELECT DISTINCT
			TCSRR.CSS_ID
			,'WOR_GRADE' AS GRADE_TYPE 
			,TCSRR.CssCode
			,TCSRR.BusinessUnit
			,TCSRR.Percentage
			,TCSRR.GradeID
			,TCSRR.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpWork_Order_Response_KPI
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY WOR.CSSCode ORDER BY WOR.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,WOR.CSSCode
				,WOR.Category_BU AS BusinessUnit
				,WOR.AVGHoursMinutes AS Percentage
				,WOR.KPI AS GradeID
				,G.Grade
			FROM dbo.Work_Order_Response_KPI WOR
			INNER JOIN SE_CSS_Master CSS
				ON WOR.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON WOR.KPI = G.GradeID
			) TCSRR
		INNER JOIN Work_Order_Response_KPI SRS
			ON TCSRR.CSSCode = SRS.CSSCode 
			AND TCSRR.RowNumber = 1

		UPDATE CG SET
			CG.WOR_GRADE = TWOR.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpWork_Order_Response_KPI TWOR
			ON CG.CSS_ID = TWOR.CSS_ID
			AND TWOR.GRADE_TYPE = 'WOR_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,BusinessUnit
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpWork_Order_Response_KPI

		--4 Sheet WOR End

		--5 Sheet MTTR_GRADE Start

		SELECT DISTINCT
			TCSRR.CSS_ID
			,'MTTR_GRADE' AS GRADE_TYPE 
			,TCSRR.CssCode
			,TCSRR.CityClass
			,TCSRR.BusinessUnit
			,TCSRR.Percentage
			,TCSRR.GradeID
			,TCSRR.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpWork_order_MTTRv_KPI
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY MTTR.CSSCode ORDER BY MTTR.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,MTTR.CSSCode
				,MTTR.CityClass
				,MTTR.Category_BU AS BusinessUnit
				,MTTR.AVGDaysHoursMinutes AS Percentage
				,MTTR.KPI AS GradeID
				,G.Grade
			FROM dbo.Work_order_MTTRv_KPI MTTR
			INNER JOIN SE_CSS_Master CSS
				ON MTTR.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON MTTR.KPI = G.GradeID
			) TCSRR
		INNER JOIN Work_order_MTTRv_KPI SRS
			ON TCSRR.CSSCode = SRS.CSSCode 
			AND TCSRR.RowNumber = 1

		UPDATE CG SET
			CG.MTTR_GRADE = MTTR.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpWork_order_MTTRv_KPI MTTR
			ON CG.CSS_ID = MTTR.CSS_ID
			AND MTTR.GRADE_TYPE = 'MTTR_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,CityClass
			,BusinessUnit
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpWork_order_MTTRv_KPI

		--5 Sheet MTTR_GRADE End

		--6 Sheet PMC_GRADE End
		SELECT DISTINCT
			TPMC.CSS_ID
			,'PMC_GRADE' AS GRADE_TYPE 
			,TPMC.CssCode
			,TPMC.Percentage
			,TPMC.GradeID
			,TPMC.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpPreventiveMaintainanceComplianceCoolingKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY PMC.CSSCode ORDER BY PMC.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,PMC.CSSCode
				,PMC.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.PreventiveMaintainanceComplianceCoolingKPI PMC
			INNER JOIN dbo.SE_CSS_Master CSS
				ON PMC.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON PMC.KPI = G.GradeID
			) TPMC
		INNER JOIN dbo.PreventiveMaintainanceComplianceCoolingKPI SRS
			ON TPMC.CSSCode = SRS.CSSCode 
			AND TPMC.RowNumber = 1

		UPDATE CG SET
			CG.PMC_GRADE = TPMC.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpPreventiveMaintainanceComplianceCoolingKPI TPMC
			ON CG.CSS_ID = TPMC.CSS_ID
			AND TPMC.GRADE_TYPE = 'PMC_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpPreventiveMaintainanceComplianceCoolingKPI

		--6 Sheet PMC_GRADE End
	
		--7 Sheet DFR_HBN_GRADE End
		SELECT DISTINCT
			TPMC.CSS_ID
			,'DFR_HBN_GRADE' AS GRADE_TYPE 
			,TPMC.CssCode
			,TPMC.Percentage
			,TPMC.GradeID
			,TPMC.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpDefectiveReturnHBNKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY PMC.CSSCode ORDER BY PMC.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,PMC.CSSCode
				,PMC.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.DefectiveReturnHBNKPI PMC
			INNER JOIN dbo.SE_CSS_Master CSS
				ON PMC.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON PMC.KPI = G.GradeID
			) TPMC
		INNER JOIN dbo.DefectiveReturnHBNKPI SRS
			ON TPMC.CSSCode = SRS.CSSCode 
			AND TPMC.RowNumber = 1

		UPDATE CG SET
			CG.DFR_HBN_GRADE = TPMC.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpDefectiveReturnHBNKPI TPMC
			ON CG.CSS_ID = TPMC.CSS_ID
			AND TPMC.GRADE_TYPE = 'DFR_HBN_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpDefectiveReturnHBNKPI

		--7 Sheet PMC_GRADE End

		--8 Sheet DFR_PPI_GRADE Start
		SELECT DISTINCT
			TPMC.CSS_ID
			,'DFR_PPI_GRADE' AS GRADE_TYPE 
			,TPMC.CssCode
			,TPMC.BusinessUnit
			,TPMC.Percentage
			,TPMC.GradeID
			,TPMC.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpDefectiveReturnRatePPAndIKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY DFR.CSSCode ORDER BY DFR.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,DFR.CSSCode
				,DFR.BusinessUnit
				,DFR.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.DefectiveReturnRatePPAndIKPI DFR
			INNER JOIN dbo.SE_CSS_Master CSS
				ON DFR.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON DFR.KPI = G.GradeID
			) TPMC
		INNER JOIN dbo.DefectiveReturnRatePPAndIKPI SRS
			ON TPMC.CSSCode = SRS.CSSCode 
			AND TPMC.RowNumber = 1

		UPDATE CG SET
			CG.DFR_PPI_GRADE = TDFR.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpDefectiveReturnRatePPAndIKPI TDFR
			ON CG.CSS_ID = TDFR.CSS_ID
			AND TDFR.GRADE_TYPE = 'DFR_PPI_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,BusinessUnit
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpDefectiveReturnRatePPAndIKPI

		--8 Sheet DFR_PPI_GRADE End

		--9 Sheet NPF_GRADE End
		SELECT DISTINCT
			TNPF.CSS_ID
			,'NPF_GRADE' AS GRADE_TYPE 
			,TNPF.CssCode
			,TNPF.Percentage
			,TNPF.GradeID
			,TNPF.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpNPFHBNKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY NPF.CSSCode ORDER BY NPF.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,NPF.CSSCode
				,NPF.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.NPFHBNKPI NPF
			INNER JOIN dbo.SE_CSS_Master CSS
				ON NPF.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON NPF.KPI = G.GradeID
			) TNPF
		INNER JOIN dbo.NPFHBNKPI NPF
			ON TNPF.CSSCode = NPF.CSSCode 
			AND TNPF.RowNumber = 1

		UPDATE CG SET
			CG.NPF_GRADE = TNPF.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpNPFHBNKPI TNPF
			ON CG.CSS_ID = TNPF.CSS_ID
			AND TNPF.GRADE_TYPE = 'NPF_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpNPFHBNKPI
	
		--9 Sheet DFR_PPI_GRADE End
	
		--10 Sheet ATTR_GRADE End
		SELECT DISTINCT
			TA.CSS_ID
			,'ATTR_GRADE' AS GRADE_TYPE 
			,TA.CssCode
			,TA.Percentage
			,TA.GradeID
			,TA.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpAttritionKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY A.CSSCode ORDER BY A.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,A.CSSCode
				,A.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.AttritionKPI A
			INNER JOIN dbo.SE_CSS_Master CSS
				ON A.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON A.KPI = G.GradeID
			) TA
		INNER JOIN dbo.AttritionKPI A
			ON TA.CSSCode = A.CSSCode 
			AND TA.RowNumber = 1

		UPDATE CG SET
			CG.ATTR_GRADE = TA.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpAttritionKPI TA
			ON CG.CSS_ID = TA.CSS_ID
			AND TA.GRADE_TYPE = 'ATTR_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpAttritionKPI
	
		--10 Sheet ATTR_GRADE End

		--11 Sheet FRS_GRADE End
		SELECT DISTINCT
			TFSR.CSS_ID
			,'FRS_GRADE' AS GRADE_TYPE 
			,TFSR.CssCode
			,TFSR.Percentage
			,TFSR.GradeID
			,TFSR.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpFSRCompetencyKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY FSR.CSSCode ORDER BY FSR.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,FSR.CSSCode
				,FSR.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.FSRCompetencyKPI FSR
			INNER JOIN dbo.SE_CSS_Master CSS
				ON FSR.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON FSR.KPI = G.GradeID
			) TFSR
		INNER JOIN dbo.FSRCompetencyKPI FSR
			ON TFSR.CSSCode = FSR.CSSCode 
			AND TFSR.RowNumber = 1

		UPDATE CG SET
			CG.FRS_GRADE = TFSR.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpFSRCompetencyKPI TFSR
			ON CG.CSS_ID = TFSR.CSS_ID
			AND TFSR.GRADE_TYPE = 'FRS_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpFSRCompetencyKPI
	
		--11 Sheet FRS_GRADE End

		--12 Sheet LEAD_GRADE End
		SELECT DISTINCT
			TLG.CSS_ID
			,'LEAD_GRADE' AS GRADE_TYPE 
			,TLG.CssCode
			,TLG.Percentage
			,TLG.GradeID
			,TLG.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpLeadGenerationKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY LG.CSSCode ORDER BY LG.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,LG.CSSCode
				,LG.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.LeadGenerationKPI LG
			INNER JOIN dbo.SE_CSS_Master CSS
				ON LG.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON LG.KPI = G.GradeID
			) TLG
		INNER JOIN dbo.LeadGenerationKPI LG
			ON TLG.CSSCode = LG.CSSCode 
			AND TLG.RowNumber = 1

		UPDATE CG SET
			CG.LEAD_GRADE = TLG.Grade 
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpLeadGenerationKPI TLG
			ON CG.CSS_ID = TLG.CSS_ID
			AND TLG.GRADE_TYPE = 'LEAD_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpLeadGenerationKPI
	
		--12 Sheet LEAD_GRADE End

		--13 Sheet IB_GRADE End
		SELECT DISTINCT
			TIB.CSS_ID
			,'IB_GRADE' AS GRADE_TYPE 
			,TIB.CssCode
			,TIB.Percentage
			,TIB.GradeID
			,TIB.Grade
			,@TodayDateTime AS TodayDateTime
		INTO #tmpIBTrackingKPI 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY IB.CSSCode ORDER BY IB.KPI asc) RowNumber
				,CSS.Id AS CSS_ID
				,IB.CSSCode
				,IB.Percentage
				,KPI AS GradeID
				,G.Grade
			FROM dbo.IBTrackingKPI IB
			INNER JOIN dbo.SE_CSS_Master CSS
				ON IB.CssCode = CSS.CSS_Code
			LEFT JOIN Grade G
				ON IB.KPI = G.GradeID
			) TIB
		INNER JOIN dbo.IBTrackingKPI IB
			ON TIB.CSSCode = IB.CSSCode 
			AND TIB.RowNumber = 1

		UPDATE CG SET
			CG.IB_GRADE = IB.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpIBTrackingKPI IB
			ON CG.CSS_ID = IB.CSS_ID
			AND IB.GRADE_TYPE = 'IB_GRADE'

		INSERT INTO #tempSE_CSS_GRADATION_DETAIL
		(
			CSS_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADEID
			,GRADE
			,Updated_Date
		)
		SELECT
			CSS_ID
			,GRADE_TYPE
			,NULL
			,NULL
			,Percentage
			,GradeID
			,Grade
			,@TodayDateTime
		FROM #tmpIBTrackingKPI
	
		--13 Sheet IB_GRADE End

		--FINAL_GRADE Start 

		--SELECT 
		--	ThresHoldID	
		--	,CssCode	
		--	,CityClass	
		--	,BusinessUnit	
		--	,NoOfRecords	
		--	,GradationEligibility
		--	,CASE 
		--		WHEN GradationEligibility = 'No' THEN 0
		--		ELSE 1
		--	END AS IsGradationEligibility
		--INTO #tempThresHold
		--FROM dbo.ThresHold

		--SELECT 
		--	ROW_NUMBER() OVER (PARTITION BY CM.Id ORDER BY TH.IsGradationEligibility ASC) RowNumber
		--	,CM.Id AS CSS_ID
		--	,CM.CSS_Code
		--	,TH.IsGradationEligibility
		--INTO #tempThresHoldRowNumber
		--FROM #tempThresHold TH
		--INNER JOIN dbo.SE_CSS_MASTER CM
		--	ON TH.CssCode = CM.CSS_Code

		--UPDATE CG SET
		--	CG.GradationEligibility =  CASE WHEN THR.IsGradationEligibility = 0 THEN 'No' ELSE 'Yes' END
		--FROM #tempSE_CSS_GRADATION CG
		--INNER JOIN #tempThresHoldRowNumber THR
		--	ON CG.CSS_ID = THR.CSS_ID
		--	AND THR.RowNumber = 1

		SELECT DISTINCT
			TCG.CSS_ID
			,TCG.GRADEID
			,TCG.Grade
		INTO #tmpFinalGrade 
		FROM(
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY GD.CSS_ID ORDER BY GD.GRADEID ASC) RowNumber
				,GD.CSS_ID
				,GD.GRADEID
				,G.Grade
			FROM #tempSE_CSS_GRADATION_DETAIL GD
			LEFT JOIN Grade G
				ON GD.GRADEID = G.GradeID
			WHERE GD.GRADEID IS NOT NULL
			) TCG
		INNER JOIN #tempSE_CSS_GRADATION_DETAIL CG
			ON TCG.CSS_ID = TCG.CSS_ID 
			AND TCG.RowNumber = 1

		UPDATE CG SET
			CG.FINAL_GRADE =  FG.Grade
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN #tmpFinalGrade FG
			ON CG.CSS_ID = FG.CSS_ID

		--ThresHold Start
		UPDATE CG SET
			CG.GradationEligibility =  FG.GradationEligibility
		FROM #tempSE_CSS_GRADATION CG
		INNER JOIN SE_CSS_MASTER CM
			ON CG.CSS_ID = CM.Id
		INNER JOIN dbo.ThresHold FG
			ON CM.CSS_Code = FG.CssCode
		WHERE FG.UpdatedDateTime IS NULL

		--ThresHold End

		INSERT INTO  dbo.SE_CSS_GRADATION_DETAIL_AUDIT
		(
			Id,
			GRADATION_ID,
			GRADE_TYPE,
			CITY_CLASS,
			BUSINESS_UNIT,
			GRADE_SCORE,
			GRADE,
			Updated_User,
			Updated_Date,
			Audit_CreatedDateTime
		)
		SELECT
			Id,
			GRADATION_ID,
			GRADE_TYPE,
			CITY_CLASS,
			BUSINESS_UNIT,
			GRADE_SCORE,
			GRADE,
			Updated_User,
			Updated_Date,
			GETDATE()
		FROM dbo.SE_CSS_GRADATION_DETAIL
		where gradation_id in (Select id from se_Css_gradation
			where valid_From = DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime), 0) 
			and valid_till= DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime) +1, 0))
		)
		INSERT INTO dbo.SE_CSS_GRADATION_AUDIT
		(
			Id,
			CSS_ID,
			VALID_FROM,
			VALID_TILL,
			SRS_GRADE,
			NSS_GRADE,
			CSR_GRADE,
			WOR_GRADE,
			MTTR_GRADE,
			PMC_GRADE,
			DFR_HBN_GRADE,
			DFR_PPI_GRADE,
			NPF_GRADE,
			ATTR_GRADE,
			FRS_GRADE,
			LEAD_GRADE,
			IB_GRADE,
			FINAL_GRADE,
			Updated_User,
			Updated_Date,
			GradationEligibility,
			Audit_CreatedDateTime 
		)
		SELECT
			Id,
			CSS_ID,
			VALID_FROM,
			VALID_TILL,
			SRS_GRADE,
			NSS_GRADE,
			CSR_GRADE,
			WOR_GRADE,
			MTTR_GRADE,
			PMC_GRADE,
			DFR_HBN_GRADE,
			DFR_PPI_GRADE,
			NPF_GRADE,
			ATTR_GRADE,
			FRS_GRADE,
			LEAD_GRADE,
			IB_GRADE,
			FINAL_GRADE,
			Updated_User,
			Updated_Date,
			GradationEligibility,
			GETDATE()
		FROM SE_CSS_GRADATION
		where valid_From = DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime), 0) 
			and valid_till= DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime) +1, 0))


		DELETE FROM SE_CSS_GRADATION_DETAIL 
		where gradation_id in (Select id from se_Css_gradation
			where valid_From = DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime), 0) 
			and valid_till= DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime) +1, 0))
		)

		DELETE FROM SE_CSS_GRADATION where valid_From = DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime), 0) 
			and valid_till= DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @TodayDateTime) +1, 0))

		INSERT INTO SE_CSS_GRADATION
		(
			CSS_ID	
			,VALID_FROM	
			,VALID_TILL	
			,SRS_GRADE
			,NSS_GRADE	
			,CSR_GRADE	
			,WOR_GRADE	
			,MTTR_GRADE	
			,PMC_GRADE	
			,DFR_HBN_GRADE	
			,DFR_PPI_GRADE	
			,NPF_GRADE	
			,ATTR_GRADE	
			,FRS_GRADE	
			,LEAD_GRADE	
			,IB_GRADE	
			,FINAL_GRADE	
			,Updated_User	
			,Updated_Date
			,GradationEligibility
		)
		SELECT
			CSS_ID	
			,VALID_FROM	
			,VALID_TILL	
			,CASE WHEN SRS_GRADE IS NULL THEN '-1' ELSE SRS_GRADE END
			,CASE WHEN NSS_GRADE IS NULL THEN '-1' ELSE NSS_GRADE END 	
			,CASE WHEN CSR_GRADE IS NULL THEN '-1' ELSE CSR_GRADE END	
			,CASE WHEN WOR_GRADE IS NULL THEN '-1' ELSE WOR_GRADE END 	
			,CASE WHEN MTTR_GRADE IS NULL THEN '-1' ELSE MTTR_GRADE END 	
			,CASE WHEN PMC_GRADE IS NULL THEN '-1' ELSE PMC_GRADE END 	
			,CASE WHEN DFR_HBN_GRADE IS NULL THEN '-1' ELSE DFR_HBN_GRADE END 	
			,CASE WHEN DFR_PPI_GRADE IS NULL THEN '-1' ELSE DFR_PPI_GRADE END 	
			,CASE WHEN NPF_GRADE IS NULL THEN '-1' ELSE NPF_GRADE END 	
			,CASE WHEN ATTR_GRADE IS NULL THEN '-1' ELSE ATTR_GRADE END 	
			,CASE WHEN FRS_GRADE IS NULL THEN '-1' ELSE FRS_GRADE END 	
			,CASE WHEN LEAD_GRADE IS NULL THEN '-1' ELSE LEAD_GRADE END 	
			,CASE WHEN IB_GRADE IS NULL THEN '-1' ELSE IB_GRADE END 	
			,CASE WHEN FINAL_GRADE IS NULL THEN '-1' ELSE FINAL_GRADE END 	
			,0	
			,Updated_Date
			,GradationEligibility
		FROM #tempSE_CSS_GRADATION

		INSERT INTO SE_CSS_GRADATION_DETAIL
		(
			GRADATION_ID
			,GRADE_TYPE
			,CITY_CLASS
			,BUSINESS_UNIT
			,GRADE_SCORE
			,GRADE
			,Updated_User
			,Updated_Date
		)
		SELECT 
			CG.Id	
			,GRADE_TYPE	
			,CASE WHEN CITY_CLASS IS NULL THEN '-1' ELSE CITY_CLASS END
			,CASE WHEN BUSINESS_UNIT IS NULL THEN '-1' ELSE BUSINESS_UNIT END 
			,CASE WHEN GRADE_SCORE IS NULL THEN '-1' ELSE GRADE_SCORE END 	
			,CASE WHEN GRADE IS NULL THEN '-1' ELSE GRADE END 	
			,0	
			,TGD.Updated_Date
		FROM #tempSE_CSS_GRADATION_DETAIL TGD
		INNER JOIN SE_CSS_GRADATION CG
			ON TGD.CSS_ID = CG.CSS_ID
			AND CG.Updated_Date = @TodayDateTime

		--FINAL_GRADE End
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH

END
