-- =============================================
-- Author		:	Vinothkumar D
-- Create date	:	25-12-2021
-- Description	:	Get hours and minutes
-- =============================================
-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- =====================================================================
-- select [dbo].[fn_GetHoursAndMinutes]('2021-04-14 14:48:00','2021-04-15 11:23:00')
CREATE FUNCTION [dbo].[fn_GetHoursAndMinutes]
(
	@pStartDate DATETIME, 
	@pEndDate DATETIME,
	@pHoliday VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @HoursMinutes VARCHAR(MAX),
			@FromDate DATETIME,
			@ToDate DATETIME,
			@Minutes INT = 0,
			@FromDatePart INT

	SET @FromDate = @pStartDate;
	WHILE (CONVERT(DATE,@FromDate) <= CONVERT(DATE,@pEndDate))
	BEGIN

		SET @FromDatePart = DATEPART(HOUR,@FromDate);

		IF(@FromDatePart >= 18)
		BEGIN
			SET @FromDate = CAST(CONVERT(DATE,DATEADD(DAY, 1, @FromDate)) AS DATETIME)+CAST('09:00:00.000' AS DATETIME); 
		END
		IF(@FromDatePart >= 0 AND @FromDatePart < 9)
		BEGIN
			SET @FromDate = CAST(CONVERT(DATE, @FromDate) AS DATETIME)+CAST('09:00:00.000' AS DATETIME); 
		END
		--IF((DATENAME(DW,@FromDate) <> 'Sunday') AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.GradationHolidays WHERE Holiday = CONVERT(DATE,@FromDate) AND IsActive = 1))
		IF((DATENAME(DW,@FromDate) <> 'Sunday') AND @pHoliday NOT LIKE '%'+CAST(CONVERT(DATE, @FromDate) AS VARCHAR(100))+'%')
		BEGIN
			SET @ToDate = CAST(CONVERT(DATE, @FromDate) AS DATETIME)+CAST('18:00:00.000' AS DATETIME);
			IF(@pEndDate < @ToDate)
			BEGIN
				SET @ToDate = @pEndDate;
			END
			
			SET @Minutes = @Minutes + DATEDIFF(MINUTE,@FromDate,@ToDate);
		END
		
		SET @FromDate = CAST(CONVERT(DATE,DATEADD(DAY, 1, @FromDate)) AS DATETIME)+CAST('09:00:00.000' AS DATETIME); 
	END
	SET @HoursMinutes = [dbo].[fn_MinutesToHoursAndMinutes](@Minutes)
	RETURN @HoursMinutes
END

