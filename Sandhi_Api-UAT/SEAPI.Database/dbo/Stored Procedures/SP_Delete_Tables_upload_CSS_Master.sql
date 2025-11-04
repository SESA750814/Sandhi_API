-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delete_Tables_upload_CSS_Master]
	
AS
BEGIN
	
delete from SE_CSS_GRADATION_DETAIL
delete from SE_CSS_GRADATION
delete from dbo.SE_Work_Order_Status
delete from SE_Work_Order
delete from SE_CSS_INVOICE_DETAIL
delete from SE_CSS_Invoice_Status
delete from dbo.SE_CSS_INVOICE
delete from SE_CSS_PURCHASE_ORDER


delete from SE_CurrentStatus
delete from SE_CSS_Invoice_Status
delete from SE_CSS_APPROVED_DATA
delete from SE_CSS_APPROVED_WORKORDER
delete from SE_Work_Order_Status
delete from SE_Notification

select * from  SE_CurrentStatus

--delete from SE_CSS_MASTER
--delete   from AspNetUsers where UserType = 2
--delete   from AspNetUsers where UserType = 3
--delete   from AspNetUsers where UserType = 4
--delete   from AspNetUsers where UserType = 5

-- exec sp_CreateCSSUser

--delete from aspnetusers where Email like 'Mayuri.Shankar@se.com'



END
