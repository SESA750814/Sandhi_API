-- =============================================
-- Author:		<Muthu,KGS>
-- Create date: <06-11-2021,,> Modified 24032022
-- Description:	<HBN Work Order Process,,>
-- =============================================

--exec SP_HBN_Repeat_Call_Rate_Mapping
CREATE procedure [dbo].[SP_HBN_Repeat_Call_Rate_Mapping]
	-- Add the parameters for the stored procedure here
AS
BEGIN
-- Find Repeate Calls more than 1
IF OBJECT_ID(N'dbo.HBN_RepeatCalls', N'U') IS NOT NULL  
   delete from  [dbo].HBN_RepeatCalls; 
insert into
HBN_RepeatCalls (Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,First_Assigned_DateTime, IsMaterialUsed, Work_Order_Type, Work_Performed) 
select Work_Order_Number, IP_Serial_Number, WO_Completed_Timestamp,First_Assigned_DateTime, IsMaterialUsed, Work_Order_Type, Work_Performed 
from HBN_Work_Order 
where IP_Serial_Number in
(select IP_Serial_Number
from HBN_Work_Order
group by IP_Serial_Number
having count(*) > 1) and IsMaterialUsed not like 1 

-- Find back in 30 days date from last call assigned Date
begin

update HBN_RepeatCalls
set 
--Date_Back_30_Days =  dateadd(day,-30,cast(t.Max_Assigned_Date as date) ) -- CONVERT(DATETIME,t.Max_Assigned_Date,105) - 30

Date_Back_30_Days = try_CONVERT(DATETIME,t.Max_Assigned_Date,121) - 30

from HBN_RepeatCalls
join 
(
    select  IP_Serial_Number, Min(First_Assigned_DateTime) as Max_Assigned_Date 
    from HBN_Work_Order
    group by IP_Serial_Number  
) t
on HBN_RepeatCalls.IP_Serial_Number= t.IP_Serial_Number and  HBN_RepeatCalls.IP_Serial_Number is not null


end 

---- Find last call assigned date

update HBN_RepeatCalls
set 
Date_last_call_Assigned = try_CONVERT(DATETIME,t.Max_Assigned_Date,121) -- CONVERT(DATETIME,t.Max_Assigned_Date,105) 
from HBN_RepeatCalls
join 
(
    select  IP_Serial_Number, Max(First_Assigned_DateTime) as Max_Assigned_Date 
    from HBN_Work_Order
    group by IP_Serial_Number  
) t
on HBN_RepeatCalls.IP_Serial_Number= t.IP_Serial_Number and  HBN_RepeatCalls.IP_Serial_Number is not null

-- Delete WO falls before 30 days

Delete from HBN_RepeatCalls where try_CONVERT(DATETIME,WO_Completed_Timestamp,121)  < Date_Back_30_Days

-- set all repeat calls as 2
update HBN_RepeatCalls 
set calls = 2

-- Update RepeatCalls set First Call as 1

update 
HBN_RepeatCalls
set calls = 1
where Work_Order_Number  in 
(select HBN_RepeatCalls.Work_Order_Number
from HBN_RepeatCalls
join 
(
    select  IP_Serial_Number, max(WO_Completed_Timestamp) as Min_Completed_Date 
    from HBN_Work_Order
    group by IP_Serial_Number  
) t
on HBN_RepeatCalls.IP_Serial_Number= t.IP_Serial_Number and HBN_RepeatCalls.WO_Completed_Timestamp = t.Min_Completed_Date) 



-- update work order set claim 0 for not as first call
update HBN_Work_Order
Set
Claim = 0,
Is_RepeatCall_NonMeterial = 1
from 
HBN_RepeatCalls RC
inner join 
HBN_Work_Order WO
on
RC.Work_Order_Number = WO.Work_Order_Number
and RC.Calls not like 1
and WO.IsMaterialUsed  not like 1

End
