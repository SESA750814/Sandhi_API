-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,> Modified 23-03-2022
-- Description:	<HBN Work Order Process,,>

--EXEC [SP_HBN_Rate_Mapping]
-- =============================================
CREATE     PROCEDURE [dbo].[SP_HBN_Rate_Mapping]
	-- Add the parameters for the stored procedure here
AS
BEGIN

-- update css_code, payout_type from CSS_List_Payout for all work orders
   UPDATE
    HBN_Work_Order
SET
    HBN_Work_Order.CSS_Code = CssList.CSS_Code,
	HBN_Work_Order.Payout_Type = CssList.Pay_out_Type,
	HBN_Work_Order.Business_Unit = CssList.Business_Unit,
	HBN_Work_Order.Region  = CssList.Region,
	HBN_Work_Order.Branch_Code = SUBSTRING(CssList.CSS_Code, 1, 3)
FROM 
    SE_CSS_Master CssList
INNER JOIN
    HBN_Work_Order WO
ON 
    CssList.CSS_Name_in_bFS_to_be_referred = WO.Service_Team;

	--- Update Product grouping T-1. T-2  from Product Category list
   UPDATE
    HBN_Work_Order
SET
    HBN_Work_Order.Product_Grouping = ProCateList.[Group],
	HBN_Work_Order.Payout_Type = ProCateList.[Type]
FROM 
    HBN_Product_category_List ProCateList
INNER JOIN
    HBN_Work_Order WO
ON 
    ProCateList.Product = WO.Product;

	-- Special requirement only in case of battery installation
UPDATE
    HBN_Work_Order
SET
    HBN_Work_Order.Product_Grouping = 'P9'
Where HBN_Work_Order.Work_Order_Type = 'Commissioning & Installation'
AND HBN_Work_Order.Work_Order_Sub_Type like 'Battery I%';

-- Update Pay_out for Luminuos and Easy 
--Comment out Payout mapping based on product grouping - Niraj
/*
  update 
  HBN_Work_Order
  set 
  Payout_Type = RCH.PayOut_Type
  from 
  HBN_Rate_Card RCH
  inner join
  HBN_Work_Order wo
  on
  SUBSTRING (RCH.Product_Grouping , 1, 1) like 'l'
  and SUBSTRING (wo.Product_Grouping , 1, 1) like 'l'

  update 
  HBN_Work_Order
  set 
  Payout_Type = RCH.PayOut_Type
  from 
  HBN_Rate_Card RCH
  inner join
  HBN_Work_Order wo
  on
  SUBSTRING (RCH.Product_Grouping , 1, 1) like 'e'
  and SUBSTRING (wo.Product_Grouping , 1, 1) like 'e'
  */





--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'DS-A'
--where HBN_Work_Order.Actual_Expense_converted <= 40

--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'DS-B'
--where HBN_Work_Order.Actual_Expense_converted > 40 and HBN_Work_Order.Actual_Expense_converted  <=100

--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'DS-C'
--where HBN_Work_Order.Actual_Expense_converted > 100

--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'ALL'
--where HBN_Work_Order.Work_Order_Type like 'Preventive Maintenance'





--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'DS-C'
--where HBN_Work_Order.Actual_Expense_converted > 100

-- Update DS-C for Easy above  40

-- Update DS-C for Easy above  40

--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'DS-A'
--where 
--HBN_Work_Order.Payout_Type like 'Easy'
--and HBN_Work_Order.Actual_Expense_converted <= 40

--UPDATE
--    HBN_Work_Order
--SET
--    HBN_Work_Order.Distance_Slab = 'DS-C'
--where 
--HBN_Work_Order.Payout_Type like 'Easy'
--and HBN_Work_Order.Actual_Expense_converted > 40

UPDATE
    HBN_Work_Order
SET
    HBN_Work_Order.Distance_Slab = HDS.Distance_Slab
from HBN_Distance_Slab HDS
where 
--trim(HDS.PayOut_Type)  LIKE 'Easy' and
HBN_Work_Order.Actual_Expense_converted <= HDS.Max_Range and HBN_Work_Order.Actual_Expense_converted >= HDS.Min_Range



---Update Distance slap in work order using Rate card and actual distance covered
-- Update of distance slab need to be removed for Prventive Maintenance in HBN - Niraj
/*
UPDATE
    HBN_Work_Order
SET
    HBN_Work_Order.Distance_Slab = HDS.Distance_Slab
from HBN_Distance_Slab HDS
where HBN_Work_Order.Actual_Expense_converted <= HDS.Max_Range and HBN_Work_Order.Actual_Expense_converted >= HDS.Min_Range
and HBN_Work_Order.PayOut_Type not like 'Easy'
AND HBN_Work_Order.Work_Order_Type not like 'Preventive Maintenance'
and HDS.PayOut_Type is null

UPDATE
    HBN_Work_Order
SET
    HBN_Work_Order.Distance_Slab = HDS.Distance_Slab
from HBN_Distance_Slab HDS
WHERE
trim(HBN_Work_Order.Work_Order_Type)  LIKE 'Preventive Maintenance'
and HBN_Work_Order.PayOut_Type not like 'Easy'
and HDS.PayOut_Type LIKE 'Preventive Maintenance'
and HDS.PayOut_Type is not  null

*/
-- Update Material Used or Not used   
update 
HBN_Work_Order
SET
MaterialUsed = Work_Performed,
IsMaterialUsed = 1
Where
Work_Performed like '%Replace%'
or Work_Performed like '%Replaced%' 
or Work_Performed like '%Change%'
or Work_Performed like '%Changed%'
or Work_Performed like '%Replac%'
or Work_Performed like '%Reaplac%'
or Work_Performed like '%Reaplced%'
or Work_Performed like '%repacled%'
or Work_Performed like '%Repal%'
or Work_Performed like '%not replac%'
or Work_Performed like '%not replaced%'



--Update Work Order Material used for all


UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.MaterialUsed = 'MATERIAL'
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type = 'NSP Payout'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 1	
	and RCH.Service_Type = 'MATERIAL'
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'

-- Work Order NON Material used update
UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.MaterialUsed = 'NONMATERIAL'
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type = 'NSP Payout'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 0
	and RCH.Service_Type = 'NONMATERIAL'
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'

-- Update material Used field for Payout "Easy'

UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.MaterialUsed = 'MATERIAL',
  HBN_Work_Order.Work_Order_Type = 'MATERIAL'
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type Like 'Easy'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 1
	and RCH.Service_Type = 'MATERIAL'
	--and RCH.Service_Type =  WO.Work_Order_Type
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'
	


UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.MaterialUsed = 'NONMATERIAL',
  HBN_Work_Order.Work_Order_Type = 'NONMATERIAL'
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type Like 'Easy'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 0
	and RCH.Service_Type = 'NONMATERIAL'
	--and RCH.Service_Type =  WO.Work_Order_Type
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'
	


--	 Update T-10 for Battery Installation falls in any payout_type
/*
UPDATE 
HBN_Work_Order
SET
Product_Grouping = 'T-10'
Where 
[dbo].[RemoveCharSpecialSymbolValue](Work_Order_Type)  like '%CommissioningInstallation%'
AND Work_Order_Sub_Type like '%Battery Installation%'
*/

-- *** Update Claim in Transaction Table based on Rate card	***

UPDATE
    HBN_Work_Order
SET
   HBN_Work_Order.Claim =  0

UPDATE
    HBN_Work_Order
SET
   HBN_Work_Order.Claim =  RCH.rate 
FROM
    HBN_Rate_Card RCH
INNER JOIN
    HBN_Work_Order WO
ON 
    WO.Payout_Type = RCH.PayOut_Type 
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and WO.Work_Order_Type = RCH.Service_Type

	--Update rate for HDFC Niraj
UPDATE
    HBN_Work_Order 
SET
   HBN_Work_Order.Claim =  3000
where 
HBN_Work_Order.Installed_At_Account like '%HDFC%'
AND HBN_Work_Order.Product in ('LD6000T', 'LD6000-PRO') 
AND HBN_Work_Order.Distance_Slab = 'DS-A'
AND HBN_Work_Order.Work_Order_Type = 'Commissioning & Installation'

UPDATE
    HBN_Work_Order 
SET
   HBN_Work_Order.Claim =  4000
where HBN_Work_Order.Installed_At_Account like '%HDFC%' 
AND HBN_Work_Order.Product in ('LD6000T', 'LD6000-PRO') 
AND HBN_Work_Order.Distance_Slab = 'DS-B'
AND HBN_Work_Order.Work_Order_Type = 'Commissioning & Installation'

UPDATE
    HBN_Work_Order 
SET
   HBN_Work_Order.Claim =  5000
where HBN_Work_Order.Installed_At_Account like '%HDFC%' 
AND HBN_Work_Order.Product in ('LD6000T', 'LD6000-PRO') 
AND HBN_Work_Order.Distance_Slab IN ('DS-C', 'DS-D')
AND HBN_Work_Order.Work_Order_Type = 'Commissioning & Installation'

	-- Update the claim to 0 if the work closed over phone.
UPDATE
    HBN_Work_Order
SET
   HBN_Work_Order.Claim =  0
where Work_Performed like '%closed over phone%' 
OR Work_Performed like '%over phone closed%'
OR Work_Performed like '%delivered over phone%'
OR Work_Performed like '%over phone delivered%'
OR Work_Performed like '%resolved over phone%'
OR Work_Performed like '%over phone resolved%'





	-- Payout type EASY and material not used - material/Non material
-- These specific updates of rate no longer required - Niraj 12/20/24
/*
	UPDATE
    HBN_Work_Order
SET
   HBN_Work_Order.Claim =  RCH.rate 
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type Like 'Easy'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 0
	and RCH.Service_Type = wo.Work_Order_Type
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'

-- Update Rate for Material used in NSP payout 

	UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.Claim =  RCH.rate 
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type = 'NSP Payout'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 1	
	and RCH.Service_Type = 'MATERIAL'
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'
	and CAST( WO.loaded_date as date) = CAST(getdate() as date) 

	-- Update Rate for NON Material used in NSP payout 
	UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.Claim =  RCH.rate 
FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type = 'NSP Payout'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and WO.IsMaterialUsed = 0	
	and RCH.Service_Type = 'NONMATERIAL'
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'
	and CAST( WO.loaded_date as date) = CAST(getdate() as date) 
		
  -- update payout type "Easy" for Material Used 

 	UPDATE
    HBN_Work_Order
SET
  HBN_Work_Order.Claim =  RCH.rate 

FROM
  HBN_Work_Order WO
  
INNER JOIN
    HBN_Rate_Card RCH
ON 
    WO.Payout_Type like 'EASY'	
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%CommissioningInstallation%'
	and [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type) not like '%PreventiveMaintenance%'
	and RCH.Service_Type like [dbo].[RemoveCharSpecialSymbolValue](WO.Work_Order_Type)
	and WO.IsMaterialUsed = 1	
	
	and WO.Product_Grouping  = RCH.Product_Grouping
	and WO.Distance_Slab = RCH.Distance_Slab
	and RCH.Rate not like 'NA'
	and RCH.Rate not like 'NULL'
	and CAST( WO.loaded_date as date) = CAST(getdate() as date) 
	*/
	--exec SP_HBN_RateMapping
--update Claim Type Warranty or AMC 	
	Update 
HBN_Work_Order
set 
Claim_Type = CTD.Claim_Type
from 
Cooling_Call_Type_Derivation CTD
inner join
HBN_Work_Order HWO
On
 trim(HWO.Non_Billing_Reason)  like '%'+trim(CTD.Non_Billing_Reason)+'%' 

-- Update the claim to 0 if claim type is null.
UPDATE
    HBN_Work_Order
SET
   HBN_Work_Order.Claim =  0
where Claim_Type is null

END
