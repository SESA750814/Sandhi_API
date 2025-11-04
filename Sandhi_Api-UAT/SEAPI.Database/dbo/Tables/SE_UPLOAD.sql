CREATE TABLE [dbo].[SE_UPLOAD] (
    [Id]             VARCHAR (MAX) NOT NULL,
    [UPLOAD_TYPE]    VARCHAR (100) NOT NULL,
    [CREATED_DATE]   DATETIME      NOT NULL,
    [PROCESSED_DATE] DATETIME      NULL,
    [REMARKS]        VARCHAR (100) NULL,
    [Is_SUCCESS]     BIT           CONSTRAINT [DF__SE_UPLOAD__Is_SU__577DE488] DEFAULT ((0)) NOT NULL
);


GO

create TRIGGER Insert_Raw_Dumps
ON dbo.SE_UPLOAD
AFTER INSERT
AS
BEGIN

	exec SP_All_Start_Process_Rate_Mapping

	declare @Cdate datetime;
	select @Cdate = max(CREATED_DATE)  from SE_UPload 
	   
	update SE_UPLOAD
	set 
	Is_SUCCESS = 1,
	PROCESSED_DATE = GETDATE(),
	REMARKS = 'Rate Mapping Process Done Successfully'
	where 
	CREATED_DATE = @Cdate

END
