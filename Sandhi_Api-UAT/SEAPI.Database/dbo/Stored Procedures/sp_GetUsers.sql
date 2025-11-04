CREATE Procedure [dbo].[sp_GetUsers]

AS
BEGIN

--select a.id, FirstName, LastName , UserType, UserStatus, UserName,
--coalesce(b.CSS_Code,'') as Css_Code, coalesce(b.CSS_Name_as_per_Oracle_SAP,'') as Css_Name, 
--coalesce(b.region,'') as Region, coalesce(b.Business_Unit,'') as BusinessUnit
--from AspnetUsers  a left outer join se_Css_master b on a.csscode = b.id 


select id, FirstName, LastName , UserType, UserStatus, UserName, '' as CSS_Code, '' as Css_Code,'' as Css_Name,
'' as Region,'' as BusinessUnit

from AspnetUsers where UserType <> 3



--select 
--	a.CSS_Code, a.CSS_Name_as_per_Oracle_SAP,b.UserName,
--	mgr.username as ManagerUSer	
--	,Fin.UserName as FinUserMail
--	, scm.username as GRNUser
--from 
--	se_Css_master a 
--	inner join  aspnetusers b on a.id = b.CSSCode
--	inner join  aspnetusers mgr on a.CSS_MGR_USER_ID = mgr.id 
--	inner join  aspnetusers fin on a.INV_FIN_USER_ID = fin.id 
--	inner join  aspnetusers scm on a.GRN_USER_ID = scm.id 
--order by a.css_code  desc 

--Select * from aspnetusers where username like '%VIJAYKUMA%'



--query to get all css details like manager user id, fin user id, grn user id


END
