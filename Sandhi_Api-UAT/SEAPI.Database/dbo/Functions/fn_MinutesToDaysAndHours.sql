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
-- select [dbo].[fn_MinutesToDaysAndHours](1440)
CREATE FUNCTION [dbo].[fn_MinutesToDaysAndHours] 
(
	@Minutes INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	-- 1440 minutes per day
	DECLARE @Days VARCHAR(MAX)
	DECLARE @Hours VARCHAR(MAX)

	SET @Days = CASE 
					WHEN LEN(@Minutes / 1440) = 1
					THEN '0' + (CAST(@Minutes / 1440 AS VARCHAR(MAX))) 
					ELSE CAST(@Minutes / 1440 AS VARCHAR(MAX))
				END

	-- modulo 1440
	SET @Hours = CASE 
					WHEN LEN((@Minutes % 1440) / 60) = 1
					THEN '0' + (CAST((@Minutes % 1440) / 60 AS VARCHAR(MAX))) 
					ELSE CAST((@Minutes % 1440) / 60 AS VARCHAR(MAX))
				END  

	RETURN CONCAT(@Days,':',@Hours)

END
