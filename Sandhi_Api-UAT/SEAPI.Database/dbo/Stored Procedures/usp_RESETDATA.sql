
CREATE procedure [dbo].[usp_RESETDATA]
AS
begin
delete from se_css_invoice_Status 
delete from se_css_invoice_detail
delete from se_work_order_Status 
delete from SE_Notification


select * from se_work_order

update se_Work_order set claim=actual_cost, labour_cost = ACTUAL_LABOUR_COST, SUPPLY_COST=ACTUAL_SUPPLY_COST, WO_Process_Status=-99,
Central_Status=null, Central_UpdatedDate=null, Central_User=null, 
css_status = null, CSS_UpdatedDate=null, css_user=null, css_remark=null, css_cost=null, css_mgr_status = null, css_mgr_user=null, CSS_Mgr_Remark=null, css_mgr_cost =null,
inv_id = null, user_id = null, SUPPLY_INV_ID=null, CSS_Reason=null, CSS_Reason_Desc=null, CSS_Attachment=null, CSS_Mgr_Reason=null, CSS_Mgr_Reason_Desc=null, 
CSS_Mgr_Attachment=null

delete from se_Css_invoice
delete from SE_CSS_PURCHASE_ORDER
truncate table SE_CSS_APPROVED_WORKORDER
delete from SE_CSS_APPROVED_DATA

truncate table SE_CurrentStatus

end
