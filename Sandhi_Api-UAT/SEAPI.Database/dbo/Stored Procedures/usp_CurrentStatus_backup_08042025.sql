  
CREATE procedure [dbo].[usp_CurrentStatus_backup_08042025]  
 @monthName  Varchar(100),  
 @businessUnit Varchar(max),  
 @cssIds   Varchar(max),  
 @gid   Varchar(max)  
AS  
BEGIN  
  
--declare @monthName  Varchar(100) ='August-2021'  
--declare @businessUnit Varchar(max)='HBN'  
--declare @cssIds   Varchar(max) ='25'  
--declare @gid   Varchar(max) ='ttt'  
declare @sql   varchar(max)  
--select * from se_css_master   
  
set @sql ='  
  
Insert into SE_CurrentStatus  
(  
 css_id, css_code, css_name, business_Unit, vendor_code, email_id,  
 MonthName, Inv_No, Inv_Date, WO_Count, Inv_Amt,Tax_Amt, Inc_Tax_Amt,  
 css_approved_date, css_mgr_approved_date, prf_gen_date, invoice_gen_date, fin_approved_date,   
 grn_gen_date, Invoice_Paid_date, gid, CREATED_DATE, Central_Approved_date   
)  
select   
 a.css_id,   
 css.css_code, css.css_Name_in_BFS_To_be_Referred as Css_Name, a.WO_BusinessUnit,  
 css.Vendor_Code, email_id,   
 a.month_name, coalesce(b.inv_no,'''') as InvoiceNumber, coalesce(b.inv_Date,getdate()) as Inv_Dt,  
 b.WO_COUNT, coalesce(b.INV_AMT,0),coalesce(b.Tax_amt,0), coalesce(b.inc_tax_amt,0),  
 min(case when css_Status = 1 then CSS_APPROVED_DATE else null end ) as CSS_Approved_Date,   
 min(case when css_mgr_Status=1 then Css_mgr_updateddate else null end) as CSS_Mgr_Approved_Date ,   
 min(b.prf_gen_Date) as PRF_Gen_Date,   
 min(b.inv_gen_Date) as Invoice_Gen_Date,  
 min(b.FIN_APPROVE_DATE) as Fin_Approved_Date,  
 min(b.grn_gen_Date) as GRN_Gen_Date,  
 min(b.inv_paid_Date) as Invoice_Paid_Date,''' +  @gid + ''', GETDATE(), min(a.Central_UpdatedDate)   
from   
 se_work_order a  
 inner join SE_CSS_Master css on a.css_id = css.id   
 inner join se_css_invoice b on a.css_id = b.css_id and a.inv_id = b.id   
where WO_Process_Status >=0  
and a.month_name = ''' + @monthName + '''  
and a.WO_BusinessUnit = ''' + @businessUnit + ''''  
--and wo_process_Status <14  
if(@cssIds !='')  
begin  
 set @sql = @sql + ' and a.css_id in (' + @cssIds + ')'  
end   
set @sql = @sql + ' group by a.css_id,   
 css.css_code, css.css_Name_in_BFS_To_be_Referred,  
 css.Vendor_Code, email_id, a.WO_BusinessUnit,  
 a.month_name, b.inv_no, b.inv_Date ,  
 b.WO_COUNT, b.INV_AMT  , b.tax_amt, b.inc_tax_amt  
union  
select   
 a.css_id,   
 css.css_code, css.css_Name_in_BFS_To_be_Referred as Css_Name, a.WO_BusinessUnit,  
 css.Vendor_Code, email_id,   
 a.month_name, coalesce(b.inv_no,'''') as InvoiceNumber, coalesce(b.inv_Date,getdate()) as Inv_Dt,  
 b.WO_COUNT, coalesce(b.INV_AMT,0),coalesce(b.Tax_amt,0), coalesce(b.inc_tax_amt,0),  
 min(case when css_Status = 1 then CSS_APPROVED_DATE else null end ) as CSS_Approved_Date,   
 min(case when css_mgr_Status=1 then Css_mgr_updateddate else null end) as CSS_Mgr_Approved_Date ,   
 min(b.prf_gen_Date) as PRF_Gen_Date,   
 min(b.inv_gen_Date) as Invoice_Gen_Date,  
 min(b.FIN_APPROVE_DATE) as Fin_Approved_Date,  
 min(b.grn_gen_Date) as GRN_Gen_Date,  
 min(b.inv_paid_Date) as Invoice_Paid_Date,''' +  @gid + ''', GETDATE(), min(a.Central_UpdatedDate)   
from   
 se_work_order a  
 inner join SE_CSS_Master css on a.css_id = css.id   
 inner join (Select month_name,min(Central_UpdatedDate) as CentralApprovedDate from Se_work_order group by month_name) Central on a.month_name=Central.month_name   
 left outer join SE_CSS_INVOICE b on a.css_id = b.css_id and a.inv_id = b.id   
 left outer join (Select css_id, month_name, id as inv_id from se_css_invoice where month_name='''+ @monthname + ''') d  
  on a.css_id = b.css_id   
where WO_Process_Status >=0   
and a.month_name = ''' + @monthName + '''  
and coalesce(d.inv_id,-1)=-1   
and a.WO_BusinessUnit = ''' + @businessUnit + ''''  
--and wo_process_Status <14  
if(@cssIds !='')  
begin  
 set @sql = @sql + ' and a.css_id in (' + @cssIds + ')'  
end   
set @sql = @sql + ' group by a.css_id,   
 css.css_code, css.css_Name_in_BFS_To_be_Referred,  
 css.Vendor_Code, email_id, a.WO_BusinessUnit,  
 a.month_name, b.inv_no, b.inv_Date ,  
 b.WO_COUNT, b.INV_AMT, b.tax_amt, b.inc_tax_amt'  
   
   
   
  
 exec(@sql)  
  
  
  
END  