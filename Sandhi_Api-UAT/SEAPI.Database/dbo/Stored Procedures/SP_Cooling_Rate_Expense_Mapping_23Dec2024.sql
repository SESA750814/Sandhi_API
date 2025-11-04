
-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,>
-- Description:	<Cooling Work Order Process rate mapping process,,>
-- =============================================
--exec SP_Cooling_Rate_Expense_Mapping
-- Updated: Niraj

CREATE     PROCEDURE [dbo].[SP_Cooling_Rate_Expense_Mapping_23Dec2024]
	-- Add the parameters for the stored procedure here
AS
BEGIN

-- update css_code, payout_type from CSS_List_Payout for all work orders



  UPDATE
    Cooling_Work_Order
SET
    Cooling_Work_Order.CSS_Code = CssList.CSS_Code,
	Cooling_Work_Order.Payout_Type = CssList.Pay_out_Type,
	Cooling_Work_Order.Business_Unit = CssList.Business_Unit,
	Cooling_Work_Order.Region  = CssList.Region,
	Cooling_Work_Order.Branch_Code = SUBSTRING(CssList.CSS_Code, 1, 3)
FROM 
    SE_CSS_Master CssList
INNER JOIN
    Cooling_Work_Order CE
ON 
    CssList.CSS_Name_in_bFS_to_be_referred like CE.Service_Team

	
	-- Cooling Labout Fix if Expense Data not availale in Cooling Expense. Copy from Cooling Raw Dump
	 insert into 
  Cooling_Expense
  (Work_Order_Number,Product,Expense_Quantity,Work_Detail_Type,Work_Order_Type,Work_Detail_Line_Number,Service_Team,CSS_Code,Region)
  select 
  Work_Order_Number,Product,Actual_Expense_converted,'Actual Expenses Mileage',Work_Order_Type,'WL-FromCoolingDump',Service_Team,CSS_Code,Region 
  from Cooling_Work_Order
  where   Work_Order_Number not in (Select Work_Order_Number from Cooling_Expense ) and Work_Order_Type like 'Preventive Maintenance'
  --- Cooling labour Fix



  update Cooling_Expense
set  
Labour_Charges = 0,
Supply_Gas_Charges = 0,
Claim=0,
Gas_rate = 0,
Is_Expenses_Gas = 0,
Is_Expenses_Mileage = 0,
Is_Expenses_Supplies_Repair =0

   UPDATE
    Cooling_Expense
SET
    --Cooling_Expense.CSS_Code = CssList.CSS_Code,
	Cooling_Expense.Payout_Type = CssList.Pay_out_Type,
	Cooling_Expense.Business_Unit = CssList.Business_Unit,
	Cooling_Expense.Region  = CssList.Region,
	Cooling_Expense.Branch_Code = SUBSTRING(CssList.CSS_Code, 1, 3)
FROM 
    SE_CSS_Master CssList
INNER JOIN
    Cooling_Expense CE
ON 
    CssList.CSS_Name_in_bFS_to_be_referred like CE.Service_Team
	
	
-- Delete Work Orders other than 'Secure Power_Cooling'

	delete from Cooling_Expense where Business_Unit not like 'Secure Power_Cooling' 
	--or Business_Unit is null


-- Product code from Cooling_Work_Order to map Group
  UPDATE
    Cooling_Expense
SET
   -- Cooling_Expense.CSS_Code = CssList.CSS_Code,
	Product = CWO.Product
FROM 
   Cooling_Work_Order CWO
INNER JOIN
    Cooling_Expense CE
ON     
	Cwo.Work_Order_Number like CE.Work_Order_Number

--- Update Product grouping 1. 2  from Product Category list

	update Cooling_Expense
	set Product_Grouping = NULL
-- First match product group with 3
UPDATE
    Cooling_Expense
SET
    Cooling_Expense.Product_Grouping = ProCateList.[Group]
FROM 
    Cooling_Product_Category_list ProCateList
INNER JOIN
    Cooling_Expense WO
ON 
    ProCateList.Product =  SUBSTRING(WO.Product, 1, 3) 

	UPDATE
    Cooling_Expense
SET
    Cooling_Expense.Product_Grouping = ProCateList.[Group]
FROM 
    Cooling_Product_Category_list ProCateList
INNER JOIN
    Cooling_Expense WO
ON 
    ProCateList.Product =  SUBSTRING(WO.Product, 1, 4)

	
	UPDATE
    Cooling_Expense
SET
    Cooling_Expense.Product_Grouping = ProCateList.[Group]
FROM 
    Cooling_Product_Category_list ProCateList
INNER JOIN
    Cooling_Expense WO
ON 
    ProCateList.Product =  SUBSTRING(WO.Product, 1, 5)
-- Override with product group if matches with 6 digit code
UPDATE
    Cooling_Expense
SET
    Cooling_Expense.Product_Grouping = ProCateList.[Group]
FROM 
    Cooling_Product_Category_list ProCateList
INNER JOIN
    Cooling_Expense WO
ON 
    ProCateList.Product =  SUBSTRING(WO.Product, 1, 6) 


		-- Find and update Supplies from Cooling Expense Dump

--Update Distance slap 
 update Cooling_Expense
   set Is_Expenses_Gas = 0, 
   Is_Expenses_Supplies_Repair = 0,
   Is_Expenses_Mileage = 0

	UPDATE
    Cooling_Expense	
SET
    Cooling_Expense.Is_Expenses_Mileage = 1,
    Cooling_Expense.Distance_Slab = PDS.Distance_Slab
from Cooling_Distance_Slab PDS
where 
Cast(Cooling_Expense.Expense_Quantity as float) <= PDS.Max_Range 
and cast(Cooling_Expense.Expense_Quantity as float) >= PDS.Min_Range
and Cooling_Expense.Work_Detail_Type like 'Actual Expenses Mileage'


--Select Work_order_number, Distance_Slab  from Cooling_Expense where Is_Expenses_Mileage = 1 

-- Update Distance Slab all line items for same Work Orders

Select Work_order_number, Distance_Slab into TempDistanceSlab from Cooling_Expense where Is_Expenses_Mileage = 1 

update Cooling_Expense
set
Distance_Slab = TDS.Distance_Slab
from TempDistanceSlab TDS
where 
Cooling_Expense.Work_Order_Number like TDS.Work_Order_Number
--and Cooling_Expense.Is_Expenses_Mileage not like 1 

--select * from TempDistanceSlab

Drop table TempDistanceSlab

-- PM Charges Map Work Description code for  PMC

    

   --  GAS Supply Map Work Description code for  GAS number

  

    UPDATE
    Cooling_Expense
   SET
    Cooling_Expense.Payout_Type = 'Supply Charges',
    Cooling_Expense.Is_Expenses_Gas = 1
	from
   Cooling_Expense CRDE
   where 
	CRDE.Work_Detail_Type like 'Actual Expenses Gas'  
	and CRDE.Work_Description is not null 
	and CRDE.Work_Description not like ''

	-- update payout Type for Supplies nothing but Repair Chargs
	
	 UPDATE
    Cooling_Expense
   SET
    Cooling_Expense.Payout_Type = 'Repair Charges',
    Cooling_Expense.Is_Expenses_Supplies_Repair = 1
	from
   Cooling_Expense CRDE
   where 
	CRDE.Work_Detail_Type like 'Actual Expenses Supplies'

	 -- Update Repair CRC and LRC 
   Update 
Cooling_Expense
set 
Cooling_Expense.Work_Description_Map_Code = CPT.Work_Description
from 
Cooling_Description_Master CPT
where
 trim(Cooling_Expense.Work_Description)  like '%'+trim(CPT.Work_Detail)+'%' 
 and Cooling_Expense.Is_Expenses_Supplies_Repair = 1

-- Update for part replacement
Update 
Cooling_Expense
set 
Cooling_Expense.Work_Description_Map_Code = 'SVC-Part'
where Cooling_Expense.Work_Order_Number in 
(
Select Work_Order_Number from Cooling_Work_Order
where Work_Order_Number in
(Select work_order_Number from Cooling_Expense where Is_Expenses_Supplies_Repair = 1)
and ((Work_Performed like '%repla%' and Work_Performed like '%fan%') or
(Work_Performed like '%change%' and Work_Performed like '%fan%') or
(Work_Performed like '%repla%' and Work_Performed like '%vfd%') or
(Work_Performed like '%change%' and Work_Performed like '%vfd%') or
(Work_Performed like '%repla%' and Work_Performed like '%valve%') or
(Work_Performed like '%change%' and Work_Performed like '%valve%') or
(Work_Performed like '%repla%' and Work_Performed like '%control%') or
(Work_Performed like '%change%' and Work_Performed like '%control%') or
(Work_Performed like '%repla%' and Work_Performed like '%capacitor%') or
(Work_Performed like '%change%' and Work_Performed like '%capacitor%') or
(Work_Performed like '%repla%' and Work_Performed like '%sensor%') or
(Work_Performed like '%change%' and Work_Performed like '%sensor%') or
(Work_Performed like '%repla%' and Work_Performed like '%compressor%') or
(Work_Performed like '%change%' and Work_Performed like '%compressor%') or
(Work_Performed like '%repla%' and Work_Performed like '%leak%') or
(Work_Performed like '%change%' and Work_Performed like '%leak%')  or
(Work_Performed like '%repla%' and Work_Performed like '%blow%') or
(Work_Performed like '%change%' and Work_Performed like '%blow%') or
(Work_Performed like '%repla%' and Work_Performed like '%filter%') or
(Work_Performed like '%change%' and Work_Performed like '%filter%')  or
(Work_Performed like '%repla%' and Work_Performed like '%drier%') or
(Work_Performed like '%change%' and Work_Performed like '%drier%')  or
(Work_Performed like '%repla%' and Work_Performed like '%motor%') or
(Work_Performed like '%change%' and Work_Performed like '%motor%')  or
(Work_Performed like '%repla%' and Work_Performed like '%part%') or
(Work_Performed like '%change%' and Work_Performed like '%part%')  or
(Work_Performed like '%repla%' and Work_Performed like '%card%') or
(Work_Performed like '%change%' and Work_Performed like '%card%')  or
(Work_Performed like '%repla%' and Work_Performed like '%contractor%') or
(Work_Performed like '%change%' and Work_Performed like '%contractor%')  or
(Work_Performed like '%repla%' and Work_Performed like '%humidi%') or
(Work_Performed like '%change%' and Work_Performed like '%humidi%') or
(Work_Performed like '%repla%' and Work_Performed like '%displ%') or
(Work_Performed like '%change%' and Work_Performed like '%displ%') or
(Work_Performed like '%repla%' and Work_Performed like '%transf%') or
(Work_Performed like '%change%' and Work_Performed like '%transf%') or
(Work_Performed like '%repla%' and Work_Performed like '%condens%') or
(Work_Performed like '%change%' and Work_Performed like '%condens%') or
(Work_Performed like '%repla%' and Work_Performed like '%transd%') or
(Work_Performed like '%change%' and Work_Performed like '%transd%') or
(Work_Performed like '%repla%' and Work_Performed like '%vmr%') or
(Work_Performed like '%change%' and Work_Performed like '%vmr%') or
(Work_Performed like '%repla%' and Work_Performed like '%evd%') or
(Work_Performed like '%change%' and Work_Performed like '%evd%') or
(Work_Performed like '%repla%' and Work_Performed like '%mech%') or
(Work_Performed like '%change%' and Work_Performed like '%mech%') or
(Work_Performed like '%repla%' and Work_Performed like '%chil%') or
(Work_Performed like '%change%' and Work_Performed like '%chil%') or
(Work_Performed like '%repla%' and Work_Performed like '%odu%') or
(Work_Performed like '%change%' and Work_Performed like '%odu%') or
(Work_Performed like '%repla%' and Work_Performed like '%dump%') or
(Work_Performed like '%change%' and Work_Performed like '%dump%') or
(Work_Performed like '%repla%' and Work_Performed like '%sens%') or
(Work_Performed like '%change%' and Work_Performed like '%sens%') or
(Work_Performed like '%repla%' and Work_Performed like '%rsf%') or
(Work_Performed like '%change%' and Work_Performed like '%rsf%') or
(Work_Performed like '%repla%' and Work_Performed like '%spares%') or
(Work_Performed like '%change%' and Work_Performed like '%spares%') or
(Work_Performed like '%repla%' and Work_Performed like '%fsc%') or
(Work_Performed like '%change%' and Work_Performed like '%fsc%') or
(Work_Performed like '%repla%' and Work_Performed like '%board%') or
(Work_Performed like '%change%' and Work_Performed like '%board%') or
(Work_Performed like '%repla%' and Work_Performed like '%pin%') or
(Work_Performed like '%change%' and Work_Performed like '%pin%') or
(Work_Performed like '%repla%' and Work_Performed like '%gas%') or
(Work_Performed like '%change%' and Work_Performed like '%gas%') or
(Work_Performed like '%repla%' and Work_Performed like '%working%') or
(Work_Performed like '%change%' and Work_Performed like '%working%') or
(Work_Performed like '%repla%' and Work_Performed like '%pfs%') or
(Work_Performed like '%change%' and Work_Performed like '%pfs%') or
(Work_Performed like '%repla%' and Work_Performed like '%actu%') or
(Work_Performed like '%change%' and Work_Performed like '%actu%') or
(Work_Performed like '%repla%' and Work_Performed like '%mcb%') or
(Work_Performed like '%change%' and Work_Performed like '%mcb%'))
)
and Cooling_Expense.Is_Expenses_Supplies_Repair = 1
and Cooling_Expense.Work_Description like '%Site Visit%'

-- Update Supply GAS 

   Update 
Cooling_Expense
set 
Work_Description_Map_Code = CPT.Work_Description
from 
Cooling_Description_Master CPT
inner join
Cooling_Expense cwo
On
  [dbo].[RemoveCharSpecialSymbolValue](CWO.Work_Description)  like LTRIM(RTRIM(CPT.Work_Description))
  And Is_Expenses_Gas = 1
  and Is_Expenses_Mileage = 0
   

  UPDATE
    Cooling_Expense
   SET
    Cooling_Expense.Payout_Type = 'PM Charges',
    Cooling_Expense.Is_Expenses_Supplies_Repair = 1
	from
   Cooling_Expense CRDE
   where 
	CRDE.Work_Detail_Type like 'Actual Expenses Supplies'
	and CRDE.Work_Description_Map_Code like '%PMC%'

-- Update Claim

	
	-- For Region
UPDATE
    Cooling_Expense
SET
   Cooling_Expense.Claim  =  CRC.rate 
FROM
    Cooling_Rate_Card CRC
INNER JOIN
    Cooling_Expense WO
ON 
    trim(CRC.Work_Description) like trim(WO.Work_Description_Map_Code) 	
	and trim(CRC.Product_Grouping)  like trim(WO.Product_Grouping)		
	and trim(CRC.Distance_Slab) like trim(WO.Distance_Slab)
	And trim(CRC.Region) like trim(WO.Region)
	And WO.Is_Expenses_Mileage = 0
	

	-- For CSSCode
	   UPDATE
    Cooling_Expense
SET
   Cooling_Expense.Claim  =  CRC.rate 
FROM
    Cooling_Rate_Card CRC
INNER JOIN
    Cooling_Expense WO
ON 
    trim(CRC.Work_Description) like trim(WO.Work_Description_Map_Code) 	
	and trim(CRC.Product_Grouping)  like trim(WO.Product_Grouping)		
	and trim(CRC.Distance_Slab) like trim(WO.Distance_Slab)
	And trim(CRC.CSS_Code) = trim(WO.Service_Team)
	And WO.Is_Expenses_Mileage = 0
			
	

	 -- Gas Rate

	 Update 
	 Cooling_Expense 
	 set 
	 Supply_Gas_Charges = cast(Expense_Quantity as float) * claim,
	 Gas_Rate = claim
	 Where Is_Expenses_Gas = 1 
	 	
	 
	 
-- Rate Mapping 
-- Update Labour Chargs Nothing but Repair Chargs 

update Cooling_Expense
set 
Labour_Charges = Cooling_Expense.Claim 
from Cooling_Expense
where
 Cooling_Expense.Is_Expenses_Supplies_Repair = 1  

--exec SP_Cooling_Rate_Expense_Mapping


-- Update Cooling Work Order from Cooling Expense 

update Cooling_Work_Order
set 
Cooling_Mileage_Actual_Expenses = 0
,Cooling_Mileage_Work_Description = NULL
,Cooling_Gas_Actual_Expenses = 0
,Cooling_Gas_Work_Description = NULL
,Cooling_Supplies_Actual_Expenses = 0
,Cooling_Supplies_Work_Description  = NULL
,Cooling_Labour_Cost = 0
,Cooling_Supply_Cost = 0
,Cooling_Total_Cost = 0
-- Millage
-- Update Mileage
update Cooling_Work_Order
set 
	Cooling_Work_Order.Cooling_Mileage_Actual_Expenses = CE.Expense_Quantity,
	Cooling_Work_Order.Cooling_Mileage_Work_Description = CE.Work_Description,
	Cooling_Work_Order.Distance_Slab = CE.Distance_Slab,
	Cooling_Work_Order.Product_Grouping = CE.Product_Grouping
from
Cooling_Expense CE
where 
Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and CE.Is_Expenses_Mileage = 1


-- Update Gas

update Cooling_Work_Order
set   
	Cooling_Work_Order.Cooling_Gas_Rate = CE.Gas_Rate,
	Cooling_Work_Order.Cooling_Gas_Actual_Expenses = CE.Expense_Quantity,
	Cooling_Work_Order.Cooling_Gas_Work_Description = CE.Work_Description
from
Cooling_Expense CE
where 
Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and CE.Is_Expenses_Gas = 1

-- Update Labour
update Cooling_Work_Order
set 
	Cooling_Work_Order.Cooling_Labour_Cost = CE.Labour_Charges,
	Cooling_Work_Order.Cooling_Supplies_Actual_Expenses = CE.Expense_Quantity,
	Cooling_Work_Order.Cooling_Supplies_Work_Description = CE.Work_Description
from Cooling_Expense CE
Where Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
AND CE.Is_Expenses_Supplies_Repair = 1  

-- Supply Total Cost Fix begin
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

-- Supply Total Cost Fix End

update Cooling_Work_Order
set 
Cooling_Work_Order.Cooling_Labour_Cost = CE.Labour_Charges
from Cooling_Expense CE
Where Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and  CE.Is_Expenses_Supplies_Repair = 1  


update Cooling_Work_Order
set 
Cooling_Work_Order.Cooling_Supply_Cost = CE.Supply_Gas_Charges
from Cooling_Expense CE
Where Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and CE.Is_Expenses_Gas = 1

update Cooling_Work_Order
set 
Cooling_Total_Cost = Cooling_Labour_Cost + Cooling_Supply_Cost

Update 
Cooling_Work_Order
set 
Claim_Type = CTD.Claim_Type
from 
Cooling_Call_Type_Derivation CTD
inner join
Cooling_Work_Order CWO
On
 trim(CWO.Non_Billing_Reason)  like '%'+trim(CTD.Non_Billing_Reason)+'%' 



END


