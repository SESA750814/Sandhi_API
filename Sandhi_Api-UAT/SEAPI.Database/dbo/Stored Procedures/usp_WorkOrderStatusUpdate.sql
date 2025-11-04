

-- =============================================
-- Author:		Mahesh, 2021-12-01
-- Create date: <Create Date,,>
-- Description:	Stored proc to update the status of the work order for Central Team
-- =============================================
CREATE procedure [dbo].[usp_WorkOrderStatusUpdate]
	-- Add the parameters for the stored procedure here
	@Status					int,
	@UserName				Varchar(max),
	@BusinessUnit			Varchar(100),
	@MonthName				Varchar(100),
	@Remarks				Varchar(max),
	@WoAmount				Decimal(18,2),
	@WOIds					Varchar(max),
	@CSSId					bigint,
	@Reason					Varchar(max),
	@ReasonDesc				Varchar(max),
	@Attachment				Varchar(max),	
	@LabourAmount			Decimal(18,2),
	@SupplyAmount			Decimal(18,2)
AS
begin transaction
begin try
	--update se_work_order set WO_Process_Status=0  where month_name='August-2021' and  WO_BusinessUnit='HBN' and css_id =80625
	--select * from se_work_order_Status where work_order_id in (Select id from se_work_order where month_name='August-2021' and  WO_BusinessUnit='HBN' and css_id =80625) order by id desc 
	--exec usp_workorderstatusupdate 2,'csshbn_18@se.com','HBN','August-2021','',-1,'',80625,'','','',-1,-1
	--select WO_Process_Status, * from se_work_order where month_name='August-2021' and  WO_BusinessUnit='HBN'  and css_id =80625
	--select * from se_work_order_Status where work_order_id in (Select id from se_work_order where month_name='August-2021' and  WO_BusinessUnit='HBN' and css_id =80625) order by id desc 
--	Declare 	@Status				int				= 0 
--Declare 	@UserName			Varchar(max)	='s@a.com'
--Declare 	@BusinessUnit		Varchar(100) ='PPI'
--Declare 	@MonthName			Varchar(100) ='November-2021'
--Declare 	@Remarks			Varchar(max) =''
--Declare 	@WoAmount			Decimal(18,2) =2500
--Declare 	@WOIds				Varchar(max) = '16038'
--Declare 	@CSSId				bigint	= -1
--Declare 	@Reason				Varchar(max) =''
--Declare 	@ReasonDesc			Varchar(max) =''
--Declare 	@Attachment			Varchar(max)	 =''
--Declare 	@LabourAmount			Decimal(18,2) =-1
--Declare 	@SupplyAmount			Decimal(18,2)=-1


--Central_Approved = 0,Central_Rejected = 1,
--CSS_Validated = 2, CSS_Approved = 3, CSS_Discrepancy = 4,
--CSS_MGR_Approved = 5,CSS_MGR_Discrepancy = 6,,CSS_MGR_Approved_Discrepancy = 7,
--PRF_Raised = 8,
--PO_Waiting = 9,
--Invoice_Raised = 10,Invoice_Validated = 11,
--GRN_Raised = 12,Invoice_Paid = 13,
Declare @imported int = -99
Declare @centralApproved int = 0
Declare @centralRejected int = 1
Declare @cssValidated int = 2
Declare @cssApproved int = 3
Declare @cssDiscrepancy int = 4
Declare @cssManagerApproved int = 5
Declare @cssManagerDiscrepancy int =6
Declare @cssManagerApproveDiscrepancy int =7


  -- *********************** Update WORK ORDER TABLE **********************
		declare @sql   Varchar(max)
		if(@Status=@centralApproved or @Status=@centralRejected) -- Central User
		begin
				Update 
					SE_Work_Order 
				set 
					Central_Status=case when @Status=@centralApproved then 1 else 0 end, 
					Central_UpdatedDate=getdate(), 
					Central_User=@UserName,
					WO_Process_Status=@Status
				where 
					Month_Name=@MonthName 
					--and WO_BusinessUnit=@BusinessUnit
					and WO_Process_Status=@imported

		end
		else if(@Status=@cssValidated or @Status=@cssDiscrepancy) -- CSS User 
		begin
				if(trim(@WOIds) <> '')
				begin
					set @sql = '
					Update 
						SE_Work_Order 
					set 
						CSS_Status=case when ' + convert(Varchar(100),@Status) + '<>' + convert(Varchar(10),@cssDiscrepancy) + ' then 1 else 0 end, 
						CSS_UpdatedDate=getdate(), 
						CSS_User=''' + @UserName + ''', 
						CSS_Remark=''' + @Remarks + ''', 
						CSS_Cost=' + Convert(Varchar(100),coalesce(@WoAmount,-1)) + ',
						CSS_Labour_COST = Case when Coalesce(' + Convert(Varchar(100),@LabourAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@LabourAmount,-1)) + ' else Labour_COST end,
						CSS_Supply_COST = Case when Coalesce(' + Convert(Varchar(100),@SupplyAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@SupplyAmount,-1)) + ' else Supply_COST end,
						Claim = Case when Coalesce(' + Convert(Varchar(100),@WoAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@WoAmount,-1)) + ' else claim end,
						Labour_COST = Case when Coalesce(' + Convert(Varchar(100),@LabourAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@LabourAmount,-1)) + ' else Labour_COST end,
						Supply_COST = Case when Coalesce(' + Convert(Varchar(100),@SupplyAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@SupplyAmount,-1)) + ' else Supply_COST end,
						WO_Process_Status=' + Convert(Varchar(100),@Status) + ',
						css_Reason=''' + @Reason + ''',
						css_Attachment=''' + @Attachment + ''',
						css_Reason_Desc=''' + @ReasonDesc + ''',
						CSS_Mgr_Status=0
					where 
						Month_Name=''' + @MonthName + '''
						and wo_businessunit=''' + @BusinessUnit + ''' 
						and WO_Process_Status in 
							(' + convert(Varchar(10),@centralApproved) + ',' + convert(Varchar(10),@cssManagerApproved) 
							+ ',' + convert(Varchar(10),@cssManagerDiscrepancy)  + ')  
						and css_id='+ convert(varchar(100),@cssId)
						set @sql =@sql + ' and Id in (' + @WOIds + ')'
						--print @sql
						exec(@sql)	
				end 
				else if (@Status=@cssValidated and trim(@WOIds)='')
				begin
					set @sql = '
					Update 
						SE_Work_Order 
					set 
						CSS_Status= 1, 
						CSS_UpdatedDate=getdate(), 
						CSS_User=''' + @UserName + ''', 
						CSS_Remark=''' + @Remarks + ''', 
						CSS_Cost= claim,
						CSS_Labour_COST =  Labour_COST ,
						CSS_Supply_COST = Supply_COST,
						WO_Process_Status=' + Convert(Varchar(100),@Status) + ',
						css_Reason=''Approve All'',
						css_Attachment='''',
						css_Reason_Desc='''',
						CSS_Mgr_Status=0
					where 
						Month_Name=''' + @MonthName + '''
						and wo_businessunit=''' + @BusinessUnit + ''' 
						and (coalesce(claim,0)>0 or Is_RepeatCall_NonMaterial=1)
						and WO_Process_Status in 
							(' + convert(Varchar(10),@centralApproved) + ',' + convert(Varchar(10),@cssManagerApproved)  + ')  
						and css_id='+ convert(varchar(100),@cssId)
						--print @sql
						exec(@sql)	
				end 				
				
		end
		else if(@status=@cssApproved) -- CSS User 
		begin
				set @sql = '
				Update 
					SE_Work_Order 
				set 
					CSS_Status=case when ' + convert(Varchar(100),@Status) + '=' + convert(Varchar(10),@cssApproved) + ' then 1 else 0 end, 
					CSS_Approved_Date=getdate(), 
					CSS_User=''' + @UserName + ''', 
					WO_Process_Status=' + Convert(Varchar(100),@Status) + ',
					CSS_Mgr_Status=0
				where 
					Month_Name=''' + @MonthName + '''
					and wo_businessunit=''' + @BusinessUnit + ''' 
					and WO_Process_Status in ('  +  convert(Varchar(10),@cssValidated) +','  +  convert(Varchar(10),@cssManagerApproveDiscrepancy) +')  
					and css_id='+ convert(varchar(100),@cssId)
				if(trim(@WOIds) <> '')
				begin
					set @sql =@sql + ' and Id in (' + @WOIds + ')'
				end 
				exec(@sql)			
				
		end
		else if(@Status=@cssManagerApproved) -- CSS Manager User 
		begin
				set @sql = '
				Update 
					SE_Work_Order 
				set 
					CSS_Mgr_Status=case when ' + convert(Varchar(100),@Status) + '=' + convert(varchar(10),@cssManagerApproved) + ' then 1 else 0 end, 
					CSS_Mgr_UpdatedDate=getdate(), 
					CSS_Mgr_User=''' + @UserName + ''', 
					CSS_Mgr_Remark=''' + @Remarks + ''', 
					css_Mgr_Reason=''' + @Reason + ''',
					css_Mgr_Attachment=''' + @Attachment + ''',
					css_Mgr_Reason_Desc=''' + @ReasonDesc + ''',
					WO_Process_Status=' + Convert(Varchar(100),@Status) + '
				where 
					Month_Name=''' + @MonthName + '''
					and wo_businessunit=''' + @BusinessUnit + ''' 
					and WO_Process_Status in (' + convert(varchar(10),@cssApproved) + ')  
					and css_id='+ convert(varchar(100),@cssId)
				if(trim(@WOIds) <> '')
				begin
					set @sql =@sql + 'and Id in (' + @WOIds + ')'
				end 
				exec(@sql)			
				

		end
		else if(@Status=@cssManagerApproveDiscrepancy or @status=@cssManagerDiscrepancy) -- CSS Manager User 
		begin
				set @sql = '
				Update 
					SE_Work_Order 
				set 
					CSS_Mgr_Status=case when ' + convert(Varchar(100),@Status) + '=' + convert(varchar(10),@cssManagerApproveDiscrepancy) + ' then 1 else 0 end, 
					CSS_Mgr_UpdatedDate=getdate(), 
					CSS_Mgr_User=''' + @UserName + ''', 
					CSS_Mgr_Remark=''' + @Remarks + ''', 
					CSS_Mgr_Cost=' + Convert(Varchar(100),coalesce(@WoAmount,-1)) + ',
					CSS_MGR_Labour_COST = Case when Coalesce(' + Convert(Varchar(100),@LabourAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@LabourAmount,-1)) + ' else Labour_COST end,
					CSS_MGR_Supply_COST = Case when Coalesce(' + Convert(Varchar(100),@SupplyAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@SupplyAmount,-1)) + ' else Supply_COST end,
					Claim = Case when Coalesce(' + convert(Varchar(100),@WoAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@WoAmount,-1)) + ' else claim end,
					Labour_COST = Case when Coalesce(' + Convert(Varchar(100),@LabourAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@LabourAmount,-1)) + ' else Labour_COST end,
					Supply_COST = Case when Coalesce(' + Convert(Varchar(100),@SupplyAmount) + ',-1)<>-1 then ' + Convert(Varchar(100),coalesce(@SupplyAmount,-1)) + ' else Supply_COST end,
					css_Mgr_Reason=''' + @Reason + ''',
					css_Mgr_Attachment=''' + @Attachment + ''',
					css_Mgr_Reason_Desc=''' + @ReasonDesc + ''',
					WO_Process_Status=' + Convert(Varchar(100),@Status) + '
				where 
					Month_Name=''' + @MonthName + '''
					and wo_businessunit=''' + @BusinessUnit + ''' 
					and WO_Process_Status in (' + convert(varchar(10),@cssApproved) + ',' + convert(varchar(10),@cssDiscrepancy) + ')  
					and css_id='+ convert(varchar(100),@cssId)
				if(trim(@WOIds) <> '')
				begin
					set @sql =@sql + 'and Id in (' + @WOIds + ')'
				end 
				exec(@sql)			
				

		end

		
  -- *********************** Update WORK ORDER TABLE ENDS **********************

  -- *********************** Insert WORK ORDER STATUS TABLE **********************
	-- TO-DO : need to check if the work order updated can be picked up in any other way.
		set @sql = 'insert into SE_Work_Order_Status (Work_Order_Id, Status_Type, Updated_User,  Updated_Date, Remarks, Reason, Attachment, Reason_Desc, WO_AMT, LABOUR_COST, SUPPLY_COST)'
		set @sql = @sql + ' Select id, ''' + convert(varchar(100),@Status) + ''', ''' +  @userName + ''',getdate(),''' + @Remarks + ''',''' + @Reason + ''',''' + @Attachment + ''',''' + @ReasonDesc + ''', ' 
		set @sql = @sql + '''' + convert(Varchar(100),@WoAmount) + ''',''' + convert(Varchar(100),@LabourAmount) +''',''' + convert(Varchar(100),@SupplyAmount) +''''
		--set @sql = @sql + ' from SE_Work_Order where Month_Name=''' + @MonthName + ''' and Wo_BusinessUnit=''' + @BusinessUnit + ''''
		set @sql = @sql + ' from SE_Work_Order where Month_Name=''' + @MonthName + ''''
		if(trim(@BusinessUnit)<>'')
		begin
			set @sql = @sql +  '  and Wo_BusinessUnit='''+@BusinessUnit+ ''''	
		end
		if(trim(@WOIds) <> '')
		begin
			set @sql = @sql +  ' and id in (' + @WOIds + ')'		
		end
		if(@cssId <> 0)
		begin		
			set @sql = @sql +  ' and css_id =' + convert(varchar(100),@cssId)
		end
		set @sql = @sql + ' and wo_process_Status=' + convert(Varchar(100),@Status) 
		exec (@sql)
  -- *********************** Insert WORK ORDER STATUS TABLE END **********************
  if(@Status=@cssManagerApproved)
  begin
	-- check if an invoice is already raised for this month, if so then the rest of the work orders will go to next months invoice.
	--Declare @invCount		int
	--Select @invCount = count(*) from SE_CSS_INVOICE where css_id=@CSSId and Month_Name=@MonthName
	--if(@invCount <=0)
	--begin
		exec dbo.usp_CSSRaiseInvoice @CSSId, @MonthName
	--end 
  end


  -- *********************** Insert Notification TABLE **********************
--Central_Approved = 0
-- Notification send to CSS 
-- Status=0, css_id = cssid, remarks='The Work order data for the month of @monthname is now available for you to validate',
-- Action='workorderlist'
if(@Status=@centralApproved)
begin
	Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, Css_Id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
	select 
		distinct @centralApproved,Month_Name + '- Work Orders','',css_id, 
		'The work orders for the month of ' + Month_Name + ' is available to be validated','WOList','System',getdate(), Dateadd(dd,5,getdate()),
		'SE WORK ORDERS -'+ Month_Name, 
		'The work orders for the month of ' + Month_Name + ' is available to be validated. Please login with your credentials and validate your work orders.',
		coalesce(b.Email_ID, b.contact_person_email_id, c.Email,'')
	from
		SE_Work_Order a
		inner join SE_CSS_Master b on a.css_id = b.id 
		left outer join (Select csscode, Email, row_number() over(partition by csscode order by id ) as RowNum from AspNetUsers) c on b.id = c.csscode and c.RowNum=1
	where
		WO_Process_Status = @Status
		and Month_Name=@MonthName
end
-- CSS_Approved = 3, CSS_Discrepancy = 4
-- Notification send to CSS Manager 
-- Status = 4, user_id=managerid picked from CSS, remarks="A discrepency has been raised by CSS [CSS_NAME] for work order [WO_NO].[CSS_REASON][CSS_REMARKS]
-- Action='worderorderdiscrepency' 
if(@Status=@cssDiscrepancy)
begin
Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
select 
	@cssDiscrepancy, Work_Order_Number,'Work Order', CSS_MGR_USER_ID,
	'Partner ' + CSS_Code + ' have raised a discrepency for ' + Work_Order_Number + '. With Reason-' + CSS_Reason + ' Reason Description-' + CSS_Reason_Desc + ' Remarks -' + CSS_Remark,
	'WODiscrepency','System',getdate(), dateadd(dd,5,getdate())	,
	'Work order Discrepency-' + CSS_Code,
	'Partner ' + CSS_Code + ' have raised a discrepency for ' + Work_Order_Number + '. With Reason-' + CSS_Reason + ' Reason Description-' + CSS_Reason_Desc + ' Remarks -' + CSS_Remark,
	c.UserName
from	
	SE_Work_Order a
	inner join Se_Css_Master b on a.css_id = b.id 
	inner join aspnetusers c on b.CSS_MGR_USER_ID=c.id 
where
	a.id in (@WOIds)
end 

-- Status = 3, user_id=managerid picked from CSS, remarks="[CSS_NAME] has approved work orders
-- Action='worderorderapproved'
if(@Status=@cssApproved)
begin
	Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
	select distinct @cssApproved,@MonthName + '- Work Orders','',
		CSS_MGR_USER_ID,'The work orders for ' + b.CSS_Code + ' the month of ' + @MonthName + ' is available to be validated','WOList'
		,'System',getdate(), Dateadd(dd,5,getdate()),
		'Work order Validated-' + CSS_Code,
		'The work orders for ' + b.CSS_Code + ' the month of ' + @MonthName + ' is available to be validated',
		c.UserName
	from
		SE_Work_Order a 
		inner join SE_CSS_MASTER b on a.css_id = b.id 
		inner join aspnetusers c on b.CSS_MGR_USER_ID=c.id 
	where
		month_name = @MonthName and css_id = @CSSId
end 

-- CSS_MGR_Approved = 5
-- Notification will be send to CSS with the PRF details to raise the 
-- Status=5, css_id = cssid, remarks='PRF_NO Raised for amount [Amount]. Please raise an invoice',
-- Action='invoice'
--?************ Status to be handled in CSSInvoiceGenerate procedure **********************

-- CSS_MGR_Discrepancy = 6,,CSS_MGR_Approved_Discrepancy = 7,
-- Notification send to CSS 
-- Status=6, css_id = cssid, remarks='Partner Manager raised a Discrepancy for [WO_NO].[CSS_MGR_REASON][CSS_MGR_REMARKS]',
-- Action='worderorderdiscrepency'
if(@Status=@cssManagerDiscrepancy)
begin
Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, css_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
select 
	@cssManagerDiscrepancy, Work_Order_Number,'Work Order', css_id,
	'Partner Manager have raised a discrepency for ' + Work_Order_Number + '. With Reason-' + CSS_Mgr_Reason + ' Reason Description-' + CSS_Mgr_Reason_Desc + ' Remarks -' + CSS_Mgr_Remark,
	'WODiscrepency','System',getdate(), dateadd(dd,5,getdate())	,
	'Work order Discrepency-' + Work_Order_Number,
	'Partner Manager have raised a discrepency for ' + Work_Order_Number + '. With Reason-' + CSS_Mgr_Reason + ' Reason Description-' + CSS_Mgr_Reason_Desc + ' Remarks -' + CSS_Mgr_Remark,
	 coalesce(b.Email_ID, b.contact_person_email_id, c.Email,'')
from	
	SE_Work_Order a 
	inner join se_Css_master b on a.css_id = b.id 
	left outer join (Select csscode, Email, row_number() over(partition by csscode order by id ) as RowNum from AspNetUsers) c on b.id = c.csscode and c.RowNum=1
where
	a.id in  (@WOIds)
end 
-- Status=6, css_id = cssid, remarks='Partner Manager approved the Discrepancy for [WO_NO].[CSS_MGR_REMARKS]',
-- Action='worderordervalidated'
if(@Status=@cssManagerApproveDiscrepancy)
begin
print 'INN CSS Manager approved disc '
print @WOIds
Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, css_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
select 
	@cssManagerApproveDiscrepancy, Work_Order_Number,'Work Order', css_id,
	'Partner Manager has approved the discrepency raised by you, for ' + Work_Order_Number + '. With  Remarks -' + CSS_Mgr_Remark,
	'WOList','System',getdate(), dateadd(dd,5,getdate()),
	'Work order Discrepency Approved-' + Work_Order_Number,
	'Partner Manager has approved the discrepency raised by you, for ' + Work_Order_Number + '. With  Remarks -' + CSS_Mgr_Remark,
	coalesce(b.Email_ID, b.contact_person_email_id, c.Email,'')
from	
	SE_Work_Order a 
	inner join Se_Css_master b on a.css_id = b.id 
	left outer join (Select csscode, Email, row_number() over(partition by csscode order by id ) as RowNum from AspNetUsers) c on b.id = c.csscode and c.RowNum=1
where
	a.id in (@WOIds)
end 
  -- *********************** Insert Notification TABLE ENDS **********************


 commit transaction
  raiserror('****** usp_WorkOrderStatusUpdate Done Sucessfully *******', 10, 0)
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
  
  raiserror('usp_WorkOrderStatusUpdate Failed and Roll Back', 11, 0)
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
end catch



