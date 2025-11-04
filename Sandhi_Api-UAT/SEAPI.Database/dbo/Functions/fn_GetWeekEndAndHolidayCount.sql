-- =============================================
-- Author		: Vinothkumar D
-- Create date	: 28-11-2021
-- Description	: Get sunday and holiday count
-- =============================================
CREATE FUNCTION [dbo].[fn_GetWeekEndAndHolidayCount]
(
	@pStartDate DATETIME,
	@pEndDate DATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @FromDate DATE,
			@HolidayCount INT = 0

	SET @FromDate = @pStartDate;
	WHILE (@FromDate <= @pEndDate)
	BEGIN
		IF((DATENAME(DW,@FromDate) = 'Sunday') OR EXISTS(SELECT Holiday FROM dbo.GradationHolidays WHERE Holiday = CONVERT(DATE,@FromDate) AND IsActive = 1))
		BEGIN
			SET @HolidayCount = @HolidayCount + 1;
		END
		SET @FromDate = DATEADD(DAY,1,@FromDate);
	END
	RETURN @HolidayCount

END
