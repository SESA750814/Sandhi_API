CREATE procedure [dbo].[usp_WorkOrderAutoApproval]

AS
BEGIN

Declare @cssApproved int = 3
Declare @cssDiscrepancy int = 4
Declare @cssManagerApproved int = 5
Declare @cssManagerApproveDiscrepancy int =7

declare @interval int = 5
declare @monthName		varchar(100)
declare @businessunit	varchar(max)
declare	@cssId			bigint
declare @woId			varchar(max)
declare @woAmt			decimal(18,2)
declare @labourAmt		decimal(18,2)
declare @supplyAmt		decimal(18,2)
Declare @cssCode		varchar(max)
Declare @remarks		varchar(max)
--*******************************   CSS DISCREPANCY *******************************************
--DECLARE DISCR_CURSOR CURSOR FOR
--select 
--	month_name, WO_BusinessUnit, css_id, convert(Varchar(10),a.id) as WoId ,
--	css_cost, css_labour_Cost, css_supply_cost, b.css_code 
--from	
--	se_work_order a
--	inner join se_Css_master b on a.css_id = b.id 
--where 
--	coalesce(CSS_UpdatedDate, getdate()) < coalesce(CSS_Mgr_UpdatedDate,getdate()) and
--	dateadd(dd,@interval,css_updateddate) > getdate() and css_updateddate is not null
--	and WO_Process_Status in (@cssDiscrepancy)

--OPEN DISCR_CURSOR 
--FETCH next from DISCR_CURSOR INTO @monthName, @businessunit, @cssId, @woId, @woAmt, @labourAmt, @supplyAmt,@cssCode
--WHILE @@FETCH_STATUS=0
--BEGIN
--	set @remarks ='Auto Approval of Discrepancy WO -' + @woId + ' for CSS ' + @cssCode
--	EXEC usp_WorkOrderStatusUpdate @cssManagerApproveDiscrepancy,'AutoApproval',@businessunit, @monthName, @remarks,@woAmt,@woId,@cssId,'Auto Approval','Auto Approval','',@labourAmt, @supplyAmt 
--FETCH next from DISCR_CURSOR INTO @monthName, @businessunit, @cssId, @woId, @woAmt, @labourAmt, @supplyAmt,@cssCode
--END
--CLOSE DISCR_CURSOR
--DEALLOCATE DISCR_CURSOR
--*******************************   CSS DISCREPANCY ENDS*******************************************
--*******************************   CSS APPROVED *******************************************

declare @woMonth		varchar(10)
declare @woYear			varchar(10)
DECLARE APPROVE_CURSOR CURSOR FOR
select 
	distinct month_name, WO_BusinessUnit, css_id, css_code, WO_Month, WO_Year  
from 
	se_work_order a
	inner join se_Css_master b on a.css_id = b.id 
where 
	coalesce(CSS_UpdatedDate, getdate()) < coalesce(CSS_Mgr_UpdatedDate,getdate())	
	and dateadd(dd,@interval,css_updateddate) > getdate() and css_updateddate is not null
	and WO_Process_Status in (@cssApproved)
order by wo_year desc, wo_month desc 
OPEN APPROVE_CURSOR 
FETCH next from APPROVE_CURSOR INTO @monthName, @businessunit, @cssId,@cssCode, @woMonth, @woYear
WHILE @@FETCH_STATUS=0
BEGIN
	set @woId=''
	set @woAmt=-1
	set @labourAmt=-1
	set @supplyAmt=-1
	set @remarks ='Auto Approval of Work order for the month of ' + @monthName + ' for CSS ' + @cssCode
	EXEC usp_WorkOrderStatusUpdate @cssManagerApproved,'AutoApproval',@businessunit, @monthName, @remarks,@woAmt,@woId,@cssId,'Auto Approval','Auto Approval','',@labourAmt, @supplyAmt 
FETCH next from APPROVE_CURSOR INTO @monthName, @businessunit, @cssId,@cssCode, @woMonth, @woYear
END
CLOSE APPROVE_CURSOR
DEALLOCATE APPROVE_CURSOR
--*******************************   CSS APPROVED ENDS *******************************************


END
