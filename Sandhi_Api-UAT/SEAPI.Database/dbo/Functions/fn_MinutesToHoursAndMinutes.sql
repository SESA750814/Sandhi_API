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
-- select [dbo].[fn_MinutesToHoursAndMinutes](40)

CREATE FUNCTION [dbo].[fn_MinutesToHoursAndMinutes]
(
	@Minutes INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Hours NVARCHAR(MAX)
  
  SET @Hours = RIGHT('0' + CONVERT(VARCHAR,@Minutes / 60),2) + ':' + RIGHT('0' + CONVERT(VARCHAR,@Minutes % 60),2)

   -- SET @Hours = CASE WHEN @Minutes >= 60 THEN
   --  (SELECT
   --         CASE WHEN LEN(@Minutes/60) > 1
   --           THEN CAST((@Minutes/60) AS VARCHAR(MAX))
   --           ELSE '0' + CAST((@Minutes/60)AS VARCHAR(MAX))
   --         END
   --         +':'+
   --         CASE WHEN (@Minutes%60) > 0
   --          THEN CASE WHEN LEN(@Minutes%60) > 1
   --            THEN CAST((@Minutes%60) AS VARCHAR(MAX))
   --            ELSE '0' + CAST((@Minutes%60) AS VARCHAR(MAX))
   --         END
   --         ELSE '00'
   --   END)
   --  ELSE
   --   '00:' + CASE WHEN LEN(@Minutes%60) > 1 
			--	THEN CAST((@Minutes%60) AS VARCHAR(2)) 
			--	ELSE '0' + CAST((@Minutes%60) AS VARCHAR(2)) 
			--END 
   --  END
  RETURN @Hours
END
