-- =============================================
-- Author:		Vinothkumar D
-- Create date: 25-11-2021
-- Description: Get Business days
-- =============================================
-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ========================================================================
--select dbo.fn_GetDayAndHours('2021-11-27 03:39:14.017','2021-11-27 03:39:14.017')
CREATE FUNCTION [dbo].[fn_GetExcludeWeekEndAndHolidayMinutes]
(
	@pStartDate DATETIME, 
	@pEndDate DATETIME,
	@pHoliday VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @HolidayMinutes INT = 0,
			@Minutes VARCHAR(MAX)

	SET @HolidayMinutes = dbo.fn_GetWeekEndAndHolidayMinutes(@pStartDate,@pEndDate,@pHoliday);
	SET @Minutes = DATEDIFF(Minute,@pStartDate,@pEndDate) - @HolidayMinutes;
		
	RETURN @Minutes;
END
