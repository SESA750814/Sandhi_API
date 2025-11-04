-- =============================================
-- Author:		Vinothkumar D
-- Create date: 25-11-2021
-- Description: Get Holiday Minutes
-- =============================================
-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ========================================================================
--select dbo.fn_GetWeekEndAndHolidayMinutes('2021-07-19 11:12:00','2021-07-26 12:00:00')
CREATE FUNCTION [dbo].[fn_GetWeekEndAndHolidayMinutes]
(
	@pStartDate DATETIME, 
	@pEndDate DATETIME,
	@pHoliday VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @FromDate DATETIME,
			@ToDate DATETIME,
			@Minutes INT =0

	SET @FromDate = @pStartDate;
	WHILE (CONVERT(DATE,@FromDate) <= CONVERT(DATE,@pEndDate))
	BEGIN

		--IF((DATENAME(DW,@FromDate) = 'Sunday') OR EXISTS(SELECT Holiday FROM dbo.GradationHolidays WHERE Holiday = CONVERT(DATE,@FromDate) AND IsActive = 1))
		IF((DATENAME(DW,@FromDate) = 'Sunday') OR @pHoliday LIKE '%'+CAST(CONVERT(DATE, @FromDate) AS VARCHAR(100))+'%')
		BEGIN
			SET @FromDate = CAST(CONVERT(DATE, @FromDate) AS DATETIME)+CAST('00:00:00.000' AS DATETIME);
			SET @ToDate = CAST(CONVERT(DATE, DATEADD(Day, 1, @FromDate)) AS DATETIME)+CAST('00:00:00.000' AS DATETIME);
			IF(@pEndDate < @ToDate)
			BEGIN
				SET @ToDate = @pEndDate
			END
			
			SET @Minutes = @Minutes + DATEDIFF(MINUTE,@FromDate,@ToDate);
		END
		
		SET @FromDate = DATEADD(DAY, 1, @FromDate);
		END

	RETURN @Minutes;
END


