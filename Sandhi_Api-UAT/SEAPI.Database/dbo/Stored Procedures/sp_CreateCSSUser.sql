
-- exec sp_CreateCSSUser
CREATE PROCEDURE [dbo].[sp_CreateCSSUser]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- begin Below code added to retain changed password, Get back up  
update a set 
a.Email = LTRIM(RTrim(b.Contact_Person_Email_ID)),
NormalizedEmail =  LTRIM(RTrim(b.Contact_Person_Email_ID)),
NormalizedUserName = LTRIM(RTrim(b.Contact_Person_Email_ID)),
UserName = LTRIM(RTrim(b.Contact_Person_Email_ID))
from aspnetusers 
a inner join se_Css_master b 
on trim(a.CSSCode) = b.id where usertype = '3'

--select id,CSS_Code, Contact_Person_Email_ID,* from SE_CSS_MASTER where Contact_Person_Email_ID like '%aurangabad@unitedsolutions.co.in%'
--select id,CSS_Code, Contact_Person_Email_ID,* from SE_CSS_MASTER where Contact_Person_Email_ID like '%helpdesk@unitedsolutions.co.in%'

--select CSSCode, UserName,* from aspnetusers where Email like '%aurangabad@unitedsolutions.co.in%'
--select CSSCode, UserName,* from aspnetusers where Email like '%helpdesk@unitedsolutions.co.in%'

IF OBJECT_ID(N'dbo.Temp_aspnetuser', N'U') IS NOT NULL  
begin
   delete from  [dbo].[Temp_aspnetuser];
   insert into [dbo].[Temp_aspnetuser] ([Id], [UserName],[PasswordHash] ) select Id, UserName,PasswordHash  from AspNetUsers
end
else
select  Id, UserName,PasswordHash into [dbo].[Temp_aspnetuser] from AspNetUsers
-- End Below code added to retain changed password 


update se_css_master set INV_FIN_USER_ID= null, GRN_USER_ID=null,CSS_MGR_USER_ID= null 
delete from aspnetusers where usertype not in (0, 1)


	declare @userName	varchar(max)
	declare @businessUnit	varchar(max)
	declare @cssCode	varchar(100)
	declare @firstName		varchar(max)
	declare @lastName		varchar(max)
Declare css_cursor Cursor For
Select a.id as CssCode, a.business_unit as BusinessUnit, a.Email_ID as userName,a.CSS_Name_as_per_Oracle_SAP as FirstName, '' as LastName 
from se_css_master a
open css_cursor
FETCH Next from css_cursor into @cssCode, @businessUnit, @userName, @firstName, @lastName
while @@FETCH_STATUS=0
BEGIN
	declare @userId		Varchar(max)
	Declare user_cursor Cursor for
		Select item from dbo.SplitString(@userName,';') where item <> '' 
	open user_cursor
	Fetch Next From user_cursor into @userId
	while @@FETCH_STATUS=0
	BEGIN
		exec [sp_CREATEUSER] @userId, @businessUnit, @cssCode, @firstName, @lastName
    
	Fetch Next From user_cursor into @userId
	end
	close user_cursor;
	deallocate user_cursor;
FETCH Next from css_cursor into @cssCode, @businessUnit, @userName, @firstName, @lastName
END
Close css_cursor;
Deallocate css_cursor;


--***************************** CREATE CSS MANAGER ID *****************************


Insert into AspNetUsers (
		[Id]
      ,[AccessFailedCount]
      ,[ConcurrencyStamp]
      ,[Email]
      ,[EmailConfirmed]
      ,[LockoutEnabled]
      ,[LockoutEnd]
      ,[NormalizedEmail]
      ,[NormalizedUserName]
      ,[PasswordHash]
      ,[PhoneNumber]
      ,[PhoneNumberConfirmed]
      ,[SecurityStamp]
      ,[TwoFactorEnabled]
      ,[UserName]
      ,[UserStatus]
      ,[UserType]
      ,[CSSCode]
      ,[UserZone]
      ,[Address]
      ,[EmployeeCode]
      ,[BusinessUnit]
      ,[IsEnabled]
      ,[FirstName]
      ,[LastName]
)

select
	newid(),0 as [AccessFailedCount]
      ,newId() as [ConcurrencyStamp]
      ,upper(Finance_Claim_Data_Validator)
      ,1 as [EmailConfirmed]
      ,1 as [LockoutEnabled]
      ,null as [LockoutEnd]
      ,upper(Finance_Claim_Data_Validator)
      ,upper(Finance_Claim_Data_Validator )
      ,'AQAAAAEAACcQAAAAEK3UpY0vbBiLaR9Hyef2g67nK/44fL3JCDQSlijiPCyaUeGSpvr7Ti8pcWO+pRiI1Q==' as [PasswordHash]
      ,'' as [PhoneNumber]
      ,0 as [PhoneNumberConfirmed]
      ,newid() as [SecurityStamp]
      ,0 as [TwoFactorEnabled]
      ,Finance_Claim_Data_Validator
      ,1 as [UserStatus]
      ,2 as [UserType]
      ,''
      ,'' as [UserZone]
      ,'' as [Address]
      ,'' as [EmployeeCode]
      ,'' as [BusinessUnit]
      ,1 as [IsEnabled]
      ,FinName
      ,''
from
	(
		Select distinct trim(CSS_Manager_Email_ID) as Finance_Claim_Data_Validator, CSS_Manager as FinName from SE_Css_Master
	) a 
	left outer join 
	Aspnetusers b on UserType=2 and a.FinName = b.FirstName
where coalesce(b.firstname,'')=''


update b set b.CSS_MGR_USER_ID= a.id from aspnetusers a inner join se_Css_master b on trim(a.FirstName) = trim(b.CSS_Manager) where usertype='2'

--*************************** CREATE CSS MANAGER ID ENDs **********************


--*************************** CREATE SCM USER ID **********************
Insert into AspNetUsers (
		[Id]
      ,[AccessFailedCount]
      ,[ConcurrencyStamp]
      ,[Email]
      ,[EmailConfirmed]
      ,[LockoutEnabled]
      ,[LockoutEnd]
      ,[NormalizedEmail]
      ,[NormalizedUserName]
      ,[PasswordHash]
      ,[PhoneNumber]
      ,[PhoneNumberConfirmed]
      ,[SecurityStamp]
      ,[TwoFactorEnabled]
      ,[UserName]
      ,[UserStatus]
      ,[UserType]
      ,[CSSCode]
      ,[UserZone]
      ,[Address]
      ,[EmployeeCode]
      ,[BusinessUnit]
      ,[IsEnabled]
      ,[FirstName]
      ,[LastName]
)

select
	newid(),0 as [AccessFailedCount]
      ,newId() as [ConcurrencyStamp]
      ,upper(Finance_Claim_Data_Validator) 
      ,1 as [EmailConfirmed]
      ,1 as [LockoutEnabled]
      ,null as [LockoutEnd]
      ,upper(Finance_Claim_Data_Validator)
      ,upper(Finance_Claim_Data_Validator)
      ,'AQAAAAEAACcQAAAAEK3UpY0vbBiLaR9Hyef2g67nK/44fL3JCDQSlijiPCyaUeGSpvr7Ti8pcWO+pRiI1Q==' as [PasswordHash]
      ,'' as [PhoneNumber]
      ,0 as [PhoneNumberConfirmed]
      ,newid() as [SecurityStamp]
      ,0 as [TwoFactorEnabled]
      ,replace(Finance_Claim_Data_Validator,' ','.')
      ,1 as [UserStatus]
      ,5 as [UserType]
      ,''
      ,'' as [UserZone]
      ,'' as [Address]
      ,'' as [EmployeeCode]
      ,'' as [BusinessUnit]
      ,1 as [IsEnabled]
      ,FinName
      ,''
from
	(
		Select distinct trim(GRN_Creater_Email_ID) as Finance_Claim_Data_Validator, GRN_Creater as FinName from SE_Css_Master
	) a 
	left outer join 
	Aspnetusers b on UserType=5 and a.FinName = b.FirstName
where coalesce(b.firstname,'')=''


update b set b.GRN_USER_ID= a.id from aspnetusers a inner join se_Css_master b on trim(a.FirstName) = trim(b.GRN_Creater) where usertype='5'

--*************************** CREATE SCM USER ID ENDs **********************
--*************************** CREATE fas USER ID  **********************
Insert into AspNetUsers (
		[Id]
      ,[AccessFailedCount]
      ,[ConcurrencyStamp]
      ,[Email]
      ,[EmailConfirmed]
      ,[LockoutEnabled]
      ,[LockoutEnd]
      ,[NormalizedEmail]
      ,[NormalizedUserName]
      ,[PasswordHash]
      ,[PhoneNumber]
      ,[PhoneNumberConfirmed]
      ,[SecurityStamp]
      ,[TwoFactorEnabled]
      ,[UserName]
      ,[UserStatus]
      ,[UserType]
      ,[CSSCode]
      ,[UserZone]
      ,[Address]
      ,[EmployeeCode]
      ,[BusinessUnit]
      ,[IsEnabled]
      ,[FirstName]
      ,[LastName]
)

select
	newid(),0 as [AccessFailedCount]
      ,newId() as [ConcurrencyStamp]
      ,upper(Finance_Claim_Data_Validator) 
      ,1 as [EmailConfirmed]
      ,1 as [LockoutEnabled]
      ,null as [LockoutEnd]
      ,upper(Finance_Claim_Data_Validator) 
      ,upper(Finance_Claim_Data_Validator) 
      ,'AQAAAAEAACcQAAAAEK3UpY0vbBiLaR9Hyef2g67nK/44fL3JCDQSlijiPCyaUeGSpvr7Ti8pcWO+pRiI1Q==' as [PasswordHash]
      ,'' as [PhoneNumber]
      ,0 as [PhoneNumberConfirmed]
      ,newid() as [SecurityStamp]
      ,0 as [TwoFactorEnabled]
      ,replace(Finance_Claim_Data_Validator,' ','.')
      ,1 as [UserStatus]
      ,4 as [UserType]
      ,''
      ,'' as [UserZone]
      ,'' as [Address]
      ,'' as [EmployeeCode]
      ,'' as [BusinessUnit]
      ,1 as [IsEnabled]
      ,FinName
      ,''
from
	(
		Select distinct trim(Finance_Claim_Data_Validator) as Finance_Claim_Data_Validator, Invoice_Validator_from_Finance_Team as FinName from SE_Css_Master
	) a 
	left outer join 
	Aspnetusers b on UserType=4 and a.FinName = b.FirstName
where coalesce(b.firstname,'')=''

--fin user - usertype=4
-- scm user - usertype=5
-- csmanager - usertype=2

update b set b.INV_FIN_USER_ID= a.id from aspnetusers a inner join se_Css_master b on trim(a.FirstName) = trim(b.Invoice_Validator_from_Finance_Team) where usertype='4'

--*************************** CREATE fas USER ID ENDs **********************

-- begin Below code added to retain changed password and update 
update a
set a.PasswordHash = b.PasswordHash 
from aspnetusers a 
inner join 
Temp_aspnetuser b 
on 
a.UserName = b.UserName 

update AspNetUsers
set Email = LTRIM(RTrim(Email)),
NormalizedEmail =  LTRIM(RTrim(NormalizedEmail)),
NormalizedUserName = LTRIM(RTrim(NormalizedUserName)),
UserName = LTRIM(RTrim(UserName))
-- End Below code added to retain changed password and update 

END
