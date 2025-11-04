CREATE procedure [dbo].[usp_GetPreviousMonthWOCount]  
  
AS  
BEGIN  
 Select  
  a.month_name,a.TotalWOs, hbn.HBNCount, ppi.PPICount, Cooling.CoolingCount , loadeddate,  IIF(a.central_Status IS NULL, 0, a.central_Status) as central_Status   
 from  
  (  
   Select month_name, wo_year, wo_month,max(loaded_date) as LoadedDate,count(*) as TotalWOs, central_Status from SE_Work_Order group by month_name, wo_year, wo_month, central_Status  
  ) a  
  left outer join (  
   select month_name, WO_BusinessUnit, count(*) as HBNCount from se_work_order   
   where WO_BusinessUnit='HBN'  
   group by month_name, WO_BusinessUnit   
  ) HBN on a.Month_Name = hbn.Month_Name  
  left outer join (  
   select month_name, WO_BusinessUnit, count(*) as PPICount from se_work_order   
   where WO_BusinessUnit='PPI'  
   group by month_name, WO_BusinessUnit   
  ) PPI on a.Month_Name = PPI.Month_Name  
  left outer join (  
   select month_name, WO_BusinessUnit, count(*) as CoolingCount from se_work_order   
   where WO_BusinessUnit='Cooling'  
   group by month_name, WO_BusinessUnit   
  ) Cooling on a.Month_Name = Cooling.Month_Name  
 Order by wo_year, convert(int,wo_month )  
  
END  