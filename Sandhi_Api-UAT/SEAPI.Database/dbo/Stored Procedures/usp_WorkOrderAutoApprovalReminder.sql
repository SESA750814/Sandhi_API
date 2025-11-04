CREATE procedure [dbo].[usp_WorkOrderAutoApprovalReminder]
	@reminderNo		int
AS
BEGIN

Declare @cssApproved int = 3
Declare @cssDiscrepancy int = 4
Declare @cssManagerApproved int = 5
Declare @cssManagerApproveDiscrepancy int =7

declare @interval int = 2
declare @interval2 int = 4

declare @monthName		varchar(100)
declare	@cssId			bigint
declare @woId			varchar(max)

declare @reminder		Varchar(100)='REMINDER-1'
if(@reminderNo=2)
begin
	set @reminder='FINAL REMINDER'
	set @interval = 4
	set @interval2 = 5
end
--*******************************   CSS DISCREPANCY *******************************************
DECLARE DISCR_CURSOR CURSOR FOR
select 
	convert(Varchar(10),a.id) as WoId
from	
	se_work_order a
where 
	coalesce(CSS_UpdatedDate, getdate()) < coalesce(CSS_Mgr_UpdatedDate,getdate()) and
	dateadd(dd,@interval,css_updateddate) > getdate() and dateadd(dd,@interval2,css_updateddate) <= getdate() 
	and css_updateddate is not null
	and WO_Process_Status in (@cssDiscrepancy)

OPEN DISCR_CURSOR 
FETCH next from DISCR_CURSOR INTO @woId
WHILE @@FETCH_STATUS=0
BEGIN
Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
select 
	@cssDiscrepancy, Work_Order_Number,'Work Order', CSS_MGR_USER_ID,
	@reminder + '- Partner ' + CSS_Code + ' have raised a discrepency for ' + Work_Order_Number + '. With Reason-' + CSS_Reason + ' Reason Description-' + CSS_Reason_Desc + ' Remarks -' + CSS_Remark,
	'WODiscrepency','System',getdate(), dateadd(dd,5,getdate())	,
	@reminder + '- Work order Discrepency-' + CSS_Code,
	'Partner ' + CSS_Code + ' have raised a discrepency for ' + Work_Order_Number + '. With Reason-' + CSS_Reason + ' Reason Description-' + CSS_Reason_Desc + ' Remarks -' + CSS_Remark,
	c.UserName
from	
	SE_Work_Order a
	inner join Se_Css_Master b on a.css_id = b.id 
	inner join aspnetusers c on b.CSS_MGR_USER_ID=c.id 
where
	a.id in (@WOId)

FETCH next from DISCR_CURSOR INTO  @woId
END
CLOSE DISCR_CURSOR
DEALLOCATE DISCR_CURSOR
--*******************************   CSS DISCREPANCY ENDS*******************************************
--*******************************   CSS APPROVED *******************************************
Declare @woYear		varchar(10)
declare @woMonth	varchar(10)
DECLARE APPROVE_CURSOR CURSOR FOR
select 
	distinct month_name, css_id , WO_Year, WO_Month
from 
	se_work_order a
where 
	coalesce(CSS_UpdatedDate, getdate()) < coalesce(CSS_Mgr_UpdatedDate,getdate())	
	and dateadd(dd,@interval,css_updateddate) > getdate() and dateadd(dd,@interval2,css_updateddate) <= getdate() 
	and css_updateddate is not null
	and WO_Process_Status in (@cssApproved)
order by wo_year desc, wo_month desc 
OPEN APPROVE_CURSOR 
FETCH next from APPROVE_CURSOR INTO @monthName, @cssId, @woYear, @woMonth
WHILE @@FETCH_STATUS=0
BEGIN
	Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, user_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, Subject, Body, ToEmail)
	select distinct @cssApproved,@MonthName + '- Work Orders','',
		CSS_MGR_USER_ID,
		@reminder + '-The work orders for ' + b.CSS_Code + ' the month of ' + @MonthName + ' is available to be validated','WOList'
		,'System',getdate(), Dateadd(dd,5,getdate()),
		@reminder + '- Work order Validated-' + CSS_Code,
		'The work orders for ' + b.CSS_Code + ' the month of ' + @MonthName + ' is available to be validated',
		c.UserName
	from
		SE_Work_Order a 
		inner join SE_CSS_MASTER b on a.css_id = b.id 
	inner join aspnetusers c on b.CSS_MGR_USER_ID=c.id 
	where
		month_name = @MonthName and css_id = @CSSId
FETCH next from APPROVE_CURSOR INTO @monthName, @cssId, @woYear, @woMonth
END
CLOSE APPROVE_CURSOR
DEALLOCATE APPROVE_CURSOR
--*******************************   CSS APPROVED ENDS *******************************************


END
