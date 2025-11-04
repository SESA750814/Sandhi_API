CREATE procedure [dbo].[usp_LinkInvoicePurchaseOrder]    
 -- Add the parameters for the stored procedure here    
 @MonthName   Varchar(max),     
 @cssId    bigint,    
 @statusType   int    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
     
 --****************************************** HBN PURCHASE ORDER UPDATE ******************************    
 update a    
  set a.po_id = c.id  , a.PO_ASSIGN_DATE = GETDATE()   
 FROM     
  SE_CSS_INVOICE A     
  INNER JOIN SE_CSS_PURCHASE_ORDER C ON A.CSS_ID = C.CSS_ID AND coalesce(C.Valid_Till,dateadd(dd,2,getdate())) > GETDATE() AND c.STATUS='Active'    
  left outer JOIN (Select inv_id, inv_amt as AMC_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='AMC') amc ON A.ID = amc.INV_ID     
  left outer JOIN (Select inv_id, inv_amt as Warranty_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='WARRANTY') warranty ON A.ID = warranty.INV_ID       
 WHERE     
  A.WO_BUSINESSUNIT='HBN' AND A.Status_Type=@statusType AND A.Month_Name=@MonthName    
  AND A.CSS_ID = @CSSId    
  and coalesce(c.available_hbn_amc_amt,0) >= coalesce(amc.AMC_Amt,0)     
  and coalesce(c.available_hbn_warranty_Amt,0) >= coalesce(warranty.Warranty_Amt,0)    
     
 update c    
  set  c.available_hbn_amc_amt = coalesce(c.available_hbn_amc_amt,0)  - coalesce(amc.AMC_Amt,0) ,    
  c.available_hbn_warranty_Amt = coalesce(c.available_hbn_warranty_Amt,0) - coalesce(warranty.Warranty_Amt,0)    
 FROM     
  SE_CSS_INVOICE A     
  INNER JOIN SE_CSS_PURCHASE_ORDER C ON A.CSS_ID = C.CSS_ID AND coalesce(C.Valid_Till,dateadd(dd,2,getdate())) > GETDATE() AND c.STATUS='Active'    
  left outer JOIN (Select inv_id, inv_amt as AMC_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='AMC') amc ON A.ID = amc.INV_ID     
  left outer JOIN (Select inv_id, inv_amt as Warranty_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='WARRANTY') warranty ON A.ID = warranty.INV_ID       
 WHERE     
  A.WO_BUSINESSUNIT='HBN' AND A.Status_Type=@statusType AND  A.Month_Name=@MonthName    
  AND A.CSS_ID = @CSSId    
  and coalesce(c.available_hbn_amc_amt,0) >= coalesce(amc.AMC_Amt,0)     
  and coalesce(c.available_hbn_warranty_Amt,0) >= coalesce(warranty.Warranty_Amt,0)    
    
 --****************************************** HBN PURCHASE ORDER UPDATE ENDS******************************    
 --****************************************** PPI PURCHASE ORDER UPDATE ******************************    
  update     
   a     
  set     
   a.po_id = b.id    , a.PO_ASSIGN_DATE = GETDATE()
  from     
   se_Css_invoice a     
   left outer join se_Css_purchase_order b on a.css_id = b.css_id and coalesce(b.Valid_Till,dateadd(dd,2,getdate())) > getdate()  AND b.STATUS='Active'    
  where     
   A.WO_BUSINESSUNIT='PPI' AND A.Status_Type=@statusType AND  A.Month_Name=@MonthName  and b.Month_Name =@MonthName  
   AND A.CSS_ID = @CSSId AND coalesce(b.available_basic_amt,0) >= coalesce(a.inv_amt,0)     
    
  update     
   b     
  set     
   b.available_basic_amt = coalesce(b.available_basic_amt,0) - coalesce(a.inv_amt,0)     
  from     
   se_Css_invoice a     
   left outer join se_Css_purchase_order b on a.css_id = b.css_id and coalesce(b.Valid_Till,dateadd(dd,2,getdate())) > getdate()  AND b.STATUS='Active'    
  where     
   A.WO_BUSINESSUNIT='PPI' AND A.Status_Type=@statusType AND A.Month_Name=@MonthName  and b.Month_Name =@MonthName  
   AND A.CSS_ID = @CSSId AND coalesce(b.available_basic_amt,0) >= coalesce(a.inv_amt,0)     
    
 --****************************************** PPI PURCHASE ORDER UPDATE ENDS******************************    
 --****************************************** Cooling Labor PURCHASE ORDER UPDATE ******************************    
 update a    
  set a.po_id = c.id  , a.PO_ASSIGN_DATE = GETDATE()   
 FROM     
  SE_CSS_INVOICE A     
  INNER JOIN SE_CSS_PURCHASE_ORDER C ON A.CSS_ID = C.CSS_ID AND coalesce(C.Valid_Till,dateadd(dd,2,getdate())) > GETDATE() AND c.STATUS='Active'    
  left outer JOIN (Select inv_id, inv_amt as AMC_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='AMC') amc ON A.ID = amc.INV_ID     
  left outer JOIN (Select inv_id, inv_amt as Warranty_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='WARRANTY') warranty ON A.ID = warranty.INV_ID       
 WHERE     
  A.WO_BUSINESSUNIT='Cooling' AND A.Status_Type=@statusType AND A.Month_Name=@MonthName and a.INV_TYPE='Labour'     
  AND A.CSS_ID = @CSSId    
  and coalesce(c.available_labor_amc_amt,0) >= coalesce(amc.AMC_Amt,0)     
  and coalesce(c.available_labor_warranty_Amt,0) >= coalesce(warranty.Warranty_Amt,0)    
    
 update c    
  set c.available_labor_amc_amt = coalesce(c.available_labor_amc_amt,0) - coalesce(amc.AMC_Amt,0) ,    
  c.available_labor_warranty_Amt = coalesce(c.available_labor_warranty_Amt,0) - coalesce(warranty.Warranty_Amt,0)    
 FROM     
  SE_CSS_INVOICE A     
  INNER JOIN SE_CSS_PURCHASE_ORDER C ON A.CSS_ID = C.CSS_ID AND coalesce(C.Valid_Till,dateadd(dd,2,getdate())) > GETDATE() AND c.STATUS='Active'    
  left outer JOIN (Select inv_id, inv_amt as AMC_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='AMC') amc ON A.ID = amc.INV_ID     
  left outer JOIN (Select inv_id, inv_amt as Warranty_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='WARRANTY') warranty ON A.ID = warranty.INV_ID       
 WHERE     
  A.WO_BUSINESSUNIT='Cooling' AND A.Status_Type=@statusType AND A.Month_Name=@MonthName and a.INV_TYPE='Labour'     
  AND A.CSS_ID = @CSSId    
  and coalesce(c.available_labor_amc_amt,0) >= coalesce(amc.AMC_Amt,0)     
  and coalesce(c.available_labor_warranty_Amt,0) >= coalesce(warranty.Warranty_Amt,0)    
     
    
 --****************************************** Cooling Labor PURCHASE ORDER UPDATE ENDS******************************    
 --****************************************** Cooling Supply PURCHASE ORDER UPDATE ******************************    
 update a    
  set a.po_id = c.id     , a.PO_ASSIGN_DATE = GETDATE()
 FROM     
  SE_CSS_INVOICE A     
  INNER JOIN SE_CSS_PURCHASE_ORDER C ON A.CSS_ID = C.CSS_ID AND coalesce(C.Valid_Till,dateadd(dd,2,getdate())) > GETDATE() AND c.STATUS='Active'    
  left outer JOIN (Select inv_id, inv_amt as AMC_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='AMC') amc ON A.ID = amc.INV_ID     
  left outer JOIN (Select inv_id, inv_amt as Warranty_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='WARRANTY') warranty ON A.ID = warranty.INV_ID       
 WHERE     
  A.WO_BUSINESSUNIT='Cooling' AND A.Status_Type=@statusType AND A.Month_Name=@MonthName and a.INV_TYPE='Supply'     
  AND A.CSS_ID = @CSSId    
  and coalesce(c.available_Supply_amc_amt,0) >= coalesce(amc.AMC_Amt,0)     
  and coalesce(c.available_Supply_warranty_Amt,0) >= coalesce(warranty.Warranty_Amt,0)    
     
 update c    
  set c.available_Supply_amc_amt = coalesce(c.available_Supply_amc_amt,0) - coalesce(amc.AMC_Amt,0) ,    
  c.available_Supply_warranty_Amt = coalesce(c.available_Supply_warranty_Amt,0) - coalesce(warranty.Warranty_Amt,0)    
 FROM     
  SE_CSS_INVOICE A     
  INNER JOIN SE_CSS_PURCHASE_ORDER C ON A.CSS_ID = C.CSS_ID AND coalesce(C.Valid_Till,dateadd(dd,2,getdate())) > GETDATE() AND c.STATUS='Active'    
  left outer JOIN (Select inv_id, inv_amt as AMC_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='AMC') amc ON A.ID = amc.INV_ID     
  left outer JOIN (Select inv_id, inv_amt as Warranty_Amt from SE_CSS_INVOICE_DETAIL where AMC_WARRANTY_FLAG='WARRANTY') warranty ON A.ID = warranty.INV_ID       
 WHERE     
  A.WO_BUSINESSUNIT='Cooling' AND A.Status_Type=@statusType AND A.Month_Name=@MonthName and a.INV_TYPE='Supply'     
  AND A.CSS_ID = @CSSId    
  and coalesce(c.available_Supply_amc_amt,0) >= coalesce(amc.AMC_Amt,0)     
  and coalesce(c.available_Supply_warranty_Amt,0) >= coalesce(warranty.Warranty_Amt,0)    
     
    
 --****************************************** Cooling Supply PURCHASE ORDER UPDATE ENDS******************************    
END 