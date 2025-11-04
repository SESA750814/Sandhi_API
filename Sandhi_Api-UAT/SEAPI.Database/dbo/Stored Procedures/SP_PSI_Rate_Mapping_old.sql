-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,>
-- Description:	<PSI Work Order Process rate mapping process,,>
-- =============================================
CREATE     PROCEDURE [dbo].[SP_PSI_Rate_Mapping_old]
	-- Add the parameters for the stored procedure here
AS
BEGIN

-- update css_code, payout_type from CSS_List_Payout for all work orders
   UPDATE
    PSI_Work_Order
SET
    PSI_Work_Order.CSS_Code = CssList.CSS_Code,
	PSI_Work_Order.Payout_Type = CssList.Pay_out_Type,
	PSI_Work_Order.Business_Unit = CssList.Business_Unit,
	PSI_Work_Order.Region  = CssList.Region,
	PSI_Work_Order.Branch_Code = SUBSTRING(CssList.CSS_Code, 1, 3)
FROM 
    SE_CSS_Master CssList
INNER JOIN
    PSI_Work_Order WO
ON 
    CssList.CSS_Name_in_bFS_to_be_referred = WO.Service_Team;

--- Update Product grouping P-1. P-2  from Product Category list

  UPDATE
    PSI_Work_Order
SET
    PSI_Work_Order.Product_Grouping = ProCateList.Product_Grouping
FROM 
    PSI_Product_Category ProCateList
INNER JOIN
    PSI_Work_Order WO
ON 
    ProCateList.Product = WO.Product;

-- update actual distance into douple 

update PSI_Work_Order
set 
Actual_Expense_converted = Actual_Expense_converted * 2



---Update Distance slap in work order using Rate card and actual distance covered

	UPDATE
    PSI_Work_Order
SET
    PSI_Work_Order.Distance_Slab = PDS.Distance_Slab
from PSI_Distance_Slab PDS
where PSI_Work_Order.Actual_Expense_converted <= PDS.Max_Range and PSI_Work_Order.Actual_Expense_converted >= PDS.Min_Range



-- *** Update Claim in Transaction Table based on Rate card	***

	UPDATE
    PSI_Work_Order
SET
   PSI_Work_Order.Claim =  RCPSI.rate 
FROM
    PSI_Rate_Card RCPSI
INNER JOIN
    PSI_Work_Order WO
ON    
    WO.Product_Grouping  = RCPSI.Product_Grouping
	and WO.Distance_Slab = RCPSI.Distance_Slab
	and RCPSI.Rate not like 'NA'
	and RCPSI.Rate not like 'NULL'
	and CAST( WO.loaded_date as date) = CAST(getdate() as date) 

--	update Claim Type Warranty or AMC 
	Update 
PSI_Work_Order
set 
Claim_Type = CTD.Claim_Type
from 
Cooling_Call_Type_Derivation CTD
inner join
PSI_Work_Order PWO
On
 trim(PWO.Non_Billing_Reason)  like '%'+trim(CTD.Non_Billing_Reason)+'%' 

	-- exec SP_PSI_Insert_Transaction
	-- exec SP_PSI_Rate_Mapping
	--select Work_order_number, Payout_Type,Product_Grouping,Distance_Slab , Actual_Expense_converted,claim from psi_work_order 
	--where  claim is not null

	--select Work_order_number, Payout_Type,Product_Grouping,Distance_Slab , Actual_Expense_converted,claim from psi_work_order 
	--where  claim is  null
	
	End
