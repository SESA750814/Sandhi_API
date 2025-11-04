CREATE PROCEDURE [dbo].[SP_Sanitycheck]	
	@gid				Varchar(max)
AS
BEGIN
	

	declare @check nvarchar(max)

	select @check = Product_Commercial_Reference from RAW_DUMP_Expense 
	   Where Is_Billable like 'NO'
		   and Work_Order_Status like  '%8- Service Completed%'
			or Work_Order_Status like  '%9- Service Validated%'
			or Work_Order_Status like  '%10- Closed%'
	group by Product_Commercial_Reference having max(len(Product_Commercial_Reference)) > 50

	if  @check <> ''
	begin
	set @check = 'Uploading Issue :  Product_Commercial_Reference Lenth limit exceeded ' + @check
	insert into SE_upload_Errors 
	(id,File_Name,Error_Information,TimeStamp) values
	(@gid,'RAW_DUMP_Expense',@check,GETDATE())
	 raiserror(@check, 11, 0)
	end
	
	   
END
