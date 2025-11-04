-- execute usp_InvoicePaid 15,'central@se.com','PPI',76,83182,'', '2022/11/28';
CREATE PROCEDURE [dbo].[usp_InvoicePaid]
	-- Add the parameters for the stored procedure here
	@Status				int,
	@UserName			Varchar(max),
	@BusinessUnit		Varchar(100),
	@InvId				bigint,
	@CSSId				int,
	@Remarks			Varchar(max),
	@PaymentDate		DateTime
	
AS
begin transaction
begin try

declare @grnRaised int = 14
declare @invoicePaid int = 15

  -- *********************** Update Invoice  TABLE **********************
 if(@Status=@invoicePaid) -- INVOICE PAID
		begin
				Update 
					SE_CSS_Invoice
				set 
					Status_Type=@Status,
					Payment_Process_Date=GETDATE(),
					Remarks = @Remarks,
					Updated_User=@UserName,
					Updated_Date=getdate(),
					INV_PAID_Date=@PaymentDate --getdate()
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type = @grnRaised

				if @@ROWCOUNT>0
					begin
							insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type,  Remarks, Updated_User, Updated_Date)
							values (@InvId, @Status, @Remarks, @UserName, getdate())

 --*********************** Update Invoice  TABLE ENDS **********************  

 --*********************** Insert Notification TABLE **********************

							Insert into SE_Notification(Status_Type, Ref_No, Ref_Type,  css_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
							select distinct @invoicePaid,a.Month_Name + '- Invoice','',
							css_id,
							'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' for the month of ' + a.Month_Name + ' has been sent for payment.',
							'Invoice','System',getdate(), Dateadd(dd,5,getdate()),
							'INVOICE PAID',
							'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' for the month of ' + a.Month_Name + ' has been sent for payment.',
							B.Email_ID
							from
								SE_CSS_INVOICE a 
								inner join SE_CSS_MASTER b on a.css_id = b.id 
							where
								a.id = @InvId
					end
				else
					begin
							raiserror('****** Invalid Invoice data.*******', 11, 0)
					end
		end
	
  -- *********************** Insert Notification TABLE ENDS **********************
commit transaction
  raiserror('****** usp_InvoicePaid Done Sucessfully*******', 10, 0)
end try
begin catch
 DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
  
    SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  rollback transaction
  
  raiserror('usp_InvoicePaid Failed and Roll Back', 11, 0)
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
end catch
