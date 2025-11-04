-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <17-12-2021,,>
-- Description:	<PSI Work Order Process,,>
-- =============================================

-- exec SP_PSI_Repeat_Call_Rate_Mapping
CREATE procedure [dbo].[SP_PSI_Repeat_Call_Rate_Mapping]
	-- Add the parameters for the stored procedure here
AS
BEGIN

update 
dbo.PSI_Work_Order
SET
IsMaterialUsed = 1
Where
Work_Performed like '%Replace%'
or Work_Performed like '%Replaced%' 
or Work_Performed like '%Change%'
or Work_Performed like '%Changed%'
or Work_Performed like '%Replac%'
or Work_Performed like '%Reaplac%'
or Work_Performed like '%not replac%'
or Work_Performed like '%not replaced%'

-- Find Repeate Calls more than 1
IF OBJECT_ID(N'dbo.PSI_RepeatCalls', N'U') IS NOT NULL  
   delete from  [dbo].PSI_RepeatCalls; 
insert into
PSI_RepeatCalls (Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,First_Assigned_DateTime, IsMaterialUsed, Work_Order_Type, Work_Performed) 
select Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,First_Assigned_DateTime, IsMaterialUsed, Work_Order_Type, Work_Performed 
FROM PSI_Work_Order 
where IP_Serial_Number in
(select IP_Serial_Number
from PSI_Work_Order
group by IP_Serial_Number
having count(*) > 1) and IsMaterialUsed not like 1 

-- Find back in 30 days date from last call assigned Date
begin

update PSI_RepeatCalls
set 
Date_Back_30_Days = try_CONVERT(DATETIME,t.Max_Assigned_Date,121) - 30 
from PSI_RepeatCalls
join 
(
    select  IP_Serial_Number, Max(First_Assigned_DateTime) as Max_Assigned_Date 
    from PSI_Work_Order
    group by IP_Serial_Number  
) t
on PSI_RepeatCalls.IP_Serial_Number= t.IP_Serial_Number and  PSI_RepeatCalls.IP_Serial_Number is not null

end 

---- Find last call assigned date

update PSI_Work_Order
set 
Date_last_call_Assigned = try_CONVERT(DATETIME,t.Max_Assigned_Date,121)
from PSI_Work_Order
join 
(
    select  IP_Serial_Number, Max(First_Assigned_DateTime) as Max_Assigned_Date 
    from PSI_Work_Order
    group by IP_Serial_Number  
) t
on PSI_Work_Order.IP_Serial_Number= t.IP_Serial_Number and  PSI_Work_Order.IP_Serial_Number is not null

-- Delete WO falls before 30 days

Delete from PSI_RepeatCalls where  try_CONVERT(DATETIME,WO_Completed_Timestamp,121) < Date_Back_30_Days

-- set all repeat calls as 2
update PSI_RepeatCalls 
set calls = 2

-- Update RepeatCalls set First Call as 1

update 
PSI_RepeatCalls
set calls = 1
where Work_Order_Number  in 
(select PSI_RepeatCalls.Work_Order_Number
from PSI_RepeatCalls
join 
(
    select  IP_Serial_Number, min(WO_Completed_Timestamp) as Min_Completed_Date 
    from PSI_Work_Order
    group by IP_Serial_Number  
) t
on PSI_RepeatCalls.IP_Serial_Number= t.IP_Serial_Number and PSI_RepeatCalls.WO_Completed_Timestamp = t.Min_Completed_Date) 



-- update work order set claim 0 for not as first call
update PSI_Work_Order
Set
Claim = 0,
Is_RepeatCall_NonMeterial = 1
from 
PSI_RepeatCalls RC
inner join 
PSI_Work_Order WO
on
RC.Work_Order_Number = WO.Work_Order_Number
and RC.Calls not like 1

End
