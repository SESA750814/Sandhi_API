-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[Error_Log_Notification]
@Status_Type int,
@Ref_No nvarchar(100),
@Ref_Type nvarchar(200),
@CSS_Id int,
@User_Id nvarchar(200),
@User_Type nvarchar(200),
@Remarks nvarchar(max),
@Action  nvarchar(max),
@Created_User nvarchar(200)

	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
--INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
--									    VALUES(@Status_Type, @Ref_No , @Ref_Type , @CSS_Id ,@User_Id,@User_Type,@Remarks, @Action ,@Created_User, GETDATE(),GETDATE(),1)

if(@Status_Type=1 or @Status_Type=2)
Begin	

	declare @centralEmail			Varchar(max)
	select 
		@centralEmail=username 
	from (
			SELECT 
				SS.userType, 
				stuff((SELECT ', ' + US.username 
				FROM AspNetUsers US
				WHERE US.UserType = SS.UserType
				FOR XML PATH('')),1,1,'') as UserName
			FROM aspnetusers SS
			GROUP BY SS.usertype 
			) a 
	where a.usertype=1

	INSERT INTO [dbo].[SE_Notification]  
	([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive], SUBJECT, Body, ToEmail)  
	VALUES(@Status_Type, @Ref_No , @Ref_Type , null ,null,1,'RAW Dump:' + @Remarks, @Action ,@Created_User, GETDATE(),DAteadd(d,3,GETDATE()),1, 'RAW DUMP',@Remarks, @centralEmail)

	
	update SE_Notification set SUBJECT='RAW DUMP - ' + Ref_Type, Body=Remarks, ToEmail=@centralEmail where Status_Type in (1,2) and coalesce(body,'')=''

end
else
begin

INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(@Status_Type, @Ref_No , @Ref_Type , @CSS_Id ,@User_Id,@User_Type,@Remarks, @Action ,@Created_User, GETDATE(),DAteadd(d,3,GETDATE()),1)

end

END
