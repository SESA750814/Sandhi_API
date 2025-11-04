-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,>
-- Description:	<Cooling Work Order Process rate mapping process,,>
-- =============================================
--exec SP_Cooling_Rate_Expense_Mapping

CREATE     PROCEDURE [dbo].[SP_Cooling_Rate_Expense_Mapping_Before_fix]
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

	--select CSS_Code,Payout_Type,Business_Unit,Region,Branch_Code from Cooling_Work_Order


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
  UPDATE
    Cooling_Expense
SET
    Cooling_Expense.Product_Grouping = ProCateList.Product_Grouping
FROM 
    Cooling_Product_Category_list ProCateList
INNER JOIN
    Cooling_Expense WO
ON 
    ProCateList.Unit_Category = SUBSTRING(WO.Product, 1, 3)
	or  ProCateList.Unit_Category = SUBSTRING(WO.Product, 1, 4) ;

		-- Find and update Supplies from Cooling Expense Dump

--Update Distance slap 

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



Select Work_order_number, Distance_Slab into TempDistanceSlab from Cooling_Expense where Is_Expenses_Mileage = 1 

--Select Work_order_number, Distance_Slab  from Cooling_Expense where Is_Expenses_Mileage = 1 

-- Update Distance Slab all line items for same Work Orders
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

    Update 
Cooling_Expense
set 
Is_Expenses_PM = 1,
Work_Description_Map_Code = CPT.Work_Description
from 
Cooling_Description_Master CPT
inner join
Cooling_Expense CE
On
  CE.Work_Order_Type  like '%'+CPT.Work_Detail+'%' 

      

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
  [dbo].[RemoveCharSpecialSymbolValue](CWO.Work_Description)  like '%'+trim(CPT.Work_Description)+'%' 
  And Is_Expenses_Gas = 1

  -- Update Repair CRC and LRC 
   Update 
Cooling_Expense
set 
Cooling_Expense.Work_Description_Map_Code = CPT.Work_Description
from 
Cooling_Description_Master CPT
where
 trim(Cooling_Expense.Work_Description)  like '%'+trim(CPT.Work_Detail)+'%' 
 

-- Update Claim

-- Make Claim as 0

update Cooling_Expense
set 
Labour_Charges = 0,
Supply_Gas_Charges = 0,
Claim=0,
Gas_rate = 0

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

		-- for Payout or Group is null
		UPDATE
    Cooling_Expense
SET
    Claim  =  0
FROM
    Cooling_Expense 
	Where
     Product_Grouping is null
	 or Distance_Slab is null

	 -- update Gas Claim 

	  -- Make Gas Claim as 0 Gas_Rate
	  Update 
	 Cooling_Expense 
	 set 		  
	  Supply_Gas_Charges = 0
	 Where Is_Expenses_Gas = 1 and claim is not null

	 Update 
	 Cooling_Expense 
	 set 
	 Supply_Gas_Charges = cast(Expense_Quantity as float) * claim,
	 Gas_Rate = claim
	 Where Is_Expenses_Gas = 1 and claim is not null

	
	 Update 
	 Cooling_Expense 
	 set 
	  claim = 0	 
	 Where Is_Expenses_Gas = 1 and claim is not null
	 
	 
	-- Group by Work_Order_Number


-- Rate Mapping 
-- Update Supplies Chargs Nothing but Repair Chargs 

update Cooling_Expense
set 
Labour_Charges = t.Labour_Charges  
from Cooling_Expense
join 
(
    select  Work_Order_Number,Claim as Labour_Charges 
    from Cooling_Expense
    --group by Work_Order_Number  
) t
on Cooling_Expense.Work_Order_Number= t.Work_Order_Number 
and  Cooling_Expense.Is_Expenses_Gas is null
and Cooling_Expense.Payout_Type = 'Repair Charges' -- updated for labour charges fix
or  Cooling_Expense.Is_Expenses_Gas <> 1

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

update Cooling_Work_Order
set 
	Cooling_Work_Order.Cooling_Mileage_Actual_Expenses = CE.Expense_Quantity,
	Cooling_Work_Order.Cooling_Mileage_Work_Description = CE.Work_Description,
	Cooling_Work_Order.Distance_Slab = CE.Distance_Slab
from
Cooling_Expense CE
where 
Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and CE.Is_Expenses_Mileage = 1

-- Gas

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

-- update costs to Cooling Work order from Cooling Expense

update Cooling_Work_Order
set 
	Cooling_Work_Order.Cooling_Supplies_Actual_Expenses = CE.Expense_Quantity,
	Cooling_Work_Order.Cooling_Supplies_Work_Description = CE.Work_Description
from
Cooling_Expense CE
where 
Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and  CE.Is_Expenses_Gas is null
or  CE.Is_Expenses_Gas <> 1

update Cooling_Work_Order
set 
Cooling_Work_Order.Cooling_Labour_Cost = CE.Labour_Charges
from Cooling_Expense CE
Where Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and  CE.Labour_Charges   <> 0


update Cooling_Work_Order
set 
Cooling_Work_Order.Cooling_Supply_Cost = CE.Supply_Gas_Charges
from Cooling_Expense CE
Where Cooling_Work_Order.Work_Order_Number = CE.Work_Order_Number
and  CE.Supply_Gas_Charges   <> 0

update Cooling_Work_Order
set 
Cooling_Total_Cost = Cooling_Labour_Cost + Cooling_Supply_Cost

--  update Claim Type Warranty or AMC 

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

 --Select Claim_Type,Non_Billing_Reason from Cooling_Work_Order where Claim_Type is not null


--update Cooling_Work_Order
--set 
--Cooling_Work_Order.Cooling_Labour_Cost = t.Labour_Charges
--from Cooling_Expense
--join 
--(
--    select  Work_Order_Number, Labour_Charges 
--    from Cooling_Expense
--    group by Work_Order_Number  
--) t
--on Cooling_Expense.Work_Order_Number = t.Work_Order_Number 
--and t.Labour_Charges is not null 
--or t.Labour_Charges <> 0


--update Cooling_Work_Order
--set 
--Cooling_Work_Order.Cooling_Supply_Cost = t.Supply_Gas_Charges,
--from Cooling_Expense
--join 
--(
--    select  Work_Order_Number, Supply_Gas_Charges
--    from Cooling_Expense
--    group by Work_Order_Number  having Work_Order_Number ='WO-08868908'
--) t
--on Cooling_Expense.Work_Order_Number = t.Work_Order_Number 










--select Work_Order_Number,Cooling_Gas_Actual_Expenses,Cooling_Gas_Work_Description from Cooling_Work_Order
	
--select Work_Order_Number,Cooling_Gas_Actual_Expenses,Cooling_Gas_Work_Description from Cooling_Work_Order
	
----and  Cooling_Expense.Is_Expenses_Supplies_Repair is null
----or  Cooling_Expense.Is_Expenses.Is_Expenses_Supplies_Repair = 1

--select Supplies_Repair_Charges, Work_Description_Map_Code,Work_Detail_Type from Cooling_Expense where Is_Expenses_Supplies_Repair = 1






END

--Begin


--select * from Cooling_Expense where Is_Expenses_Gas = 1
--  select  Work_Description_Map_Code,  Work_Description ,Expense_Quantity
--  from Cooling_Expense order by Work_Description_Map_Code desc Where Is_Expenses_Gas = 1

----select Payout_type , Work_Detail, Work_Description from  Cooling_Description_Master

------select * from Cooling_Expense where Work_Description_Map_Code = 'pmc'

--Select Work_order_Number from Cooling_Expense group by Work_order_Number having COUNT(*) > 2
--WO-08855339
--WO-08868908
----WO-08900180

--select
--    Work_Order_Number,
--	Cooling_Mileage_Actual_Expenses,
--	Cooling_Mileage_Work_Description,
--	Cooling_Gas_Actual_Expenses,
--	Cooling_Gas_Rate,
--	Cooling_Gas_Work_Description,
--	Cooling_Supplies_Actual_Expenses,
--	Cooling_Supplies_Work_Description,
--	Cooling_Labour_Cost,
--	Cooling_Supply_Cost,
--	Cooling_Total_Cost
--from    
--Cooling_Work_Order 
--Where Work_Order_Number = 'WO-08885631'

--Select Region, Service_Team, Work_Order_number,  Product, Product_Grouping, Distance_Slab,Work_Description_Map_Code,
--Claim,
--Gas_Rate,
--Expense_Quantity,
--Supplies_Repair_Charges,
--Supply_Gas_Charges,
--Labour_Charges,
--Work_Description ,
--Work_Order_Type
--from Cooling_Expense 
----where
-- --work_order_number like 'WO-08885631'
-- order by Work_Order_number

 
 
--Select Region,Service_Team,  Work_Order_number, Product, Product_Grouping, Distance_Slab,PM_Charges_Claim,Gas_Rate,
--Supplies_Charges_Gas_Claim,
--SVC_Claim,
--PM_Charges_Work_Description  
--from Cooling_Work_Order
--where work_order_number like 'WO-08873529'
----select Product_Grouping, Work_Order_number, Product from Cooling_Expense where Work_Order_number in (Select Work_Order_number from Cooling_Work_Order)

--select * from Cooling_Expense where Work_Order_number  in (Select Work_Order_number from Cooling_Work_Order)

--select * from Cooling_Expense where Is_Expenses_Gas = 1 and claim is not null
 --Select * from Cooling_RAW_DUMP_Expense

 --select * from Cooling_Expense where Product_Grouping is null
	--  select * from Cooling_Expense where Product_Grouping is null
 --End

 --	[Cooling_Mileage_Actual_Expenses] [float] NULL,
	--[Cooling_Mileage_Work_Description] [nvarchar](max) NULL,
	--[Cooling_Gas_Actual_Expenses] [float] NULL,
	--[Cooling_Gas_Work_Description] [nvarchar](max) NULL,
	--[Cooling_Supplies_Actual_Expenses] [float] NULL,
	--[Cooling_Supplies_Work_Description] [nvarchar](max) NULL,
	--[Cooling_Labour_Cost] [float] NULL,
	--[Cooling_Supply_Cost] [float] NULL,
	--[Cooling_Total Cost] [float] NULL,
