-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE [dbo].[SP_HBN_Repeat_Call_Mapping_26042022]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN


Begin
IF OBJECT_ID(N'dbo.HBN_Repeat_Calls', N'U') IS NOT NULL  
   delete from  [dbo].HBN_Repeat_Calls 
insert into HBN_Repeat_Calls
(Work_Order_Number, 
IP_Serial_Number, 
Completed_On , 
First_Assigned_DateTime,
IsMaterialUsed,
Work_Order_Type,
Work_Order_Sub_Type,
Work_Performed,
Service_Team,
claim)
select Work_Order_Number, 
IP_Serial_Number, 
Completed_On , 
First_Assigned_DateTime,
IsMaterialUsed,
Work_Order_Type,
Work_Order_Sub_Type,
Work_Performed,
Service_Team,
claim
from HBN_Work_Order 


Declare @last_month as nvarchar(2)

select @last_month = Max(WO_Month) from SE_Work_Order

if @last_month = 1 
begin 
set @last_month = 12
End
else
if @last_month > 1
begin
set @last_month = @last_month -1
end


--Print @last_month

insert into HBN_Repeat_Calls
(Work_Order_Number, 
IP_Serial_Number, 
Completed_On , 
First_Assigned_DateTime,
IsMaterialUsed,
Work_Order_Type,
Work_Order_Sub_Type,
Work_Performed,
Service_Team,
claim)
select Work_Order_Number, 
IP_Serial_Number, 
Completed_On , 
First_Assigned_DateTime,
IsMaterialUsed,
Work_Order_Type,
Work_Order_Sub_Type,
Work_Performed,
Service_Team,
claim
 from SE_Work_Order where IP_Serial_Number in (Select IP_Serial_Number from HBN_Work_Order) and WO_Month = @last_month 


SELECT 
  Work_Order_number , IP_Serial_Number,First_Assigned_DateTime,Service_Team,
  RANK() OVER (PARTITION BY IP_Serial_Number,Service_Team
                    ORDER BY    Service_Team asc,First_Assigned_DateTime asc
                    ) AS Call_Rank
  into HBN_Repeate_rank_Call FROM HBN_Repeat_Calls order by Service_Team asc,  First_Assigned_DateTime asc




 update HBN_Repeat_Calls
set Days = 0,
Call_Rank = 0,
Call_Rank_Claim = 0


update HBN_Repeat_Calls
set Call_Rank = HRC.Call_Rank,
 Call_Rank_Claim = HRC.Call_Rank
from HBN_Repeate_rank_Call HRC
inner join 
HBN_Repeat_Calls HR
on 
HR.Work_Order_Number = HRC.Work_Order_Number

drop table HBN_Repeate_rank_Call

---- Find last call assigned date

update HBN_Repeat_Calls
set 
First_Call_Completed_Date =  t.Min_First_Assigned_Date--CONVERT(DATETIME,t.Min_First_Assigned_Date,121)  --try_CONVERT(DATETIME,t.Min_First_Assigned_Date,121) -- CONVERT(DATETIME,t.Max_Assigned_Date,105) 
from HBN_Repeat_Calls
join 
(
    select  IP_Serial_Number, min(Completed_On) as Min_First_Assigned_Date 
    from HBN_Repeat_Calls
    group by IP_Serial_Number  
) t
on HBN_Repeat_Calls.IP_Serial_Number= t.IP_Serial_Number 



update HBN_Repeat_Calls
set Days = DATEDIFF(day, try_CONVERT(DATETIME,First_Assigned_DateTime,105) , try_CONVERT(DATETIME,First_Call_Completed_Date,105) )
where Call_Rank = 2

update 
HBN_Repeat_Calls
Set Call_Rank_claim = 1
Where Days > 30 and Call_Rank = 2




update HBN_Repeat_Calls
set Claim = 0
where Call_Rank_Claim > 1 
and  IsMaterialUsed = 0
and Work_Order_Sub_Type not like '%Battery Installation%' 
and Work_Order_Sub_Type not like '%Regular Preventive Maintenance%'

--select * from HBN_Repeat_Calls
--where Call_Rank_Claim > 1 
--and  IsMaterialUsed = 0
--and Work_Order_Sub_Type  like '%Battery Installation%' 
--or Work_Order_Sub_Type  like '%Regular Preventive Maintenance%' 

--select Distinct Work_Order_Sub_Type from HBN_Repeat_Calls

update HBN_Work_Order
Set
Claim = RC.Claim
from 
HBN_Repeat_Calls RC
inner join 
HBN_Work_Order WO
on
RC.Work_Order_Number = WO.Work_Order_Number


--select Work_Order_Number,IP_Serial_Number,Service_team,Work_Order_Sub_Type, IsMaterialUsed,Claim, days, Call_Rank_claim, Call_Rank, First_Call_Completed_Date,Completed_On 
--from HBN_Repeat_Calls Where claim is not null and Claim not like 0  order by IP_Serial_Number desc

--select Work_Order_Number,IP_Serial_Number,Service_team,Work_Order_Sub_Type, IsMaterialUsed,Claim, Completed_On , WO_Month
--from HBN_Work_Order where Work_Order_Number like 'WO-09224958' order by IP_Serial_Number desc

--select * from HBN_Repeat_Calls

--delete from HBN_Repeat_Calls
--Where Work_Order_Number is null
--EXEC SP_HBN_Repeat_Call_Mapping_26042022

--select IP_Serial_Number,* from HBN_Work_Order where IP_Serial_Number is null

End

END