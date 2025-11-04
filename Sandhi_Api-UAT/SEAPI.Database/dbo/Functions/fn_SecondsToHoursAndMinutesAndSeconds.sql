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
-- select fn_SecondsToHoursAndMinutesAndSeconds(12)

CREATE FUNCTION [dbo].[fn_SecondsToHoursAndMinutesAndSeconds]
(
	@pSeconds INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @HoursMinuteSeconds NVARCHAR(MAX)
    
	SET @HoursMinuteSeconds = RIGHT('0' + CAST(@pSeconds / 3600 AS VARCHAR),2) + ':' +
	RIGHT('0' + CAST((@pSeconds / 60) % 60 AS VARCHAR),2) + ':' +
	RIGHT('0' + CAST(@pSeconds % 60 AS VARCHAR),2)

  RETURN @HoursMinuteSeconds
END
