-- =============================================
-- Author		: Vinothkumar D
-- Create date	: 25-11-2021
-- Description	: Get Business hours
-- =============================================
-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ========================================================================
--select dbo.fn_GetMinutesToBusinessHours(12)
CREATE FUNCTION [dbo].[fn_GetMinutesToBusinessHoursAndMinutes]
(
	@Minutes INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @TotalDays VARCHAR(MAX) = 0,
			@TotalHours VARCHAR(MAX) = 0,
			@TotalMinutes VARCHAR(MAX) = 0,
			@BusinessHours VARCHAR(MAX) = 0,
			@BusinessMinutes VARCHAR(MAX) = 0

	-- 1440 minutes per day
	SET @TotalDays = @Minutes / 1440;

	-- modulo 1440
	SET @TotalHours = (@Minutes % 1440) / 60;

	---- modulo 60
	SET @TotalMinutes = CASE 
							WHEN LEN(@Minutes % 60) = 1
							THEN '0' + CAST(@Minutes % 60 AS VARCHAR(MAX))
							ELSE CAST(@Minutes % 60 AS VARCHAR(MAX))
						END 

	SET @BusinessHours = CASE 
							WHEN LEN((@TotalDays * 9) + @TotalHours) = 1
							THEN '0' + (CAST((@TotalDays * 9) + @TotalHours AS VARCHAR(MAX))) 
							ELSE CAST((@TotalDays * 9) + @TotalHours AS VARCHAR(MAX))
						END

	RETURN CONCAT(@BusinessHours,':',@TotalMinutes)

END
