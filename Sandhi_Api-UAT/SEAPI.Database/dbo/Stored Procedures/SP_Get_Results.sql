-- =============================================
-- Author:		<muthukrishnan marimuthu>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[SP_Get_Results]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

--delete from RAW_DUMP_Expense

select Count(*) as RAW_DUMP_HBN_PSI_Cooling from RAW_DUMP_Expense 
select Count(*) as HBN_RAW_DUMP from HBN_RAW_DUMP
select Count(*) as HBN_Work_Order from HBN_Work_Order
select Count(*) as PSI_RAW_DUMP from PSI_RAW_DUMP
select Count(*) as PSI_Work_Order from PSI_Work_Order
select Count(*) as Cooling_RAW_DUMP from Cooling_RAW_DUMP
select Count(*) as Cooling_RAW_DUMP_Expense from RAW_DUMP_Cooling_Expense
select Count(*) as Cooling_Work_Order from Cooling_Work_Order
select Count(*) as Cooling_Expense from Cooling_Expense
select Count(*) as SE_Work_Order from SE_Work_Order

select distinct WO_Month from SE_Work_Order
select * from SE_Work_Order
select * from HBN_Work_Order
select * from PSI_Work_Order
select * from Cooling_Work_Order

--delete from SE_Work_Order
Select * from SE_Notification order by id desc

select * from RAW_DUMP_Expense where Work_Order_Work_Order_Number='WO-07460787'
select * from HBN_RAW_DUMP where Work_Order_Work_Order_Number='WO-07460789'--'WO-07460787'
select * from HBN_Work_Order where Work_Order_Number='WO-07460787'

select * from RAW_DUMP_Cooling_Expense where Work_Order_Work_Order_Number='WO-08873529'

select Work_Order_Work_Order_Number from RAW_DUMP_Expense group by Work_Order_Work_Order_Number having count(*) > 1

select * from HBN_Work_Order where Is_RepeatCall_NonMeterial = 1

select 
Cooling_Gas_Rate,
Cooling_Gas_Actual_Expenses,
Cooling_Supplies_Actual_Expenses,
Cooling_Labour_Cost,
Cooling_Supply_Cost,
Cooling_Total_Cost
from Cooling_Work_Order

select * from PSI_Work_Order where Product_Grouping like '%P7%'

select * from PSI_RAW_DUMP where Work_Order_Work_Order_Number like 'WO-08821122'

select * from PSI_Work_Order where Work_Order_Number like 'WO-08821122'

select * from PSI_Product_Category where Product like '150196_MAT04_ALEXA'

select Work_Order_Number, product, Product_Grouping,Distance_Slab,claim from PSI_Work_Order where Claim is null and Product is not null
and product not in (select Main_Installed_Product from PSI_Product_Category)


select * from PSI_Work_Order where claim is not null and Product_Grouping is null

select * from PSI_Work_Order where claim is  null and Product is null



 select * from PSI_Work_Order order by claim desc

 select Product_Grouping,distance_Slab,Actual_Expense_Converted,PayOut_Type,Work_Order_Type,Work_Performed from HBN_Work_Order
 where 
Product_Grouping = 'T-10'
 --payout_Type  like 'Easy' and 
-- Work_order_Type  like 'Preventive Maintenance'
-- payout_Type not like 'Easy' and Work_order_Type not like 'Preventive Maintenance'
--Actual_Expense_Converted > 40 and Actual_Expense_Converted < 100
 --Distance_Slab = 'DS-B'




--delete top(1) from  RAW_DUMP_HBN_PSI_Cooling where Work_Order_Number='WO-07460787'

-- Cooling
Begin
-- WO-08868908  WO-08873529  WO-08885631
select
    Work_Order_Number,
	Cooling_Mileage_Actual_Expenses,
	Cooling_Mileage_Work_Description,
	Cooling_Gas_Actual_Expenses,
	Cooling_Gas_Rate,
	Cooling_Gas_Work_Description,
	Cooling_Supplies_Actual_Expenses,
	Cooling_Supplies_Work_Description,
	Cooling_Labour_Cost,
	Cooling_Supply_Cost,
	Cooling_Total_Cost
from    
Cooling_Work_Order 
Where Work_Order_Number = 'WO-08868908'

Select Region, Service_Team, Work_Order_number,  Product, Product_Grouping, Distance_Slab,Work_Description_Map_Code,
Claim,
Gas_Rate,
Expense_Quantity,
Supplies_Repair_Charges,
Supply_Gas_Charges,
Labour_Charges,
Work_Description ,
Work_Order_Type
from Cooling_Expense 
where
 work_order_number like 'WO-08868908'
 order by Work_Order_number

 -- Compare HBN
 
Select 
WO.[Work_Order_Number] ,WODA.[Work_Order_Number] AS SE_Work_Order_Number ,
WO.IP_Serial_Number, WODA.IP_Serial_Number as SE_IP_SerialNumber,
WO.WO_Completed_Timestamp, WODA.WO_Completed_Timestamp as SE_WO_Completed_Timestamp,
WO.First_Assigned_DateTime, WODA.First_Assigned_DateTime as SE_First_Assigned_DateTime,
WO.[Case] ,          WODA.[Case] as SE_Case ,
WO.[Service_Team],
WO.PRODUCT_CATEGORY,
WO.Call_type,
WO.Product, WODA.Product as SE_Product,
WO.Payout_Type,      WODA.Payout_Type as SE_Payout_Type ,
WO.[Work_Order_Type],WODA.[Work_Order_Type]  as SE_Work_Order_Type ,
WO.Product_Grouping, WODA.PRODUCT_CATEGORY as SE_Product_Grouping,
WO.Distance_Slab,    WODA.Distance_Slab as SE_Distance_Slap,
WO.[Actual_Expense_converted],
WO.Claim ,			 WODA.Claim as SE_Claim,
WO.Work_Performed,    WODA.Work_Performed as SE_Work_Performed,
WO.Non_Billing_Reason, WODA.Non_Billing_Reason AS SE_Non_Billing_Reason,
WO.MaterialUsed 
--into TempWithRepeat
From 
 HBN_Work_Order WO
 Inner join 
  Arrived_HBN_Sep WODA
  ON
  WO.Work_Order_Number like WODA.Work_Order_Number 
 -- and WO.Claim  <> WODA.Claim


  Select 
WO.[Work_Order_Number] ,WODA.[Work_Order_Number] AS SE_Work_Order_Number ,
WO.IP_Serial_Number, WODA.IP_Serial_Number as SE_IP_SerialNumber,
WO.Product, WODA.Product as SE_Product,
WO.Payout_Type,      WODA.Payout_Type as SE_Payout_Type ,
WO.[Work_Order_Type],WODA.[Work_Order_Type]  as SE_Work_Order_Type ,
WO.Product_Grouping, WODA.PRODUCT_CATEGORY as SE_Product_Grouping,
WO.Distance_Slab,    WODA.Distance_Slab as SE_Distance_Slap,
WO.[Actual_Expense_converted],
WO.Claim ,			 WODA.Claim as Sandhi_Claim,
WO.WO_Completed_Timestamp, WODA.WO_Completed_Timestamp as SE_WO_Completed_Timestamp,
WO.First_Assigned_DateTime, WODA.First_Assigned_DateTime as SE_First_Assigned_DateTime,
WO.[Case] ,          WODA.[Case] as SE_Case ,
WO.[Service_Team],
WO.Product, WODA.Product as SE_Product,
WO.Payout_Type,      WODA.Payout_Type as SE_Payout_Type ,
WO.[Work_Order_Type],WODA.[Work_Order_Type]  as SE_Work_Order_Type ,
WO.Product_Grouping, WODA.PRODUCT_CATEGORY as SE_Product_Grouping,
WO.Distance_Slab,    WODA.Distance_Slab as SE_Distance_Slap,
WO.[Actual_Expense_converted],
WO.Claim ,			 WODA.Claim as SE_Claim,
WO.Work_Performed,    WODA.Work_Performed as SE_Work_Performed,
WO.Non_Billing_Reason, WODA.Non_Billing_Reason AS SE_Non_Billing_Reason,
WO.MaterialUsed 
--into TempWithRepeat
From 
 HBN_Work_Order WO
 Inner join 
  Sandhi_Derived WODA
  ON
  WO.Work_Order_Number like WODA.Work_Order_Number 
  and WO.Claim  = WODA.SANDHI
   --and WO.Claim != WODA.Claim
  --and WO.Claim is NULL  
  --and wo.Product_Grouping is not null
  --and WO.Payout_Type like 'LUMINOUS'
  --and SUBSTRING (WO.Product , 1, 1) like 'l'
 --and WO.Claim = 0
 --and Product_Grouping like '%T-10%'
  --order by IP_Serial_Number

 
 select Payout_Type, Actual_Expense_converted, Distance_Slab , PayOut_Type, Work_Order_Type, * from HBN_Work_Order where Work_Order_number like 'WO-09318644'

select  HDS.Distance_Slab
from HBN_Distance_Slab HDS, HBN_Work_Order
where HBN_Work_Order.Actual_Expense_converted <= HDS.Max_Range and HBN_Work_Order.Actual_Expense_converted >= HDS.Min_Range
and Trim(HBN_Work_Order.PayOut_Type) not like '%Easy%'
AND Trim(HBN_Work_Order.Work_Order_Type) not like '%Preventive Maintenance%' 
and HDS.PayOut_Type is null
and Work_Order_number like 'WO-09318644' order by HBN_Work_Order.Payout_Type desc

select * from HBN_Distance_Slab

select Work_order_number, Payout_Type, Product_Grouping, Actual_Expense_converted, Distance_Slab , IsMaterialUsed, MaterialUsed, PayOut_Type, Work_Order_Type, claim, * from HBN_Work_Order 

 select claim,Work_order_number, IP_Serial_Number, Payout_Type, Product_Grouping, Actual_Expense_converted, Distance_Slab , IsMaterialUsed,MaterialUsed, PayOut_Type, Work_Order_Type, claim, * from HBN_Work_Order 
 where Work_Order_number like 'WO-09311728'
 
 --'WO-09312918'

 --'WO-09308169'

  select claim, Work_order_number, IP_Serial_Number, Payout_Type, Product_Grouping, Actual_Expense_converted, Distance_Slab , IsMaterialUsed,MaterialUsed, PayOut_Type, Work_Order_Type, claim, * from HBN_Work_Order 
 where IP_Serial_Number like 'IS1147001310'


   select IsMaterialUsed, claim, Work_order_number, IP_Serial_Number, Payout_Type, Product_Grouping, Actual_Expense_converted, Distance_Slab , IsMaterialUsed,MaterialUsed, PayOut_Type, Work_Order_Type, claim, * from HBN_Work_Order 
 where Work_Order_number in ( select Work_Order_Number from HBN_RepeatCalls)

 select * from SE_Work_Order where Work_Order_number like 'WO-09308169'

   select calls, Work_order_number, IsMaterialUsed, IP_Serial_Number, Work_Order_Type, * 
   from HBN_RepeatCalls 
 where IP_Serial_Number like 'BQ1809003124'



 --'WO-08735915'
 
 --'WO-09293065'

 
 --'WO-08959198'

 --'WO-09268959'
 
 --'WO-09314315'
 
 --'WO-09268774'
 
 --'WO-09318644'

 select * from HBN_Product_category_List where Product like '%SRV3%'

select * from HBN_Rate_Card where PayOut_Type like 'Preventive Maintenance'

--'EASY'

Select 
WO.[Work_Order_Number] ,WODA.[Work_Order_Number] AS SE_Work_Order_Number ,
WO.Claim ,			 WODA.SANDHI as SANDHI_Claim,
WO.IP_Serial_Number, WODA.IP_Serial_Number as SE_IP_SerialNumber,
WO.WO_Completed_Timestamp, WODA.WO_Completed_Timestamp as SE_WO_Completed_Timestamp,
WO.First_Assigned_DateTime, WODA.First_Assigned_DateTime as SE_First_Assigned_DateTime,

WO.[Work_Order_Type],WODA.[Work_Order_Type]  as SE_Work_Order_Type ,

WO.Work_Performed,    WODA.Work_Performed as SE_Work_Performed,
WO.Non_Billing_Reason, WODA.Non_Billing_Reason AS SE_Non_Billing_Reason,
WO.MaterialUsed 
--into TempWithRepeat
From 
 HBN_Work_Order WO
 Inner join 
  Sandhi_Derived WODA
  ON
  WO.Work_Order_Number like WODA.Work_Order_Number 
  and WODA.Work_Order_Number in ( select Work_Order_Number from HBN_RepeatCalls)
  and WO.Claim != WODA.SANDHI

 
 -- Repeat Calls

 select Work_order_number, IP_Serial_Number, Calls, Date_Back_30_Days, * from HBN_RepeatCalls 
where IP_Serial_Number in (select IP_Serial_Number
from HBN_Work_Order
group by IP_Serial_Number)

select * from HBN_RepeatCalls where IP_Serial_Number = '241903506721'

select Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,First_Assigned_DateTime, IsMaterialUsed, Work_Order_Type, Work_Performed 
from HBN_Work_Order 
where IP_Serial_Number in
(select IP_Serial_Number
from HBN_Work_Order
group by IP_Serial_Number
having count(*) > 1) and IsMaterialUsed not like 1 order by IP_Serial_Number

select Work_order_number, IP_Serial_Number, First_Assigned_DateTime, Completed_On, WO_Completed_Timestamp from HBN_Work_Order where IP_Serial_Number like '241903506721'

select Work_order_number,IP_Serial_Number,First_Assigned_DateTime, WO_Completed_Timestamp,Calls,Date_Back_30_Days from HBN_RepeatCalls where IP_Serial_Number = '241903506721'

select * from Cooling_Work_Order where Service_Team like '%ucs%'
select * from Cooling_Rate_Card where CSS_Code like 'India FS South4 Cooling CSP UCS project & Service Bangalore'
--- Cooling Fix
  Select Work_Order_Number,
  Product_Grouping,
  Distance_Slab,
  Work_Detail_Type,
  Work_Description
  Work_Description_Map_Code,
  Work_Description_Mapped,
  Supply_Gas_Charges,
  Labour_Charges,
  Total_Claim,
  Claim,
  *  from Cooling_Expense where Work_Order_Number like 'WO-09753258'
  --'WO-09485179'


  Select Cooling_Total_Cost,
  Cooling_Labour_Cost,
  Cooling_Supply_Cost 
  from Cooling_Work_Order where Work_Order_Number like 'WO-09753258'

  update Cooling_Expense
  set Work_Description = NULL
  where Work_Order_Number like 'WO-09753258' and Work_Description_Map_Code = 'SVC'


  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [Work Order Number *]
,[Total Labour and Supply]
      ,[SE_Labour]
      ,[SE_Supply]
      ,[SE_Total]
      ,[SE_Remarks]
      ,[SE_Total_check]
      ,[SE_Labour_check]
      ,[SE_Supply_check]
      ,[Case *]
      ,[First Assigned DateTime]
      ,[Main Installed Product *]
      ,[IP Serial Number]
      ,[Product Grouping]
      ,[Work Order Type *]
      ,[Work Order Sub-Type *]
      ,[Completed On *]
      ,[Services Business Unit]
      ,[Work Order Reason]
      ,[Product]
      ,[Non Billing Reason *]
      ,[Is Billable]
      ,[Installed At Account *]
      ,[Street]
      ,[City]
      ,[Zip]
      ,[State]
      ,[Service Team]
      ,[Primary FSR *]
      ,[Partner Account]
      ,[Work Performed]
      ,[Work Order Status *]
      ,[Distance Slab]
      ,[Actual Expense Converted]
      ,[WO Completed Timestamp]
      ,[Claim Type]
      ,[Month]
      ,[Region]
      ,[Actual Expenses Mileage]
      ,[Cooling Mileage Work Description]
      ,[Actual Expenses Gas]
      ,[Cooling Gas Work Description]
      ,[Actual Expenses Supplies]
      ,[Cooling Supplies Work Description]
      ,[Labour]
      ,[Supply]
      ,[Remarks]
      
  FROM [SE_UAT].[dbo].[Cooling_Derived] where  [Work Order Number *] like 'WO-09745445'

 -- a.[Cooling_Mileage_Actual_Expenses]
	----,cast(a.[Cooling_Mileage_Actual_Expenses] as decimal(5,2))
	--,a.[Cooling_Gas_Actual_Expenses]
	----,cast(a.[Cooling_Gas_Actual_Expenses] as decimal(5,2)) 
	--,a.[Cooling_Supplies_Actual_Expenses]
	----,cast(a.[Cooling_Supplies_Actual_Expenses] as decimal(5,2)) 
	
	--,cast(a.[Cooling_Labour_Cost] as decimal(18,2))
	--,cast(a.[Cooling_Supply_Cost] as decimal(18,2))		
	
	--,a.[Claim_Type]				
	--,cast(a.[Cooling_Total_Cost] as decimal(18,2))	

  select A.[Work Order Number *]
  , A.[SE_Supply] as SE_Supply_Cost
    ,B.Supplies_Repair_Charges as Sandhi_Supply_Cost
  ,A.[SE_Labour]  as SE_Labour_Cost
    ,B.Labour_Charges as Sandhi_Labour_Cost
  ,A.[SE_Total] as SE_Total_Cost
  ,B.Total_Claim as Sandhi_Total_Cost
  ,B.Distance_Slab as Sandhi_Distance_Slab
  ,B.Product_Grouping as Sandhi_Product_Grouping
  ,B.Work_Description as Sandhi_Description
  ,B.Work_Detail_Type as Sandhi_Detail_Type
  ,* from Cooling_Derived A
  inner join 
  Cooling_Expense B
  on
  A.[SE_Total] not like B.Total_Claim
  and 
  A.[Work Order Number *] like B.Work_Order_Number

   select A.[Work Order Number *] as Work_Order_Number
  , A.[SE_Supply] as SE_Supply_Cost
    ,B.Cooling_Supply_Cost as Sandhi_Supply_Cost
  ,A.[SE_Labour]  as SE_Labour_Cost
    ,B.Cooling_Labour_Cost as Sandhi_Labour_Cost
  ,A.[SE_Total] as SE_Total_Cost
  ,B.Cooling_Total_Cost as Sandhi_Total_Cost
    from Cooling_Derived A
  inner join 
  Cooling_Work_Order B
  on
  A.[SE_Total] not like B.Cooling_Total_Cost
  and 
  A.[Work Order Number *] like B.Work_Order_Number

select * from Cooling_Rate_Card where CSS_Code like 'India FS North2 Cooling CSP S & S Computers_Jammu'
and Product_Grouping like 1 

select * from Cooling_Rate_Card where 
CSS_Code like 'India FS South4 Cooling CSP UCS project & Service Bangalore'
and Distance_Slab like 'DS-A'
select * from Cooling_Work_Order where Work_Order_Number like 'WO-09461634' 

  Select Work_Order_Number,Work_Description,
  Payout_Type, Work_Description,Product_Grouping,Product,Distance_Slab,Expense_Quantity, Gas_Rate,
  Is_Expenses_Mileage, Is_Expenses_Gas,Is_Expenses_Supplies_Repair, Work_Detail_Type,
  Work_Description_Map_Code,Work_Description_Mapped,Supply_Gas_Charges,Labour_Charges,
  Total_Claim,
  Claim,Service_Team,
  *  from Cooling_Expense where 
 --Service_Team like 'India FS South4 Cooling CSP UCS project & Service Bangalore'
 --and 
 Work_Order_Number like 'WO-09461634'

 select * from RAW_DUMP_Cooling_Expense






 update Cooling_Expense
 set Work_Description_Map_Code = NULL

 update Cooling_Expense
 set Work_Description = 'R134a'
 where  Work_Order_Number like 'WO-09825910' and Work_Description like 'R134'

 --'WO-09461634' -- PG issue
 --'WO-09187318'
 --'WO-09001570'
  --'WO-09824380'
  --'WO-09485179'
 -- 'QUNIF-CRAC'

 select * from Cooling_Distance_Slab

 select * from Cooling_Expense where Work_Detail_Type like 'Actual Expenses Mileage' and Expense_Quantity is null
  
  select A.[Work Order Number *]
  ,b.Payout_Type
  ,b.Product_Grouping
  ,b.Work_Description
  ,b.Work_Description_Map_Code
  ,b.Distance_Slab
  ,b.Expense_Quantity
  ,b.Work_Detail_Type
  ,b.Work_Order_Type
  ,b.Claim
  , A.[SE_Supply] as SE_Supply_Cost
    ,B.Supplies_Repair_Charges as Sandhi_Supply_Cost
  ,A.[SE_Labour]  as SE_Labour_Cost
    ,B.Labour_Charges as Sandhi_Labour_Cost
  ,A.[SE_Total] as SE_Total_Cost
  ,B.Total_Claim as Sandhi_Total_Cost
  ,B.Distance_Slab as Sandhi_Distance_Slab
  ,B.Product_Grouping as Sandhi_Product_Grouping
  ,B.Work_Description as Sandhi_Description
  ,B.Work_Detail_Type as Sandhi_Detail_Type
  ,* from Cooling_Derived A, Cooling_Expense B
 where A.[Service Team]  like  'India FS South4 Cooling CSP UCS project & Service Bangalore'
 and b.Product_Grouping = 1
and b.Payout_Type = 'PM Charges'

 select b.Payout_Type
  ,b.Product_Grouping
  ,b.Work_Description
  ,b.Work_Description_Map_Code
  ,b.Distance_Slab
  ,b.Work_Detail_Type
  ,b.Work_Order_Type
  ,b.Claim
  ,b.Labour_Charges
  ,b.Supplies_Repair_Charges
  ,b.Supply_Gas_Charges
  ,b.Total_Claim
  ,* from Cooling_Expense b
 where 
b.Service_Team like 'India FS South4 Cooling CSP UCS project & Service Bangalore'
and b.Payout_Type like 'PM Charges'
and b.Product_Grouping = 1  
and b.Distance_Slab like '%DS-A%'
--and 
--b.Work_Order_Number like 'WO-09095111'

  Select Cooling_Total_Cost,
  Cooling_Labour_Cost,
  Cooling_Supply_Cost 
  from Cooling_Work_Order where Work_Order_Number like 'WO-09824380'



  
  Select 
  Work_Order_Number,
  Work_Description,
  Product_Grouping,
  Work_Detail_Type,
  Work_Description_Map_Code,
  Work_Description_Mapped,
  Supply_Gas_Charges,
  Labour_Charges,
  Total_Claim,
  Claim,* from Cooling_Expense where Is_Expenses_Gas = 1

  select  * from RAW_DUMP_Cooling_Expense

   select * from Cooling_Expense
  
  select * from Cooling_Rate_Card where Work_Description like 'LRC'
  and Distance_Slab like 'DS-A' and Product_Grouping like '6'
  --and CSS_Code like '%India FS West1 Cooling CSP Unique India Mumbai%'
  and Region like 'East'

    select * from Cooling_Rate_Card where Work_Description like 'SVC'
  and Distance_Slab like 'DS-A' and Product_Grouping like '6'
  --and CSS_Code like '%India FS West1 Cooling CSP Unique India Mumbai%'
  and Region like 'East'

  SELECT Parent.Work_Order_Number as Work_Order_Number, SUM( Child.Supply_Gas_Charges ) AS Total
  into #total_Supply_Cost  FROM Cooling_Work_Order AS Parent 
       LEFT JOIN Cooling_Expense As Child ON Parent.Work_Order_Number = Child.Work_Order_Number
GROUP BY Parent.Work_Order_Number;


update Cooling_Work_Order 
set Cooling_Supply_Cost = B.Total
from #total_Supply_Cost B
where
Cooling_Work_Order.Work_Order_Number like B.Work_Order_Number

Delete #total_Supply_Cost

select * from SE_CSS_MASTER where CSS_Name_in_bFS_to_be_referred like '%UCS%'

update SE_CSS_MASTER
set CSS_Name_in_bFS_to_be_referred = 'India FS South4 Cooling CSP UCS project & Service Bangalore'
where CSS_Name_in_bFS_to_be_referred like 'India FS South3 Cooling CSP UCS project & Service Bangalore'

select * from SE_CSS_MASTER where CSS_Name_in_bFS_to_be_referred like '%unity%'

select * from Cooling_Rate_Card where CSS_Code like '%unity%'


update SE_CSS_MASTER
set CSS_Name_in_bFS_to_be_referred = 'India FS South4 Cooling CSP Unity Air conditioning Engineers Chennai'
where CSS_Name_in_bFS_to_be_referred like 'India FS South2 Cooling CSP Unity Air conditioning Engineers Chennai'


select  
  Work_Order_Number,
   Supply_Gas_Charges,
  Labour_Charges,
  Gas_Rate,
  Total_Claim,

  Work_Description,
  Product_Grouping,
  Work_Detail_Type,
  Work_Description_Map_Code,
  Work_Description_Mapped, 
  Claim,* from Cooling_Expense where 
Service_Team like 'India FS South4 Cooling CSP Unity Air conditioning Engineers Chennai'
or  Service_Team like 'India FS South4 Cooling CSP UCS project & Service Bangalore'


update aspnetusers set 
UserName='raghavendra@zigma-technologies.com',
NormalizedUserName='raghavendra@zigma-technologies.com',
Email='raghavendra@zigma-technologies.com',
NormalizedEmail='raghavendra@zigma-technologies.com'
where UserName like '%raghavendra@zigma-technologies.com%'

select * from AspNetUsers where UserName like '%raghavendra@zigma-technologies.com%'
End
END
