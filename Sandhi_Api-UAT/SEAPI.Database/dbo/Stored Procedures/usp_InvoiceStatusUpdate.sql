CREATE procedure [dbo].[usp_InvoiceStatusUpdate]
	-- Add the parameters for the stored procedure here
	@Status				int,
	@UserName			Varchar(max),
	@BusinessUnit		Varchar(100),
	@InvId				bigint,
	@CSSId				int,
	@RefNo				Varchar(max),
	@RefDate			DateTime,
	@InvAmount			Decimal(18,2),
	@InvAttachment		Varchar(max),
	@Remarks			Varchar(max),
	@NoDueDate			DateTime,
	@PaymentDate		DateTime
	
AS
begin transaction
begin try
declare @prfRaised int = 8
Declare @awaitingPO int =9
declare @invoiceRaised int = 10
declare @invoiceValidated int = 11
declare @invoiceRejected int = 12
declare @grnClarification int = 13
declare @grnRaised int = 14
declare @invoicePaid int = 15

  -- *********************** Update Invoice  TABLE **********************
		declare @sql   Varchar(max)
		if(@Status=@awaitingPO) -- Generate NEW PO
		begin
				Update 
					SE_CSS_Invoice
				set 
					PO_Id= null,
					Remarks=@Remarks,
					Status_Type=@Status,
					Updated_User=@UserName,
					Updated_Date=getdate(),
					PO_REQ_DATE =getdate()
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type < @invoiceValidated -- once invoice validated cannot request new po
				insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type, Remarks, Updated_User, Updated_Date)
				values (@InvId, @Status, @Remarks, @UserName, getdate())
		end
		else if(@Status=@invoiceRaised) -- Invoice Raised, need to update invoice no, invoice date and invoice attachment 
		begin
				Update 
					SE_CSS_Invoice
				set 
					Inv_No = @RefNo,
					Inv_Date = @RefDate,
					INV_Attachment = @InvAttachment,
					--CSS_INV_AMT=@InvAmount,
					Status_Type=@Status,
					Remarks = @Remarks,
					Updated_User=@UserName,
					Updated_Date=getdate(),
					INV_GEN_Date=getdate()
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type in (@prfRaised, @invoiceRejected)
				insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type, Ref_no, Ref_Date, Ref_Amt, Remarks, Attachment, Updated_User, Updated_Date)
				values (@InvId, @Status, @RefNo, @RefDate, @InvAmount, @Remarks, @InvAttachment, @UserName, getdate())

		end
		else if(@Status=@invoiceValidated or @status=@invoiceRejected) -- Invoice Validated/Rejected - Update the Remarks and Status for the Invoice
		begin
				Update 
					SE_CSS_Invoice
				set 
					Status_Type=@Status,
					Remarks=@Remarks,
					Updated_User=@UserName,
					Updated_Date=getdate(),
					FIN_APPROVE_Date= Case when @status = @invoiceValidated then getdate() else null end
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type in (@invoiceRaised, @invoiceRejected)
				insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type,  Remarks, Updated_User, Updated_Date)
				values (@InvId, @Status,  @Remarks, @UserName, getdate())	
				
		end
		else if(@Status=@grnClarification) -- GRN clarification, clarification remarks
		begin
				Update 
					SE_CSS_Invoice
				set 
					Status_Type=@Status,
					Remarks = @Remarks,
					Updated_User=@UserName,
					Updated_Date=getdate()
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type = @invoiceValidated

				insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type, Ref_no, Ref_Date, Remarks, Updated_User, Updated_Date)
				values (@InvId, @Status, @RefNo, @RefDate, @Remarks, @UserName, getdate())
		END
		else if(@Status=@grnRaised) -- GRN Raised, need to GRN no, GRN date 
		begin
				Update 
					SE_CSS_Invoice
				set 
					GRN_NO = @RefNo,
					GRN_DATE = @RefDate,
					Status_Type=@Status,
					Updated_User=@UserName,
					Updated_Date=getdate(),
					GRN_GEN_Date=getdate()
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type in ( @invoiceValidated, @grnClarification)

				insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type, Ref_no, Ref_Date, Remarks, Updated_User, Updated_Date)
				values (@InvId, @Status, @RefNo, @RefDate, @Remarks, @UserName, getdate())
		END
		else if(@Status=@invoicePaid) -- INVOICE PAID
		begin
				Update 
					SE_CSS_Invoice
				set 
					Status_Type=@Status,
					Payment_Process_Date=GETDATE(),
					Remarks = @Remarks,
					Updated_User=@UserName,
					Updated_Date=getdate(),
					INV_PAID_Date=getdate()
				where 
					id = @InvId
					and CSS_ID = @CSSId
					and WO_BUSINESSUNIT = @BusinessUnit
					and status_type = @grnRaised
				insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type,  Remarks, Updated_User, Updated_Date)
				values (@InvId, @Status, @Remarks, @UserName, getdate())

		end

		
  -- *********************** Update Invoice  TABLE ENDS **********************  

  -- *********************** Insert Notification TABLE **********************
  --PO_Waiting = 8,
  -- Need notification send to Central User
	  if(@Status=@awaitingPO)
	  begin
	  		Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, User_Type, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
		select 
			@awaitingPO, a.Month_Name,'Awaiting PO', '1',
			'PRF ' + Convert(Varchar(100),PRF_No) + ' for ' + b.css_code +' for the month of ' + a.Month_Name + ' for Amount ' + convert(Varchar(20),a.INV_AMT) + ' is awaiting PO.',
			'Invoice','System',getdate(), dateadd(dd,5,getdate()),
			'PRF AWAITING PURCHASE ORDER - '+ CSS_CODE,
			'PRF ' + Convert(Varchar(100),PRF_No) + ' for ' + CSS_Code + ' for the month of ' + a.Month_Name + ' for Amount ' + convert(Varchar(20),INV_AMT) + ' is awaiting PO.',
			c.username 
		from	
			SE_CSS_Invoice a
			inner join SE_CSS_MASTER b on a.css_id = b.id 
			inner join (
				SELECT 
				   SS.userType, 
				   stuff((SELECT ', ' + US.username 
					FROM AspNetUsers US
					WHERE US.UserType = SS.UserType and US.EmailConfirmed=1
					FOR XML PATH('')),1,1,'') as UserName
				FROM aspnetusers SS
				GROUP BY SS.usertype 
			) c on 1=1 and c.usertype=1
		where
			a.id = @InvId
	  end
	--Invoice_Raised = 9,
	-- Notification send to Finance user
	if(@Status=@invoiceRaised)
	begin
		Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
		select distinct @invoiceRaised,a.Month_Name + '- Invoice','',
			INV_FIN_USER_ID
			,'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' has been raised by ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' is available to be validated',
			'Invoice','System',getdate(), Dateadd(dd,5,getdate()),
			'INVOICE AVAILABLE TO VALIDATE -' + b.css_Code,
			'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' has been raised by ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' is available to be validated',
			c.username 
		from
			SE_CSS_INVOICE a 
			inner join SE_CSS_MASTER b on a.css_id = b.id 
			inner join aspnetusers c on b.INV_FIN_USER_ID = c.id 
		where
			a.id = @InvId
	end 

	-- Invoice_Validated = 10
	-- Notification to be sent to SCM User to generate GRN
		if(@Status=@invoiceValidated)
		begin
			Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
			select distinct @invoiceValidated,a.Month_Name + '- Invoice','',
				GRN_USER_ID,'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' has been validated for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' and is available to be enter GRN',
				'Invoice','System',getdate(), Dateadd(dd,5,getdate()),
				'INVOICE AVAILABLE FOR GRN -' + b.css_Code,
				'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' has been raised by ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' is available to be validated',
				c.username 
			from
				SE_CSS_INVOICE a 
				inner join SE_CSS_MASTER b on a.css_id = b.id 
				inner join aspnetusers c on b.GRN_USER_ID = c.id 
			where
				a.id = @InvId
		end 

	-- Invoice_Rejected = 11,
	-- Notification to be sent to CSS Manager and CSS
		if(@Status=@invoiceRejected)
		begin
			Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, css_id, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
			select distinct @invoiceRejected,a.Month_Name + '- Invoice','',a.css_id,
				CSS_MGR_USER_ID,
				'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' has been rejected for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + '. ' + @Remarks,
				'Invoice','System',getdate(), Dateadd(dd,5,getdate()),
				'SE INVOICE REJECTED -' + inv_no,
				'The invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' has been rejected for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + '. ' + @Remarks,
				 c.username + ',' +coalesce(b.Email_ID,'s@a.com')  
			from
				SE_CSS_INVOICE a 
				inner join SE_CSS_MASTER b on a.css_id = b.id 
				inner join aspnetusers c on b.CSS_MGR_USER_ID = c.id 
			where
				a.id = @InvId
		end 
	--GRN Clarification = 12
	-- Notification sent to Finance team /Central Team
	if(@Status=@grnClarification)
		begin
			Insert into SE_Notification(Status_Type, Ref_No, Ref_Type,  user_id, User_type, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
			select distinct @grnRaised,a.Month_Name + '- Invoice','',
				INV_FIN_USER_ID,'1',
				'GRN, the invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' has some clarification needed Remarks:' + @Remarks + '.',
				'Invoice','System',getdate(), Dateadd(dd,5,getdate()),
				'Invoice Clarification - ' + inv_no,
				'GRN, the invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' has some clarification needed Remarks:' + @Remarks + '.',
				c.UserName + ',' + d.username 
			from
				SE_CSS_INVOICE a 
				inner join SE_CSS_MASTER b on a.css_id = b.id 
				inner join (
					SELECT 
					   SS.userType, 
					   stuff((SELECT ', ' + US.username 
						FROM AspNetUsers US
						WHERE US.UserType = SS.UserType and US.EmailConfirmed=1
						FOR XML PATH('')),1,1,'') as UserName
					FROM aspnetusers SS
					GROUP BY SS.usertype 
				) c on 1=1 and c.usertype=1
				inner join aspnetusers d on b.INV_FIN_USER_ID = d.id 
			where
				a.id = @InvId
		end 
	--GRN_Raised = 12
	-- Notification sent to Finance team 
	if(@Status=@grnRaised)
		begin
			Insert into SE_Notification(Status_Type, Ref_No, Ref_Type,  user_id, User_type, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)
			select distinct @grnRaised,a.Month_Name + '- Invoice','',
				INV_FIN_USER_ID,'1',
				'GRN for the invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' has been raised.',
				'Invoice','System',getdate(), Dateadd(dd,5,getdate()),
				'GRN RAISED - ' + inv_no,
				'GRN for the invoice ' + inv_no + ' dated ' + convert(varchar(20),INV_DATE, 103) + ' for ' + b.CSS_Code + ' for the month of ' + a.Month_Name + ' has been raised.',
				c.UserName + ',' + d.username 
			from
				SE_CSS_INVOICE a 
				inner join SE_CSS_MASTER b on a.css_id = b.id 
				inner join (
					SELECT 
					   SS.userType, 
					   stuff((SELECT ', ' + US.username 
						FROM AspNetUsers US
						WHERE US.UserType = SS.UserType and US.EmailConfirmed=1
						FOR XML PATH('')),1,1,'') as UserName
					FROM aspnetusers SS
					GROUP BY SS.usertype 
				) c on 1=1 and c.usertype=1
				inner join aspnetusers d on b.INV_FIN_USER_ID = d.id 
			where
				a.id = @InvId
		end 
	--Invoice_Paid = 13
	-- Notification sent to CSS about the payment
		if(@Status=@invoicePaid)
		begin
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

  -- *********************** Insert Notification TABLE ENDS **********************

commit transaction
  raiserror('****** usp_InvoiceStatusUpdate Done Sucessfully*******', 10, 0)
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
  
  raiserror('usp_InvoiceStatusUpdate Failed and Roll Back', 11, 0)
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
end catch



