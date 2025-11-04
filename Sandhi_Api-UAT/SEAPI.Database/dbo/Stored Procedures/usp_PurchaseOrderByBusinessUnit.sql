CREATE PROCEDURE [dbo].[usp_PurchaseOrderByBusinessUnit]
	@BusinessUnit varchar(max),
	@region			varchar(max) = null,
	@cssManagerUserId	varchar(max) = null,
	@finUserId			Varchar(max) = null,
	@grnUserId			Varchar(max) = null,
	@cssId				Varchar(max) = null    
AS
BEGIN
--exec usp_PurchaseOrderByBusinessUnit 'Cooling'
if @BusinessUnit='HBN'
Begin
	set @BusinessUnit='Secure Power_HBN'
End
if @BusinessUnit='Cooling'
Begin
	set @BusinessUnit='Secure Power_Cooling'
End
if @BusinessUnit='PPI'
Begin
	set @BusinessUnit='Power Products & Industry'
End
select
	b.css_Code, b.CSS_Name_as_per_Oracle_SAP as Css_Name, b.Business_Unit, b.region, 
	a.PO_No, a.PO_Date, a.HBN_WARRANTY_AMT, a.Available_HBN_WARRANTY_AMT, a.HBN_AMC_AMT, a.Available_HBN_AMC_AMT,
	a.LABOR_AMC_AMT, a.Available_LABOR_AMC_AMT, a.LABOR_WARRANTY_AMT, a.Available_LABOR_WARRANTY_AMT,
	a.SUPPLY_AMC_AMT, a.Available_SUPPLY_AMC_AMT, a.SUPPLY_WARRANTY_AMT, a.Available_SUPPLY_WARRANTY_AMT,
	a.BASIC_AMT as PPI_AMT, a.Available_Basic_AMT as Available_PPI_AMT
from SE_CSS_PURCHASE_ORDER a
inner join se_Css_master b on a.css_id = b.id 
where coalesce(valid_till, dateadd(dd,1,getdate())) > getdate()
	and b.region = case when coalesce(@region,'')='' then b.region else @region end 
	and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
	and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
	and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
	and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
	and b.Business_Unit like '%'+@BusinessUnit+'%'
END