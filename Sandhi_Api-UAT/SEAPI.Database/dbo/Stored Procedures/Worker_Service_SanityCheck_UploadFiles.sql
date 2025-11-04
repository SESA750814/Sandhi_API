-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[Worker_Service_SanityCheck_UploadFiles]
@Return_status int output,
@Ref_No nvarchar(200)
	
AS

BEGIN
	
	begin try

	Declare @W_month  nvarchar(2)
Declare @W_Year nvarchar(4)
Declare @Process_Status bigint


IF OBJECT_ID(N'dbo.Find_Month', N'U') IS NOT NULL 
begin
    Drop table Find_Month
end

IF OBJECT_ID(N'dbo.Find_Year', N'U') IS NOT NULL  
begin
    Drop table Find_Year
End
-- for Developer Edition

--select  month(format(try_convert(datetime2,WO_Completed_Timestamp,103),'dd/MM/yyyy')) as mmonth, count(month(format(try_convert(datetime2,WO_Completed_Timestamp,103),'dd/MM/yyyy'))) as mcount into Find_Month from RAW_DUMP_Expense
--group by month(format(try_convert(datetime2,WO_Completed_Timestamp,103),'dd/MM/yyyy'))

select  month(format(try_convert(date,WO_Completed_Timestamp,103),'dd/MM/yyyy')) as mmonth, count(month(format(try_convert(date,WO_Completed_Timestamp,103),'dd/MM/yyyy'))) as mcount into Find_Month from RAW_DUMP_Expense
group by month(format(try_convert(date,WO_Completed_Timestamp,103),'dd/MM/yyyy'))


select top 1 @W_month = mmonth from Find_Month where mmonth is not null order by mcount desc


-- Developer Edition
--select  year(format(try_convert(datetime2,WO_Completed_Timestamp,103),'dd/MM/yyyy')) as yyear, count(month(format(try_convert(datetime2,WO_Completed_Timestamp,103),'dd/MM/yyyy'))) as ycount into Find_Year from RAW_DUMP_Expense
--group by year(format(try_convert(datetime2,WO_Completed_Timestamp,103),'dd/MM/yyyy'))


select  year(format(try_convert(date,WO_Completed_Timestamp,103),'dd/MM/yyyy')) as yyear, count(year(format(try_convert(date,WO_Completed_Timestamp,103),'dd/MM/yyyy'))) as ycount into Find_Year from RAW_DUMP_Expense
group by year(format(try_convert(date,WO_Completed_Timestamp,103),'dd/MM/yyyy'))

select top 1 @W_Year = yyear from Find_Year where yyear is not null order by ycount desc



delete from Month_year

INSERT INTO [dbo].[Month_Year]
           ([cmonth]
           ,[cyear])
     VALUES
           (@W_month
           ,@W_Year)

	declare @check nvarchar(max)
	
	--set @Return_status = 0
	set @check='OK'

	select @check = Product_Commercial_Reference from RAW_DUMP_Expense 
	   Where Is_Billable like 'NO'
		   and Work_Order_Status like  '%8- Service Completed%'
			or Work_Order_Status like  '%9- Service Validated%'
			or Work_Order_Status like  '%10- Closed%'
	group by Product_Commercial_Reference having max(len(Product_Commercial_Reference)) > 50

	Print @check

	if  @check <> 'OK' 
	begin	
		set @check = 'Uploading Issue File: RAW_DUMP_Expense :  Product_Commercial_Reference Lenth limit exceeded ' + @check
		INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(2, @Ref_No , 'Check Files ' , null, null, 1, @check, 'XLS DB Push and Rate Mapping Process' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)

		set @Return_status = 1
		
	end
	else
	begin
	set @Return_status = 0	
	end
	



select @Process_Status = WO_Process_Status from SE_Work_Order
where WO_Month = @W_month and WO_Year = @W_Year 


-- Check for File rejected by central team
if (@Process_Status = 1)
begin
Delete from SE_Work_Order_Status where work_order_id in (Select id from SE_Work_Order where WO_Month = @W_month and WO_Year = @W_Year )

Delete from SE_Work_Order where WO_Month = @W_month and WO_Year = @W_Year

set @check = 'Rejected and reloading for month :' + @W_month +' Year : '+ @W_Year
INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(2,@Ref_No , 'Worker Service' , null, null, 1, @check, 'XLS DB Push and Rate Mapping Process' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)

set @Return_status = 0

end

-- --Check month data already there
--if (@Process_Status <> 1)
--begin
--if (@Process_Status  <> '') or (@Process_Status is not null) 
--begin
--set @check = 'Uploading Issue : Files already in process month : ' + @W_month +' Year : '+ @W_Year
--INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
--									    VALUES(2, @Ref_No , 'Check Files ' , null ,null,1, @check, 'XLS DB Push and Rate Mapping Process' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)

--set @Return_status = 1

--end
--else
--begin
--set @Return_status = 0
--end
--end



end try
begin catch 


INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(2, @Ref_No , 'Validate Dump Files ' , null ,null,1, ERROR_MESSAGE(), 'XLS DB Push and Rate Mapping Process' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)


set @Return_status = 1
end catch





--update SE_Work_Order
--set 
--WO_Process_Status = 1
--where WO_Month = 9

----delete from SE_Work_Order_Status
----delete from SE_Work_Order
	
	   
END

