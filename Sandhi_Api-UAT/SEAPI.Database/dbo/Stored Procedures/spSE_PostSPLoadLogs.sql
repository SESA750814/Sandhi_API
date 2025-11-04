-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : insert sp load logs 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_PostSPLoadLogs

CREATE procedure [dbo].[spSE_PostSPLoadLogs]
(
	@ObjectName VARCHAR(1000),
	@StartDateTime DATETIME,
	@EndTime DATETIME,
	@TotalTime VARCHAR(100)
)
	
AS
BEGIN
	
	INSERT INTO dbo.SPLoadLogs
	(
		ObjectName,
		StartDateTime,
		EndTime,
		TotalTime 
	)
	VALUES
	(
		@ObjectName,
		@StartDateTime,
		@EndTime,
		@TotalTime
	)
END
