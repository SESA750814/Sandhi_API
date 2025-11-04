CREATE procedure [dbo].[usp_SEPurchaseOrderImport]  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 --SELECT 'PO'  
   
 --select * from SE_CSS_PURCHASE_ORDER  
 --select * from dbo.purchase_order_import   
 --alter table dbo.purchase_order_import add css_code   varchar(max) null  
 --update dbo.Purchase_Order_Import set css_code = 'DELC003' where Supplier_Name='MARUTI ENTERPRISES'  
 --update dbo.Purchase_Order_Import set css_code = 'BLRPI001' where Supplier_Name='PSK Power Controls'  
 --update dbo.Purchase_Order_Import set css_code = 'MUM026' where Supplier_Name='UNITED SOLUTIONS'  
 --update dbo.Purchase_Order_Import set css_code = 'DELC003' where Supplier_Name=''  
 declare @prfRaised  int = 8   
 declare @awaitingPO  int = 9   
  
   
 update a set a.status='InActive' , valid_till=dateadd(dd,-1,getdate()) from SE_CSS_PURCHASE_ORDER a 
 inner join SE_CSS_Master b on a.css_id = b.id  
 inner join dbo.Purchase_Order_Import c on c.css_Code = b.css_code   
  
 insert into SE_CSS_PURCHASE_ORDER  
 (  
  Css_Id, PO_No, Po_Date, HBN_WARRANTY_AMT, Available_HBN_WARRANTY_AMT,  
  HBN_AMC_AMT, Available_HBN_AMC_AMT,  
  LABOR_AMC_AMT, Available_LABOR_AMC_AMT,  
  SUPPLY_AMC_AMT, Available_SUPPLY_AMC_AMT,  
  LABOR_WARRANTY_AMT, Available_LABOR_WARRANTY_AMT,  
  SUPPLY_WARRANTY_AMT, Available_SUPPLY_WARRANTY_AMT,  
  BASIC_AMT, Available_Basic_AMT,  
  Valid_From,  
  Status, Updated_User, Updated_Date, Remarks  , Month_Name
 )  
 select   
  b.id as CSS_Id,  a.PO, getdate() as PO_Date  
  ,Case when isNumeric(a.HBN_WARRANTY)=1 then convert(decimal(18,2),a.HBN_WARRANTY) else 0 end  
  ,Case when isNumeric(a.HBN_WARRANTY)=1 then convert(decimal(18,2),a.HBN_WARRANTY) else 0 end  
  ,Case when isNumeric(a.HBN_AMC)=1 then convert(decimal(18,2),a.HBN_AMC) else 0 end  
  ,Case when isNumeric(a.HBN_AMC)=1 then convert(decimal(18,2),a.HBN_AMC) else 0 end   
  ,Case when isNumeric(a.AMC_LABOR)=1 then convert(decimal(18,2),a.AMC_LABOR) else 0 end  
  ,Case when isNumeric(a.AMC_LABOR)=1 then convert(decimal(18,2),a.AMC_LABOR) else 0 end  
  ,Case when isNumeric(a.AMC_SUPPLY)=1 then convert(decimal(18,2),a.AMC_SUPPLY) else 0 end  
  ,Case when isNumeric(a.AMC_SUPPLY)=1 then convert(decimal(18,2),a.AMC_SUPPLY) else 0 end  
  ,Case when isNumeric(a.WARRANTY_LABOR)=1 then convert(decimal(18,2),a.WARRANTY_LABOR) else 0 end  
  ,Case when isNumeric(a.WARRANTY_LABOR)=1 then convert(decimal(18,2),a.WARRANTY_LABOR) else 0 end  
  ,Case when isNumeric(a.WARRANTY_SUPPLY)=1 then convert(decimal(18,2),a.WARRANTY_SUPPLY) else 0 end  
  ,Case when isNumeric(a.WARRANTY_SUPPLY)=1 then convert(decimal(18,2),a.WARRANTY_SUPPLY) else 0 end  
  ,Case when isNumeric(a.Basic_Amount)=1 then convert(decimal(18,2),a.Basic_Amount) else 0 end  
  ,Case when isNumeric(a.Basic_Amount)=1 then convert(decimal(18,2),a.Basic_Amount) else 0 end  
  ,getdate()  
  , 'Active' as Status, 'System',Getdate(), '' as Remarks  ,
  a.Month_Name
 from [dbo].[Purchase_Order_Import] a inner join SE_CSS_Master b on a.CSS_Code=b.Css_Code   
  
  
  
 Declare @cssId   bigint  
 declare @monthName  Varchar(max)  
 Declare PO_CURSOR CURSOR FOR  
 SELECT DISTINCT b.id as CssId, c.Month_Name as MonthName from [dbo].[Purchase_Order_Import] a inner join SE_CSS_Master b on a.CSS_Code=b.Css_Code   
 inner join SE_CSS_INVOICE c on b.id = c.css_id and c.Status_Type=@awaitingPO and coalesce(c.po_id,-1)=-1  
 OPEN PO_CURSOR  
 FETCH NEXT FROM PO_CURSOR INTO @cssId, @monthName  
 WHILE @@FETCH_STATUS=0  
 BEGIN  
  exec usp_LinkInvoicePurchaseOrder @monthName, @cssId, @awaitingPO  
  
 --************************************* Update Status and Insert Notification **********************************************  
 -- if po_id exists for status_type =-99 then send a prf raised notification to css  
   
 update   
  a   
 set   
  a.WO_Process_Status = @prfRaised  
 from   
  se_work_order a   
  inner join se_css_invoice b on a.inv_id = b.id and a.css_id = b.css_id   
 where  
   b.month_name=@monthName 
   and coalesce(po_id,-1)<>-1 
   and status_type=@awaitingPO and b.css_id = @cssId  
  
 Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, css_id, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)  
 select   
  @prfRaised, @MonthName,'PRF', css_id,  
  'PRF ' + Convert(Varchar(100),PRF_No) + ' for the month of ' + @MonthName ' has been raised. Please raise an invoice for the same.',  
  'Invoice','System',getdate(), dateadd(dd,5,getdate()) ,  
  'SE PRF RAISED -' + @MonthName,  
  'PRF ' + Convert(Varchar(100),PRF_No) + ' for the month of ' + @MonthName ' has been raised. Please raise an invoice for the same.',  
  b.Email_ID  
 from   
  SE_CSS_Invoice a   
  inner join se_css_master b on a.css_id = b.id   
 where  
  month_name = @monthname and coalesce(po_id,-1)<>-1 and status_type=@awaitingPO and css_id = @CSSId  
  
   
 update SE_CSS_Invoice set Status_Type=@prfRaised  
 where  
  month_name = @monthname 
  and coalesce(po_id,-1)<>-1 
  and status_type=@awaitingPO and css_id = @CSSId  
 --************************************* Insert into Notification Table Ends**********************************************  
      
 FETCH NEXT FROM PO_CURSOR INTO @cssId, @monthName  
 END  
 CLOSE PO_CURSOR  
 DEALLOCATE PO_CURSOR  
  
  
  
  
END  