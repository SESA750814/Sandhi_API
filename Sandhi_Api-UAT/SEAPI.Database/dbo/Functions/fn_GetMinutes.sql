-- =============================================
-- Author		:	Vinothkumar D
-- Create date	:	25-12-2021
-- Description	:	Get minutes
-- =============================================
-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- =====================================================================
-- select [dbo].[fn_GetMinutes]('2021-06-12 19:07:00.000','2021-06-13 20:32:00.000')
CREATE FUNCTION [dbo].[fn_GetMinutes]
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
			@Minutes INT =0,
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
		--IF((DATENAME(DW,@FromDate) <> 'Sunday') AND NOT EXISTS(SELECT Holiday FROM dbo.GradationHolidays WHERE Holiday = CONVERT(DATE,@FromDate) AND IsActive = 1))
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

	RETURN @Minutes
END

