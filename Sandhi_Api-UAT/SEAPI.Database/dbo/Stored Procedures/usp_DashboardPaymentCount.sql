--select * from se_Css_invoice 
CREATE procedure		[dbo].[usp_DashboardPaymentCount]
	@groupBy			Varchar(max) = 'BusinessUnit',
	@cssManagerUserId	varchar(max) = null,
	@finUserId			Varchar(max) = null,
	@grnUserId			Varchar(max) = null,
	@cssId				Varchar(max) = null
	
AS
begin
-- exec usp_DashboardPaymentCount 'BusinessUnit'
declare @prfRaised int = 8
Declare @awaitingPO int =9
declare @invoiceRaised int = 10
declare @invoiceValidated int = 11
declare @invoiceRejected int = 12
declare @grnClarification int = 13
declare @grnRaised int = 14
declare @invoicePaid int = 15
declare @businessUnit			varchar(max)
Create Table #tmpPayment
(
	Ordinal				int				not null,
	HeaderTyp			Varchar(max)	not null,
	Region				Varchar(max)	null,
	Cooling_Month1		int				null,
	Cooling_Month2		int				null,
	Cooling_Month3		int				null,
	HBN_Month1			int				null,
	HBN_Month2			int				null,
	HBN_Month3			int				null,
	PPI_Month1			int				null,
	PPI_Month2			int				null,
	PPI_Month3			int				null
)

--declare @groupBy			varchar(max)
--set @groupBy =''
--select DATEADD(month, DATEDIFF(month, 0, getdate()), 0), DATEADD(month, DATEDIFF(month, 0, getdate())+1, 0)

select *  into #tmpTypes from (
		Select 1 as Ordinal, 'TOTAL CSS' as Typ
		union
		SELECT 2 as Ordinal, 'INVOICE SUBMITTED'
		UNION
		SELECT 3, 'INVOICE PENDING'
		UNION
		SELECT 4, 'INVOICE PAID'
		UNION
		SELECT 5, 'INVOICE NOT PAID'
		UNION
		SELECT 6, 'INVOICE PAID <= 45 DAYS'
) a



insert into #tmpPayment (Ordinal, HeaderTyp, Region)
Select 
	distinct b.Ordinal, b.TYP as HeaderTyp, Case when @groupBy='Region' then region else '' end as Region 
from 
	SE_CSS_MASTER a
	--inner join se_css_invoice b on a.id = b.css_id and b.inv_Date >=  dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
	inner join #tmpTypes b ON 1=1
WHERE
	a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end
	and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end
	and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
	and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
order by ordinal, region

--

DECLARE BU_CURSOR CURSOR FOR
Select distinct wo_businessunit from SE_CSS_INVOICE where inv_date >= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))

OPEN BU_CURSOR 
FETCH NEXT FROM BU_CURSOR INTO @businessUnit
WHILE @@FETCH_STATUS=0
BEGIN
	Declare @region		Varchar(max)
	Declare REGION_CURSOR CURSOR FOR
	SELECT distinct region from #tmpPayment

	OPEN REGION_CURSOR
	FETCH NEXT FROM REGION_CURSOR INTO @region
	WHILE @@FETCH_STATUS=0
	BEGIN
		declare @i int = 0
		WHILE (@i<3)
		begin
			declare @ordinal			int = 1
			while (@ordinal<7)
			begin		
				declare @count				int=0
				if(@ordinal=1)
				begin
					select
						 @count= count(distinct css_id)
					From
						Se_Css_invoice a
						inner join se_css_master b on a.css_id = b.id 
					where
						INV_DATE>= dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and inv_date <=dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and WO_BUSINESSUNIT=@businessUnit
						and b.region = CASE WHEN @region <>'' then @region else b.region end
						and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
						and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
						and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
						and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
					group by month_name, WO_BUSINESSUNIT, CASE WHEN @region <>'' then REGION else '' end	 
				end
				else if(@ordinal=2)
				begin
					select
						 @count= count(inv_no)
					From
						Se_Css_invoice  a
						inner join se_css_master b on a.css_id = b.id 
					where
						INV_DATE>= dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and inv_date <=dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and WO_BUSINESSUNIT=@businessUnit
						and b.region = CASE WHEN @region <>'' then @region else b.region end
						and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
						and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
						and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
						and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
					group by month_name, WO_BUSINESSUNIT, CASE WHEN @region <>'' then REGION else '' end	
				end
				else if(@ordinal=3)
				begin
					select
						 @count= count(inv_no)
					From
						Se_Css_invoice  a
						inner join se_css_master b on a.css_id = b.id 
					where
						INV_DATE>= dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and inv_date <=dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and WO_BUSINESSUNIT=@businessUnit
						and b.region = CASE WHEN @region <>'' then @region else b.region end
						and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
						and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
						and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
						and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
						and Status_Type=@invoiceRaised
					group by month_name, WO_BUSINESSUNIT, CASE WHEN @region <>'' then REGION else '' end		
				end
				else if(@ordinal=4)
				begin
					select
						 @count= count(inv_no)
					From
						Se_Css_invoice a
						inner join se_css_master b on a.css_id = b.id 
					where
						INV_DATE>= dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and inv_date <=dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and WO_BUSINESSUNIT=@businessUnit
						and b.region = CASE WHEN @region <>'' then @region else b.region end
						and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
						and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
						and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
						and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
						and Status_Type=@invoicePaid
					group by month_name, WO_BUSINESSUNIT, CASE WHEN @region <>'' then REGION else '' end	
				end
				else if(@ordinal=5)
				begin
					select
						 @count= count(inv_no)
					From
						Se_Css_invoice a
						inner join se_css_master b on a.css_id = b.id 
					where
						INV_DATE>= dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and inv_date <=dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and WO_BUSINESSUNIT=@businessUnit
						and b.region = CASE WHEN @region <>'' then @region else b.region end
						and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
						and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
						and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
						and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
						and Status_Type<@invoicePaid and Status_type >= @invoiceRaised
					group by month_name, WO_BUSINESSUNIT, CASE WHEN @region <>'' then REGION else '' end		
				end
				else if(@ordinal=6)
				begin
					select
						 @count= count(inv_no)
					From
						Se_Css_invoice  a
						inner join se_css_master b on a.css_id = b.id 
					where
						INV_DATE>= dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and inv_date <=dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
						and WO_BUSINESSUNIT=@businessUnit
						and b.region = CASE WHEN @region <>'' then @region else b.region end
						and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
						and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
						and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
						and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
						and Status_Type=@invoicePaid 
						and  DATEDIFF(dd,INV_DATE, INV_PAID_DATE) <= 45
					group by month_name, WO_BUSINESSUNIT, CASE WHEN @region <>'' then REGION else '' end			
				end
				declare @sql		varchar(max)=''
				set @sql = 'Update #tmpPayment set ' + @businessUnit + '_Month' + convert(Varchar(20),(@i+1)) + '=' + convert(Varchar(20),@count) + ' where ordinal=' + Convert(Varchar(10),@ordinal) +' and region=''' + @region + ''''
				exec (@sql)
				set @ordinal = @ordinal + 1 
			end

				--select  dateadd(m,-1 * @i,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) as FromDate, @i as I
				--select  dateadd(m,(-1 * @i)+1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) as ToDate, @i as I

			print @i
			set @i=@i+1
		end
		
	FETCH NEXT FROM REGION_CURSOR INTO @region
	END
	CLOSE REGION_CURSOR
	DEALLOCATE REGION_CURSOR
	
FETCH NEXT FROM BU_CURSOR INTO @businessUnit
end
CLOSE BU_CURSOR
DEALLOCATE BU_CURSOR


select ordinal, headertyp, region, coalesce(cooling_month1,0) as Cooling_Month1, coalesce(cooling_month2,0) as Cooling_Month2, coalesce(cooling_month3,0) as Cooling_Month3, 
coalesce(HBN_month1,0) as HBN_Month1, coalesce(HBN_month2,0) as HBN_Month2, coalesce(HBN_month3,0) as HBN_Month3,
coalesce(PPI_month1,0) as PPI_Month1, coalesce(PPI_month2,0) as PPI_Month2, coalesce(PPI_month3,0) as PPI_Month3
from #tmpPayment

select 
	a.CSS_Code, a.css_name, a.WO_BUSINESSUNIT, a.Region	, 
	coalesce(Month1.Month1Count,0) as Month1Count, coalesce(Month2.Month2Count,0) as Month2Count, Coalesce(Month3.Month3Count,0) as Month3Count 
from 
	(
		Select 
			distinct b.css_code, b.CSS_Name_as_per_Oracle_SAP as Css_Name, a.WO_BUSINESSUNIT, b.Region, a.css_id 
		from 
			se_css_invoice a
			inner join se_Css_master b on a.css_id = b.id 
		 where 
			inv_date >= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
			and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end
			and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end
			and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
			and b.id = case when coalesce(@cssId,'')='' then b.Id else @cssId end
	) a 
	left outer join 
	(		
		select
			css_id, WO_BUSINESSUNIT, count(INV_NO) as Month1Count
		From
			Se_Css_invoice 
		where
			INV_DATE>= dateadd(m,0,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
			and inv_date <=dateadd(m,1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
		group by css_id, WO_BUSINESSUNIT
	) Month1 on a.css_id = Month1.css_id and a.WO_BUSINESSUNIT = month1.WO_BUSINESSUNIT
	left outer join 
	(		
		select
			css_id, WO_BUSINESSUNIT, Count(Inv_No) as Month2Count
		From
			Se_Css_invoice 
		where
			INV_DATE>= dateadd(m,-1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
			and inv_date <=dateadd(m,0,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
		group by css_id, WO_BUSINESSUNIT
	) Month2 on a.css_id = Month2.css_id and a.WO_BUSINESSUNIT = Month2.WO_BUSINESSUNIT
	left outer join 
	(		
		select
			css_id, WO_BUSINESSUNIT,Count(Inv_No) as Month3Count
		From
			Se_Css_invoice 
		where
			INV_DATE>= dateadd(m,-2,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
			and inv_date <=dateadd(m,-1,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
		group by css_id, WO_BUSINESSUNIT
	) Month3 on a.css_id = Month3.css_id and a.WO_BUSINESSUNIT = Month3.WO_BUSINESSUNIT

--select
--	1 as ordinal, 'Total CSS', datename(month,inv_Date), WO_BUSINESSUNIT,region, count(distinct css_id)
--From
--	Se_Css_invoice a
--	inner join se_Css_master b on b.id = a.css_id 
--where
--	INV_DATE>= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
--group by datename(month,inv_Date),WO_BUSINESSUNIT, region
--union
--select 
--	2, 'Invoice Submitted', month_name, wo_businessunit, count(inv_no) 
--from 
--	Se_Css_invoice 
--where
--	INV_DATE>= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
--group by month_name, WO_BUSINESSUNIT
--union
--select 
--	3, 'Invoice Pending', month_name, wo_businessunit, count(inv_no) 
--from 
--	Se_Css_invoice 
--where
--	INV_DATE>= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
--	and Status_Type=@invoiceRaised
--group by month_name, WO_BUSINESSUNIT
--union
--select 
--	4, 'Invoice Paid', month_name, wo_businessunit, count(inv_no) 
--from 
--	Se_Css_invoice 
--where
--	INV_DATE>= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
--	and Status_Type=@invoicePaid
--group by month_name, WO_BUSINESSUNIT
--union
--select 
--	5, 'Invoice Not Paid', month_name, wo_businessunit, count(inv_no) 
--from 
--	Se_Css_invoice 
--where
--	INV_DATE>= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
--	and Status_Type<@invoicePaid and Status_type >= @invoiceRaised
--group by month_name, WO_BUSINESSUNIT
--union
--select 
--	6, 'Invoice Paid<=45 days', month_name, wo_businessunit, count(inv_no)
--from 
--	Se_Css_invoice 
--where
--	INV_DATE>= dateadd(m,-3,DATEADD(month, DATEDIFF(month, 0, getdate()), 0))
--	and Status_Type=15
--	and  DATEDIFF(dd,INV_DATE, INV_PAID_DATE) <= 45
--group by month_name, WO_BUSINESSUNIT
--order by WO_BUSINESSUNIT, ordinal
----select * from SE_CSS_INVOICE

end
