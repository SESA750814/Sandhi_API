-- =============================================
-- Author		: Vinothkumar D
-- Create date  : 26-11-2021
-- Description  : insert error logs 
-- =============================================

-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ====================================================================
-- EXEC spSE_PostErrorLogs

CREATE procedure [dbo].[spSE_PostErrorLogs]
(
	@ProcMethodName VARCHAR(1000),
	@AppType VARCHAR(1000),
	@ErrorMessage VARCHAR(1000),
	@Createdby BIGINT
)
	
AS
BEGIN
	
	INSERT INTO dbo.ErrorLogs
	(
		ProcMethodName,
		AppType,
		ErrorMessage,
		Createdby,
		CreatedDateTime
	)
	VALUES
	(
		@ProcMethodName,
		@AppType,
		@ErrorMessage,
		@Createdby,
		GETDATE()
	)
END
