-- =============================================
-- Author:		Vinothkumar D
-- Create date: 25-12-2021
-- Description:	Minutes convert hours and minutes 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ========================================================================
-- select [dbo].[fn_MinutesToDaysAndHoursAndMinutes](1580)
CREATE FUNCTION [dbo].[fn_MinutesToDaysAndHoursAndMinutes] 
(
	@pMinutes INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	
	DECLARE @Days VARCHAR(MAX),
			@Hours VARCHAR(MAX),
			@Minutes VARCHAR(MAX)

	-- 1440 minutes per day
	SET @Days = RIGHT('0' + CAST(@pMinutes / 1440 AS VARCHAR(MAX)), 2)
					

	-- modulo 1440
	SET @Hours = RIGHT('0' + CAST((@pMinutes % 1440) / 60 AS VARCHAR(MAX)), 2)

	-- modulo 60
	SET @Minutes = RIGHT('0' + CAST(@pMinutes % 60 AS VARCHAR(MAX)), 2)

	RETURN CONCAT(@Days,':',@Hours,':',@Minutes)

END
