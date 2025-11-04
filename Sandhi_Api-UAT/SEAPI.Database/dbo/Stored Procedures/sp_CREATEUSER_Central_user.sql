-- Exec sp_CREATEUSER_Central_user
CREATE Procedure [dbo].[sp_CREATEUSER_Central_user]
AS
Begin
declare @userName varchar(max)
declare @cssCode	varchar(100)
declare @firstName		varchar(max)
declare @lastName		varchar(max)
declare @businessUnit varchar(max)
set @firstName='sankar '
SET @lastName='ganesh'
set @cssCode=null
set @businessUnit =null
set @userName ='sankar.mganesh@se.com'
--sankar.mganesh@se.com <sankar.mganesh@se.com>;
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
      ,@userName
       ,1 as [EmailConfirmed]
      ,1 as [LockoutEnabled]
      ,null as [LockoutEnd]
      ,upper(@username)
      ,upper(@username)
       ,'AQAAAAEAACcQAAAAEK3UpY0vbBiLaR9Hyef2g67nK/44fL3JCDQSlijiPCyaUeGSpvr7Ti8pcWO+pRiI1Q==' as [PasswordHash]
      ,'' as [PhoneNumber]
      ,0 as [PhoneNumberConfirmed]
      ,newid() as [SecurityStamp]
      ,0 as [TwoFactorEnabled]
      ,@userName
      ,1
      ,1
      ,@cssCode
      ,'' as [UserZone]
      ,'' as [Address]
      ,'' as [EmployeeCode]
      ,@businessUnit
      ,1 as [IsEnabled]
      ,@firstName
      ,@lastName

end 
