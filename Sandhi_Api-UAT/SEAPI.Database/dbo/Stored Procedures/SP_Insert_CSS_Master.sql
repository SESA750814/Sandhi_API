

CREATE procedure [dbo].[SP_Insert_CSS_Master]
as
BEGIN

update b set b.region = a.[Region]
				  ,b.CSS_Name_as_per_Oracle_SAP = a.[CSS_Name_as_per_Oracle_SAP]
				  ,b.[CSS_Name_in_bFS_to_be_referred]=a.[CSS_Name_in_bFS_to_be_referred]
				  ,b.[CSS_Manager] = a.[CSS_Manager]
				  ,b.[Vendor_Code]=a.[Vendor_Code]
				  ,b.[CSS_Code]=a.[CSS_Code]
				  ,b.[Email_ID]=a.[Contact_Person_Email_Id]
				  ,b.[Contact_Person_Email_Id]=a.[Contact_Person_Email_Id]
				  ,b.[Pay_out_Type]=a.[Pay_out_Type]
				  ,b.[Pay_out_Structure]=a.[Pay_out_Sctructure]
				  ,b.[Business_Unit]=a.[Business_Unit]
				  ,b.[City_Location]=a.[City_Location]
				  ,b.[State]=a.[State]
				  ,b.[CSS_Country]=a.[CSS_Country]
				  ,b.[Finance_Claim_Data_Validator]=a.[Finance_Claim_Data_Validator]
				  ,b.[Invoice_Validator_from_Finance_Team]=a.[Invoice_Validator_from_Finance_Team]
				  ,b.[HBN_WARRANTY]=a.[HBN_WARRANTY]
				  ,b.[HBN_AMC]=a.[HBN_AMC]
				  ,b.[AMC_LABOR]=a.[AMC_LABOR]
				  ,b.[AMC_SUPPLY]=a.[AMC_SUPPLY]
				  ,b.[WARRANTY_LABOR]=a.[WARRANTY_LABOR]
				  ,b.[WARRANTY_SUPPLY]=a.[WARRANTY_SUPPLY]
				  ,b.[PO]=a.[PO]
				  ,b.[WH_Location]=a.[WH_Location]
				  ,b.[PO_Type]=a.[PO_Type]
				  ,b.[CSS_City_Class]=a.[CSS_City_Class]
				  ,b.[GRN_Creater_Email_ID]=a.[GRN_Creater_Email_ID] 
				  ,b.[Grn_Creater] =a.[GRN_Creater]
				  ,b.[Finance_Head] =a.[Finance_Head]
				  ,b.[Finance_Head_Email_ID] =a.[Finance_Head_Email_ID]	
				  ,b.[CSS_Manager_Email_ID] =a.[CSS_Manager_Email_ID]
				  ,b.Base_Payout_Percentage = ISNULL(a.base_payout_percentage, 100)
				  ,b.Incentive_Percentage = ISNULL(a.Incentive_Percentage, 0)
				from CSS_List_Payout_Slab_CSS_Manager_Details a 
				inner join se_Css_master b on a.css_code = b.css_code 
				
				insert into SE_CSS_Master(
					[Region]
				  ,[CSS_Name_as_per_Oracle_SAP]
				  ,[CSS_Name_in_bFS_to_be_referred]
				  ,[CSS_Manager]
				  ,[Vendor_Code]
				  ,[CSS_Code]
				  ,[Email_ID]
				  ,[Pay_out_Type]
				  ,[Pay_out_Structure]
				  ,[Business_Unit]
				  ,[City_Location]
				  ,[State]
				  ,[CSS_Country]
				  ,[Finance_Claim_Data_Validator]
				  ,[Invoice_Validator_from_Finance_Team]
				  ,[HBN_WARRANTY]
				  ,[HBN_AMC]
				  ,[AMC_LABOR]
				  ,[AMC_SUPPLY]
				  ,[WARRANTY_LABOR]
				  ,[WARRANTY_SUPPLY]
				  ,[PO]
				  ,[WH_Location]
				  ,[PO_Type]
				  ,[CSS_City_Class]	
				  ,Grn_Creater
				  ,GRN_Creater_Email_Id
				  , Finance_Head
				  ,Finance_Head_Email_ID	
				  , SCM_Head_Email_Id
				  ,CSS_Manager_Email_ID
				  ,[base_payout_percentage]
			      ,[Incentive_Percentage]
			)
			select [Region]
				  ,[CSS_Name_as_per_Oracle_SAP]
				  ,[CSS_Name_in_bFS_to_be_referred]
				  ,[CSS_Manager]
				  ,[Vendor_Code]
				  ,[CSS_Code]
				  ,[Contact_Person_Email_Id]
				  ,[Pay_out_Type]
				  ,[Pay_out_Sctructure]
				  ,[Business_Unit]
				  ,[City_Location]
				  ,[State]
				  ,[CSS_Country]
				  ,[Finance_Claim_Data_Validator]
				  ,[Invoice_Validator_from_Finance_Team]
				  ,[HBN_WARRANTY]
				  ,[HBN_AMC]
				  ,[AMC_LABOR]
				  ,[AMC_SUPPLY]
				  ,[WARRANTY_LABOR]
				  ,[WARRANTY_SUPPLY]
				  ,[PO]
				  ,[WH_Location]
				  ,[PO_Type]
				  ,[CSS_City_Class]
				  ,Grn_Creater
				  ,GRN_Creater_Email_Id
				  ,Finance_Head
				  ,Finance_Head_Email_Id
				  ,SCM_Head_Email_Id
				  ,CSS_Manager_Email_ID
				  ,ISNULL(base_payout_percentage, 100)
				  ,ISNULL(Incentive_Percentage, 0)
				from CSS_List_Payout_Slab_CSS_Manager_Details 
			 where CSS_Code not in (select CSS_Code from SE_CSS_Master)

update b set b.INV_FIN_USER_ID= a.id from aspnetusers a inner join se_Css_master b on (a.FirstName + ' ' + coalesce(a.lastname,'') = b.Invoice_Validator_from_Finance_Team or a.firstname = b.Invoice_Validator_from_Finance_Team ) where usertype='4' and coalesce(b.INV_FIN_USER_ID,'')=''
update b set b.GRN_USER_ID= a.id from aspnetusers a inner join se_Css_master b on (a.FirstName + ' ' + coalesce(a.lastname,'') =  b.Grn_Creater or a.firstname =  b.Grn_Creater ) where usertype='5' and coalesce(b.GRN_USER_ID,'')=''
update b set b.CSS_MGR_USER_ID= a.id from aspnetusers a inner join se_Css_master b on (a.FirstName + ' ' + coalesce(a.lastname,'') =   b.CSS_Manager or a.firstname =   b.CSS_Manager ) where usertype='2' and coalesce(b.css_mgr_user_id,'') =''

END
