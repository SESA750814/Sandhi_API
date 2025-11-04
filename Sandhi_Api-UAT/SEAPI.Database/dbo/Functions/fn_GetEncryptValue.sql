-- =============================================
-- Author:		Vinothkumar D
-- Create date: 25-11-2021
-- Description: Get Business days
-- =============================================
-- Modification Histories
-- *********************************************
-- Date           Modificationby                      Description
-- ====================================================================
-- 26-11-2021    Vinothkumar D                       Initial Release
-- ========================================================================
--select dbo.fn_GetEncryptValue('2021-11-27 03:39:14.017','2021-11-27 03:39:14.017')
CREATE FUNCTION [dbo].[fn_GetEncryptValue]
(
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	
	RETURN 'SEKGS';
END
