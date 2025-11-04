-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_HBN_Repeat_Call_Fix]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
Begin -- Start SP

IF OBJECT_ID(N'dbo.HBN_RepeatCalls', N'U') IS NOT NULL  
   delete from  [dbo].HBN_RepeatCalls; 
insert into
HBN_RepeatCalls (Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,First_Assigned_DateTime, IsMaterialUsed, Work_Order_Type, Work_Performed) 
select Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,  CAST(First_Assigned_DateTime AS DATE), IsMaterialUsed, Work_Order_Type, Work_Performed
from HBN_Work_Order 
where IP_Serial_Number in
(select IP_Serial_Number
from HBN_Work_Order
group by IP_Serial_Number
having count(*) > 1) 


update HBN_RepeatCalls
set Calls = 0

SELECT 
  Work_Order_number , IP_Serial_Number,First_Assigned_DateTime,
  RANK() OVER (PARTITION BY IP_Serial_Number
                    ORDER BY First_Assigned_DateTime asc
                    ) AS cals
 into HBN_Repeate_rank_Call FROM HBN_RepeatCalls;


update HBN_RepeatCalls
set Calls = HRC.cals
from HBN_Repeate_rank_Call HRC
inner join 
HBN_RepeatCalls HR
on 
HR.Work_Order_Number = HRC.Work_Order_Number

drop table HBN_Repeate_rank_Call



update HBN_Work_Order
Set Claim = CASE  WHEN RC.Calls / 2 =  0 THEN  0    END        
                
from 
HBN_RepeatCalls RC
inner join 
HBN_Work_Order WO
on
RC.Work_Order_Number = WO.Work_Order_Number

and WO.IsMaterialUsed  = 0



end
END

