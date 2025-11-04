-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[usp_WorkOrderAutoApprovalReminders]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	exec usp_WorkOrderAutoApprovalReminder 1
	exec usp_WorkOrderAutoApprovalReminder 2
END
