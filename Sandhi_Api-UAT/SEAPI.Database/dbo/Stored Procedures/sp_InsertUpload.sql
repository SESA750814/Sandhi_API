CREATE Procedure [dbo].[sp_InsertUpload]
	@uploadType			VArchar(max),
	@gid				Varchar(max)
as
BEGIN
-- Call the Sanity Check Stored Proc
   
	exec sp_Sanitycheck @gid =  @gid

	Declare @errorCount	bigint
	Select @errorCount=count(*) from SE_UPLOAD_ERRORS where [id] =@gid
	
	if(@errorCount=0)
	BEGIN	
	insert into SE_upload 
	(id,UPLOAD_TYPE,CREATED_DATE,PROCESSED_DATE,REMARKS,Is_SUCCESS) values
	(@gid,@uploadType,GETDATE(),GETDATE(),'Process Started',0)
	
	END
END
