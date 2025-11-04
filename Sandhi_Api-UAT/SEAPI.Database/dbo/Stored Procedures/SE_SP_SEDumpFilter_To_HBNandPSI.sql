-- =============================================
-- Author:		<Muthukrishnan Marimuthu,,Name>
-- Create date: <Create Date,,>
-- Description:	<Parse Raw Dump file  into HBN, PSI and Cooling>
-- =============================================
CREATE procedure [dbo].[SE_SP_SEDumpFilter_To_HBNandPSI]
	
AS
BEGIN


IF OBJECT_ID(N'dbo.HBN_RAW_DUMP', N'U') IS NOT NULL  
    Drop table HBN_RAW_DUMP
	IF OBJECT_ID(N'dbo.PSI_RAW_DUMP', N'U') IS NOT NULL  
	Drop table PSI_RAW_DUMP
	IF OBJECT_ID(N'dbo.Cooling_RAW_DUMP', N'U') IS NOT NULL  
	Drop table Cooling_RAW_DUMP
	

      SELECT * INTO HBN_RAW_DUMP from [RAW_DUMP_Expense] where Service_team  like '%HBN%' 
	  SELECT * INTO PSI_RAW_DUMP from [RAW_DUMP_Expense] where Service_team  like '%ED&I%' 
	  SELECT * INTO Cooling_RAW_DUMP from [RAW_DUMP_Expense] where Service_team  like '%Cooling%' 

	  Declare @countHBN bigint
	  Select @countHBN = Count(*) from HBN_RAW_DUMP
	  if @countHBN = 0 
	  INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(2, 111 , 'Check Files ' , null ,null,1, 'Excell Data', 'Error : No Data pushed: HBN Data have issues  Please check service team column Excell Dump Columns' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)

	  
	  Declare @countPSI bigint
	  Select @countPSI = Count(*) from PSI_RAW_DUMP
	  if @countPSI = 0 
	   INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(2, 222 , 'Check Files ' , null ,null,1, 'Excell Data', 'Error : No Data pushed: PPI Data have issues  Please check service team column Excell Dump Columns' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)

	  
	  Declare @countCooling bigint
	  Select @countCooling = Count(*) from Cooling_RAW_DUMP
	  if @countCooling = 0 
	    INSERT INTO [dbo].[SE_Notification]  ([Status_Type]  ,[Ref_No]  ,[Ref_Type]  ,[CSS_Id] ,[User_Id]  ,[User_Type]  ,[Remarks]   ,[Action]  ,[Created_User]  ,[Created_Date] ,[Expiry_Date]    ,[IsActive])  
									    VALUES(2, 333 , 'Check Files ' , null ,null,1, 'Excell Data', 'Error : No Data pushed: Cooling Data have issues  Please check service team column Excell Dump Columns' ,'Worker Service', GETDATE(),Dateadd(dd,1,GETDATE()),1)




END

