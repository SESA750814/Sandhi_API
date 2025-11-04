  
CREATE procedure [dbo].[usp_CSSRaiseInvoice]  
 -- Add the parameters for the stored procedure here  
 @CSSId    bigint,  
 @MonthName   Varchar(100)  
AS  
begin transaction  
begin try  
--CSS_MGR_Approved = 5,CSS_MGR_Discrepancy = 6,,CSS_MGR_Approved_Discrepancy = 7,  
--PRF_Raised = 8,  
--PO_Waiting = 9,  
--Invoice_Raised = 10,Invoice_Validated = 11,Invoice_Rejected = 12,  
--GRN_Raised = 13,Invoice_Paid = 14,  
  
declare @taxPercentage  decimal = 18  
declare @cssMgrApproved int=5  
declare @prfRaised int=8  
declare @awaitingPO int=9  
Declare @PRFNo   bigint  
--************************* HBN and PPI  invoice generation************************  
select @PRFNo =right(PRF_No,CHARINDEX('-',reverse(PRF_No))-1) from se_css_invoice  
set @PRFNo = coalesce(@prfno,0)  
  
Insert into SE_CSS_Invoice (  
 [CSS_ID], [Month_Name] ,[INV_TYPE] ,[WO_BUSINESSUNIT],[WO_AMT],[WO_COUNT],[PRF_NO],[PRF_Gen_Date],[Status_Type],  
 [Updated_User],[Updated_Date],[Remarks])  
select a.CSS_Id,@MonthName,'All',a.WO_BusinessUnit,sum(Claim),count(a.id),   
b.css_code + '-' + convert(varchar(10),(year(getdate())%100)) + '-' + RIGHT('00000'+ cast((@PRFNo + (Row_Number() Over(order by a.css_id))) as Varchar(100)),5) as PRF_No,   
getdate() as PRF_Gen_Date, -99 as StatusType,'SYSTEM',getdate(),''    
from se_work_order a  
inner join SE_CSS_Master b on a.css_id = b.id   
where a.WO_BusinessUnit in ('HBN','PPI')  
and a.css_id = @CSSId  
and WO_Process_Status = @cssMgrApproved  
group by css_id, WO_BusinessUnit, b.css_Code   
  
  
INSERT INTO SE_CSS_INVOICE_DETAIL(INV_ID, AMC_WARRANTY_FLAG, INV_AMT, UPDATED_USER, UPDATED_DATE)  
SELECT   
 A.ID AS INV_ID, coalesce(B.AMC_WARRANTY_FLAG,''), SUM(CLAIM), 'SYSTEM',GETDATE()  
FROM  
 SE_CSS_INVOICE A  
 INNER JOIN SE_WORK_ORDER B ON A.CSS_ID = B.CSS_ID   
WHERE  
  a.css_Id = @CSSId and  
 STATUS_TYPE=-99 and b.WO_Process_Status = @cssMgrApproved  
GROUP BY A.ID, B.AMC_WARRANTY_FLAG  
  
  
--************************* HBN and PPI  invoice generation end************************  
--************************* Cooling labour invoice generation************************  
select @PRFNo =right(PRF_No,CHARINDEX('-',reverse(PRF_No))-1) from se_css_invoice where css_id = @CSSId  
  
set @PRFNo = coalesce(@prfno,0)  
  
Insert into SE_CSS_Invoice (  
 [CSS_ID],[Month_Name] ,[INV_TYPE] ,[WO_BUSINESSUNIT],[WO_AMT],[WO_COUNT],[PRF_NO],[PRF_Gen_Date],[Status_Type],  
 [Updated_User],[Updated_Date],[Remarks])  
select   
 a.CSS_Id,@MonthName,'Labour',a.WO_BusinessUnit,sum(LABOUR_COST),count(a.id),   
 b.css_code + '-' + convert(varchar(10),(year(getdate())%100)) + '-' + RIGHT('00000'+ cast((@PRFNo + (Row_Number() Over(order by a.css_id))) as Varchar(100)),5) as PRF_No,   
 getdate() as PRF_Gen_Date, -99 as StatusType,'SYSTEM',getdate(),''    
from   
 se_work_order a  
 inner join SE_CSS_Master b on a.css_id = b.id   
where   
 a.WO_BusinessUnit in ('Cooling') and coalesce(LABOUR_COST,0)>0  
 and WO_Process_Status= @cssMgrApproved and a.css_id = @CSSId  
group by a.css_id, WO_BusinessUnit, b.css_Code   
  
  
INSERT INTO SE_CSS_INVOICE_DETAIL(INV_ID, AMC_WARRANTY_FLAG, INV_AMT, UPDATED_USER, UPDATED_DATE)  
SELECT   
 A.ID AS INV_ID, Coalesce(B.AMC_WARRANTY_FLAG,''), SUM(LABOUR_COST), 'SYSTEM',GETDATE()  
FROM  
 SE_CSS_INVOICE A  
 INNER JOIN SE_WORK_ORDER B ON A.CSS_ID = B.CSS_ID   
WHERE  
 STATUS_TYPE=-99 and a.CSS_ID=@CSSId and b.WO_Process_Status=@cssMgrApproved  
 and a.inv_type='Labour' and a.WO_BUSINESSUNIT='Cooling'  
GROUP BY A.ID, B.AMC_WARRANTY_FLAG  
  
  
  
--************************* Cooling labour invoice generation ends************************  
--************************* Cooling SUPPLY invoice generation************************  
select right(PRF_No,CHARINDEX('-',reverse(PRF_No))-1) from se_css_invoice  
set @PRFNo = coalesce(@prfno,0)  
  
Insert into SE_CSS_Invoice (  
 [CSS_ID],[Month_Name],[INV_TYPE] ,[WO_BUSINESSUNIT],[WO_AMT],[WO_COUNT],  
 [PRF_NO],[PRF_Gen_Date],[Status_Type],  
 [Updated_User],[Updated_Date],[Remarks])  
select   
 a.CSS_Id,@MonthName,'Supply',a.WO_BusinessUnit,sum(SUPPLY_COST),count(a.id),     
 Case when coalesce(c.prf_no,'')='' then   
  b.css_code + '-' + convert(varchar(10),(year(getdate())%100)) + '-' + RIGHT('00000'+ cast((@PRFNo + (Row_Number() Over(order by a.css_id))) as Varchar(100)),5)  
 else  
  coalesce(c.prf_no,'')  
 end  
 as PRF_No,  
 getdate() as PRF_Gen_Date, -99 as StatusType,'SYSTEM',getdate(),''    
from   
 se_work_order a  
 inner join SE_CSS_Master b on a.css_id = b.id   
 left outer join   
  (  
   Select   
    prf_no, css_id   
   from   
    Se_Css_Invoice   
   where   
    status_type=-99 and WO_BUSINESSUNIT='Cooling' and INV_TYPE='Labour'  
    and month_name=@MonthName  
  ) c on a.css_id = c.css_id   
where   
 a.WO_BusinessUnit in ('Cooling') and coalesce(SUPPLY_COST,0)>0  
 and WO_Process_Status=@cssMgrApproved and a.css_id = @CSSId  
group by a.css_id, WO_BusinessUnit, b.css_Code ,coalesce(c.prf_no,'')  
  
  
INSERT INTO SE_CSS_INVOICE_DETAIL(INV_ID, AMC_WARRANTY_FLAG, INV_AMT, UPDATED_USER, UPDATED_DATE)  
SELECT   
 A.ID AS INV_ID, coalesce(B.AMC_WARRANTY_FLAG,''), SUM(SUPPLY_COST), 'SYSTEM',GETDATE()  
FROM  
 SE_CSS_INVOICE A  
 INNER JOIN SE_WORK_ORDER B ON A.CSS_ID = B.CSS_ID and b.WO_Process_Status=@cssMgrApproved  
WHERE  
 STATUS_TYPE=-99 and a.CSS_ID=@CSSId  
 and a.inv_type='Supply' and a.WO_BUSINESSUNIT='Cooling'  
GROUP BY A.ID, B.AMC_WARRANTY_FLAG  
  
   
  
--************************* Cooling SUPPLY invoice generation ends************************  
  
  
--************** RUN Gradation*****************  
update a  set    
 Base_Payout = WO_AMT * coalesce(b.base_payout_percentage,0)/100  
 ,INCENTIVE_AMT = (WO_AMT * coalesce(b.base_payout_percentage,0)/100) * coalesce(b.Incentive_Percentage,0)/100  
from se_Css_invoice a inner join SE_CSS_MASTER b on a.css_id = b.id where status_type=-99  
  
  
update a  set    
 Inv_Amt = BASE_PAYOUT + INCENTIVE_AMT  
 ,Tax_Amt = (BASE_PAYOUT + Incentive_Amt) * @taxPercentage/100  
from se_Css_invoice a inner join SE_CSS_MASTER b on a.css_id = b.id where status_type=-99  
  
update a  set    
 INC_TAX_AMT = INV_AMT+ TAX_AMT  
from se_Css_invoice a inner join SE_CSS_MASTER b on a.css_id = b.id where status_type=-99  
  
--************** RUN Gradation ENDS *****************  
--************************ Check open Purchase Order ***********************  
-- MonthName, cssId, statustype=-99  
exec usp_LinkInvoicePurchaseOrder @MonthName, @CSSId,-99  
--************************ Check open Purchase Order ends ***********************  
  
 --************************************* Insert into Notification Table **********************************************  
 -- if po_id exists for status_type =-99 then send a prf raised notification to css  
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
  month_name = @monthname and coalesce(po_id,-1)<>-1 and status_type=-99 and css_id = @CSSId  
  
 -- if po_id is null for status_type=-99 then send a notification to central user that this css needs PO for value  
 Insert into SE_Notification(Status_Type, Ref_No, Ref_Type, User_Type, Remarks, Action, Created_User, Created_Date, Expiry_Date, [Subject], Body,ToEmail)  
 select   
  @awaitingPO, @MonthName,'Awaiting PO', '1',  
  'PRF ' + Convert(Varchar(100),PRF_No) + ' for ' + CSS_Code + ' for the month of ' + @MonthName + ' for Amount ' + convert(Varchar(20),INV_AMT) + ' is awaiting PO.<br/>Invoice Breakup - ' + d.InvoiceDetail,  
  'Invoice','System',getdate(), dateadd(dd,5,getdate()),  
  'PRF AWAITING PURCHASE ORDER - '+ CSS_CODE,  
  'PRF ' + Convert(Varchar(100),PRF_No) + ' for ' + CSS_Code + ' for the month of ' + @MonthName + ' for Amount ' + convert(Varchar(20),INV_AMT) + ' is awaiting PO.<br/>Invoice Breakup - ' + d.InvoiceDetail,  
  c.username   
 from   
  SE_CSS_Invoice a  
  inner join SE_CSS_MASTER b on a.css_id = b.id   
  inner join (  
   SELECT   
      SS.inv_id,   
      stuff((SELECT ', ' + US.AMC_WARRANTY_FLAG + ':' + convert(Varchar(20),us.INV_AMT)   
    FROM SE_CSS_INVOICE_DETAIL US  
    WHERE US.INV_ID = SS.INV_ID  
    FOR XML PATH('')),1,1,'') as InvoiceDetail  
   FROM SE_CSS_INVOICE_DETAIL SS  
   GROUP BY SS.INV_ID   
  
  ) d on a.id = d.inv_id   
  inner join (  
   SELECT   
      SS.userType,   
      stuff((SELECT ', ' + US.username   
    FROM AspNetUsers US  
    WHERE US.UserType = SS.UserType  
    FOR XML PATH('')),1,1,'') as UserName  
   FROM aspnetusers SS  
   GROUP BY SS.usertype   
  ) c on 1=1 and c.usertype=1  
 where  
  month_name = @monthname and coalesce(po_id,-1)=-1 and status_type=-99 and css_id = @cssId   
 --************************************* Insert into Notification Table Ends**********************************************  
   
insert into SE_CSS_Invoice_Status (Inv_Id, Status_Type, Remarks, Attachment, Updated_User, Updated_date)  
select   
 id, @prfRaised,'','','SYSTEM',getdate() from SE_CSS_INVOICE  
where  
 status_type=-99 and css_id = @CSSId and coalesce(po_id,-1)<>-1   
union  
select   
 id, @awaitingPO,'','','SYSTEM',getdate() from SE_CSS_INVOICE  
where  
 status_type=-99 and css_id = @CSSId and coalesce(po_id,-1)=-1   
  
  
   
   
UPDATE A SET A.INV_ID = B.ID  , WO_Process_Status=case when coalesce(b.po_id,-1)<>-1 then @prfRaised else @awaitingPO end   
FROM SE_WORK_ORDER A INNER JOIN SE_CSS_INVOICE B ON A.CSS_ID = B.CSS_ID   
WHERE B.STATUS_TYPE=-99 AND A.WO_Process_Status=@cssMgrApproved and a.css_id = @CSSId and b.inv_type in ('All','Labour') and b.Month_Name= @MonthName
  
  
  
UPDATE A SET A.SUPPLY_INV_ID = B.ID  , WO_Process_Status=case when coalesce(b.po_id,-1)<>-1 then @prfRaised else @awaitingPO end   
FROM SE_WORK_ORDER A INNER JOIN SE_CSS_INVOICE B ON A.CSS_ID = B.CSS_ID   
WHERE B.STATUS_TYPE=-99 and a.css_id = @CSSId and b.inv_type in ('Supply') and WO_Process_Status in (@cssMgrApproved, @prfRaised, @awaitingPO)   
and coalesce(a.Supply_Cost,0) > 0 and b.Month_Name= @MonthName 
  
-- SET STATUS TO PRF_RAISED  
UPDATE SE_CSS_INVOICE SET Status_Type=@prfRaised WHERE STATUS_TYPE=-99 and css_Id = @CSSId and coalesce(po_id,-1)<>-1  
UPDATE SE_CSS_INVOICE SET Status_Type=@awaitingPO, PO_REQ_DATE=getdate() WHERE STATUS_TYPE=-99 and css_Id = @CSSId and coalesce(po_id,-1)=-1  
--************************ Check open Purchase Order ends ***********************  
  
  
  
 commit transaction  
  raiserror('****** usp_CSSRaiseInvoice Done Sucessfully*******', 10, 0)  
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
    
  raiserror('usp_CSSRaiseInvoice Failed and Roll Back', 11, 0)  
    RAISERROR (@ErrorMessage, -- Message text.    
               @ErrorSeverity, -- Severity.    
               @ErrorState -- State.    
               );    
end catch  
  
  
   