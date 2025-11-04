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
CREATE FUNCTION [dbo].[fn_GetDaysAndHours]
(
	@pStartDate DATETIME, 
	@pEndDate DATETIME
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @HolidayMinutes INT = 0,
			@DayHours VARCHAR(MAX)

	SET @HolidayMinutes = dbo.fn_GetWeekEndAndHolidayCount(@pStartDate,@pEndDate) * 1440;
	SET @DayHours = dbo.fn_MinutesToDaysAndHours(DATEDIFF(Minute,@pStartDate,@pEndDate) - @HolidayMinutes);
		
	RETURN @DayHours;
END
