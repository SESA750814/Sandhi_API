-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : Add updateddattime in 14 tables 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_AlterGradationScript

CREATE PROCEDURE [dbo].[spSE_AlterGradationScript]
	
AS
BEGIN
	
	BEGIN TRY
		
		DECLARE @ErrorMessage VARCHAR(2000), @ProcedureName VARCHAR(2000)
		--1. Safety Rating Score
		if not exists (select 1 from syscolumns
		where id = object_id('SafetyRatingScore')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE SafetyRatingScore ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('SafetyRatingScore')
			and name = 'Id')
		begin
			ALTER TABLE SafetyRatingScore ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--2. Customer Satisfaction Score (NSS)
		if not exists (select 1 from syscolumns
		where id = object_id('CustomerSatisfactionScoreNSS')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE CustomerSatisfactionScoreNSS ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('CustomerSatisfactionScoreNSS')
			and name = 'Id')
		begin
			ALTER TABLE CustomerSatisfactionScoreNSS ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end
	
		--3. Customer Survey response rate
		if not exists (select 1 from syscolumns
		where id = object_id('CustomerSurveyResponseRate')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE CustomerSurveyResponseRate ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('CustomerSurveyResponseRate')
			and name = 'Id')
		begin
			ALTER TABLE CustomerSurveyResponseRate ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end
	
		--4. Work order response
		if not exists (select 1 from syscolumns
		where id = object_id('Work_Order_Response')
			and name = 'HoursMinutes')
		begin
			ALTER TABLE Work_Order_Response ADD HoursMinutes VARCHAR(20)
		end

		if not exists (select 1 from syscolumns
		where id = object_id('Work_Order_Response')
			and name = 'UpdateHoursMinutesDateTime')
		begin
			ALTER TABLE Work_Order_Response ADD UpdateHoursMinutesDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('Work_Order_Response')
			and name = 'TotalMinutes')
		begin
			ALTER TABLE Work_Order_Response ADD TotalMinutes VARCHAR(MAX)
		end

		if not exists (select 1 from syscolumns
		where id = object_id('Work_Order_Response')
			and name = 'Id')
		begin
			ALTER TABLE Work_Order_Response ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--5. Work order MTTRv
		if not exists (select 1 from syscolumns
		where id = object_id('Work_order_MTTRv')
			and name = 'DaysHoursMinutes')
		begin
			ALTER TABLE Work_order_MTTRv ADD DaysHoursMinutes VARCHAR(20)
		end

		if not exists (select 1 from syscolumns
		where id = object_id('Work_order_MTTRv')
			and name = 'UpdateDaysHoursMinutesDateTime')
		begin
			ALTER TABLE Work_order_MTTRv ADD UpdateDaysHoursMinutesDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('Work_order_MTTRv')
			and name = 'TotalMinutes')
		begin
			ALTER TABLE Work_order_MTTRv ADD TotalMinutes VARCHAR(MAX)
		end

		if not exists (select 1 from syscolumns
		where id = object_id('Work_order_MTTRv')
			and name = 'Id')
		begin
			ALTER TABLE Work_order_MTTRv ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end
	
		--6. Preventive Maintainance compliance % - Cooling
		if not exists (select 1 from syscolumns
		where id = object_id('PreventiveMaintainanceComplianceCooling')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE PreventiveMaintainanceComplianceCooling ADD UpdatePercentageDateTime DATETIME
		end
	
		if not exists (select 1 from syscolumns
		where id = object_id('PreventiveMaintainanceComplianceCooling')
			and name = 'Id')
		begin
			ALTER TABLE PreventiveMaintainanceComplianceCooling ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--7. Defective Return - HBN
		if not exists (select 1 from syscolumns
		where id = object_id('DefectiveReturnHBN')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE DefectiveReturnHBN ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('DefectiveReturnHBN')
			and name = 'Id')
		begin
			ALTER TABLE DefectiveReturnHBN ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--8. Defective return rate % - PP&I
		if not exists (select 1 from syscolumns
		where id = object_id('DefectiveReturnRatePPAndI')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE DefectiveReturnRatePPAndI ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('DefectiveReturnRatePPAndI')
			and name = 'Id')
		begin
			ALTER TABLE DefectiveReturnRatePPAndI ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--9. NPF - HBN
		if not exists (select 1 from syscolumns
		where id = object_id('NPFHBN')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE NPFHBN ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('NPFHBN')
			and name = 'Id')
		begin
			ALTER TABLE NPFHBN ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--10. Attrition
		if not exists (select 1 from syscolumns
		where id = object_id('Attrition')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE Attrition ADD UpdatePercentageDateTime DATETIME
		end
	
		if not exists (select 1 from syscolumns
		where id = object_id('Attrition')
			and name = 'Id')
		begin
			ALTER TABLE Attrition ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--11. FSR Competency
		if not exists (select 1 from syscolumns
		where id = object_id('FSRCompetency')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE FSRCompetency ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('FSRCompetency')
			and name = 'Id')
		begin
			ALTER TABLE FSRCompetency ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end

		--12. Lead Generation
		if not exists (select 1 from syscolumns
		where id = object_id('LeadGeneration')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE LeadGeneration ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('LeadGeneration')
			and name = 'Id')
		begin
			ALTER TABLE LeadGeneration ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end
	
		--13. IB Tracking
		if not exists (select 1 from syscolumns
		where id = object_id('IBTracking')
			and name = 'UpdatePercentageDateTime')
		begin
			ALTER TABLE IBTracking ADD UpdatePercentageDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('IBTracking')
			and name = 'Id')
		begin
			ALTER TABLE IBTracking ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end
	
		--14. Threshold Criteria_Final
		if not exists (select 1 from syscolumns
		where id = object_id('ThresHold')
			and name = 'UpdatedDateTime')
		begin
			ALTER TABLE ThresHold ADD UpdatedDateTime DATETIME
		end

		if not exists (select 1 from syscolumns
		where id = object_id('ThresHold')
			and name = 'Id')
		begin
			ALTER TABLE ThresHold ADD Id BIGINT PRIMARY KEY IDENTITY(1,1)
		end
	END TRY
	BEGIN CATCH
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(), 
			@ProcedureName = OBJECT_NAME(@@PROCID)

		EXEC [dbo].[spSE_PostErrorLogs] @ProcedureName, 'dbo',	@ErrorMessage, 0

	END CATCH
END
