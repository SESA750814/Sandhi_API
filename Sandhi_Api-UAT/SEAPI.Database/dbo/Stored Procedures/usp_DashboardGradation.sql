CREATE procedure [dbo].[usp_DashboardGradation]
	@fromDate			DateTime,
	@toDate				DateTime,
	@region				Varchar(max) = null,
	@businessUnit		Varchar(max) = null,
	@groupBy			Varchar(max) = 'BusinessUnit',
	@cssManagerUserId	varchar(max) = null,
	@finUserId			Varchar(max) = null,
	@grnUserId			Varchar(max) = null,
	@cssId				Varchar(max) = null
AS
Begin
--exec usp_DashboardGradation '2022/01/12','2022/01/12',null, null,'BusinessUnit'
--Declare @fromDate		DateTime  = '01/12/2022'
--Declare @toDate			DateTime  = '01/22/2022'
--select convert(Decimal(18,0),8)/convert(Decimal(18,0),22) * 100
CREATE TABLE #tmpGroup
(
	Region			Varchar(max),
	BusinessUnit	Varchar(max),
	Month_Name		Varchar(max),
	TOTAL_CSS		bigint,
	Grade_text		varchar(100),
	Final_Grade		int,
	SRS_Grade		int,
	SRS_Percentage	decimal(18,2),
	NSS_Grade		int,
	NSS_Percentage	decimal(18,2),
	CSR_Grade		int,
	CSR_Percentage	decimal(18,2),
	WOR_Grade		int,
	WOR_Percentage	decimal(18,2),
	MTTR_Grade		int,
	MTTR_Percentage	decimal(18,2),
	PMC_Grade		int,
	PMC_Percentage	decimal(18,2),
	DFR_HBN_Grade	int,
	DFR_HBN_Percentage 	decimal(18,2),
	DFR_PPI_GRADE	int,
	DFR_PPI_Percentage	decimal(18,2),
	NPF_Grade		int,
	NPF_Percentage	decimal(18,2),
	ATTR_GRADE		int,
	ATTR_Percentage	decimal(18,2),
	FRS_Grade		int,
	FRS_Percentage	decimal(18,2),
	Lead_Grade		int,
	Lead_Percentage	decimal(18,2),
	IB_Grade		int,
	IB_Percentage	decimal(18,2)
)
select 
	a.css_code, a.CSS_Name_as_per_Oracle_SAP as Css_Name, a.region, a.Business_Unit, 
	DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name, b.FINAL_GRADE,
	b.SRS_GRADE, b.NSS_GRADE, b.CSR_GRADE, b.wor_grade, b.MTTR_GRADE, b.PMC_GRADE, b.DFR_HBN_GRADE, DFR_PPI_GRADE,
	npf_grade, attr_grade, frs_grade, lead_grade, ib_Grade
from
	SE_CSS_MASTER a 
	inner join SE_CSS_GRADATION b on a.id = b.css_id 
where 
	(
		@fromDate between VALID_FROM and VALID_TILL
		or
		@toDate between VALID_FROM and VALID_TILL
	)
	and b.GradationEligibility='Yes'
	and a.region = case when coalesce(@region,'')<>'' then @region else a.region end
	and a.Business_Unit = case when coalesce(@businessUnit,'')<>'' then @businessUnit else a.Business_Unit end
	and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
	and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
	and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
	and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
	declare @grade		Varchar(max)
	declare @ordinal		int
	Declare GRADE_CURSOR CURSOR FOR
	--select distinct final_Grade, 
	--	case 
	--		when final_Grade ='No Grade' then 0 
	--		when final_Grade ='Silver' then 1
	--		when final_Grade ='Gold' then 2
	--		when final_Grade ='Platinum' then 3
	--		when FINAL_GRADE='-1' then 4
	--	end as Ordinal from se_css_Gradation 
	--order by ordinal
	Select 'No Grade'
	union
	Select 'Silver'
	union
	Select 'Gold'
	union
	Select 'Platinum'
	declare @sql		varchar(max) =''
	OPEN GRADE_CURSOR
	FETCH NEXT FROM GRADE_CURSOR INTO @grade
	WHILE @@FETCH_STATUS=0
	BEGIN
		insert into #tmpGroup
		select 
			a.Region, 
			a.BusinessUnit, 
			a.Month_Name, TotalCss, @grade,
			coalesce(Final.FinalGradeCount,0) as FinalGradeCount,
			coalesce(srs.SRSGradeCount,0) as SRSGradeCount,coalesce(convert(decimal(18,2),(convert(decimal(18,2),srs.SRSGradeCount)/Convert(Decimal(18,2),TotalCss)) * 100.00),0) as SRSGradePercentage,
			coalesce(nss.NSSGradeCount,0) as NSSGradeCount, Coalesce((nss.NSSGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as NSSGradePercentage, 
			coalesce(csr.CSRGradeCount,0),coalesce((csr.CSRGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as CSRGradePercentage, 
			coalesce(WOR.WORGradeCount,0),coalesce((wor.WORGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as WORGradePercentage, 
			coalesce(MTTR.MTTRGradeCount,0),coalesce((MTTR.MTTRGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as MTTRGradePercentage, 
			coalesce(PMC.PMCGradeCount,0),coalesce((pmc.PMCGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as PMCGradePercentage, 
			coalesce(DFRHBN.DRFHBNGradeCount,0),coalesce((DFRHBN.DRFHBNGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as DFRHBNGradePercentage, 
			coalesce(DFRPPI.DRFPPIGradeCount,0),coalesce((DFRPPI.DRFPPIGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as dfrppiGradePercentage, 
			coalesce(npf.NPFGradeCount,0),coalesce((npf.NPFGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as NPFGradePercentage, 
			coalesce(attr.ATTRGradeCount,0),coalesce((attr.ATTRGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as ATTRGradePercentage, 
			coalesce(frs.FRSGradeCount,0),coalesce((frs.FRSGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as FRSGradePercentage, 
			coalesce(leadg.LeadGradeCount,0),coalesce((leadg.LeadGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as LeadGradePercentage, 
			coalesce(ib.IBGradeCount,0),coalesce((ib.IBGradeCount/Convert(Decimal(18,2),TotalCss)) * 100.00,0) as ibGradePercentage 
		from
			(
				SELECT
					Case when @groupBy='Region' then b.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then b.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					Count(css_id) as TotalCss
				from
					SE_CSS_GRADATION a
					inner join se_Css_master b on a.css_id = b.id  
				where 
					(
						@fromDate between VALID_FROM and VALID_TILL
						or
						@toDate between VALID_FROM and VALID_TILL
					)
					and a.GradationEligibility='Yes'
					and 
					(
						@fromDate between VALID_FROM and VALID_TILL
						or
						@toDate between VALID_FROM and VALID_TILL
					)
					and region = case when coalesce(@region,'')<>'' then @region else region end
					and Business_Unit = case when coalesce(@businessUnit,'')<>'' then @businessUnit else Business_Unit end
					and b.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then b.CSS_MGR_USER_ID else @cssManagerUserId end 
					and b.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then b.INV_FIN_USER_ID else @finUserId end 
					and b.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then b.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then b.region else '' end, 
					Case when @groupBy ='BusinessUnit' then b.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))

			) a 
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as FinalGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.FINAL_GRADE=@grade and GradationEligibility='Yes' and
					(
						@fromDate between VALID_FROM and VALID_TILL
						or
						@toDate between VALID_FROM and VALID_TILL
					)
					and a.region = case when coalesce(@region,'')<>'' then @region else a.region end
					and a.Business_Unit = case when coalesce(@businessUnit,'')<>'' then @businessUnit else a.Business_Unit end
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) final on a.month_name = final.Month_Name   and a.region = final.region and a.BusinessUnit = final.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as SRSGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.SRS_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) SRS on SRS.month_name = a.Month_Name  and srs.region = a.region and srs.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as NSSGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.NSS_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) NSS on NSS.month_name = a.Month_Name  and NSS.region = a.region and NSS.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as CSRGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.CSR_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) CSR on CSR.month_name = a.Month_Name  and CSR.region = a.region and CSR.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as WORGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.WOR_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) WOR on WOR.month_name = a.Month_Name  and WOR.region = a.region and WOR.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as MTTRGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.MTTR_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) MTTR on MTTR.month_name = a.Month_Name  and MTTR.region = a.region and MTTR.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as PMCGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.PMC_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) PMC on PMC.month_name = a.Month_Name  and PMC.region = a.region and PMC.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as DRFHBNGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.DFR_HBN_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) DFRHBN on DFRHBN.month_name = a.Month_Name  and DFRHBN.region = a.region and DFRHBN.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as DRFPPIGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.DFR_HBN_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) DFRPPI on DFRPPI.month_name = a.Month_Name  and DFRPPI.region = a.region and DFRPPI.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as NPFGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.NPF_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) NPF on NPF.month_name = a.Month_Name  and NPF.region = a.region and NPF.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as ATTRGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.ATTR_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) ATTR on ATTR.month_name = a.Month_Name  and ATTR.region = a.region and ATTR.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as FRSGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.FRS_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) FRS on FRS.month_name = a.Month_Name  and FRS.region = a.region and FRS.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as LeadGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.LEAD_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) LEADG on LEADG.month_name = a.Month_Name  and LEADG.region = a.region and LEADG.BusinessUnit = a.BusinessUnit
			left outer join 
			(
				select	
					Case when @groupBy='Region' then a.region else '' end as Region, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end as BusinessUnit,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From)) as Month_Name,
					count(*) as IBGradeCount
				From	
					SE_CSS_MASTER a 
					inner join SE_CSS_GRADATION b on a.id = b.css_id 
				Where
					b.IB_GRADE=@grade and GradationEligibility='Yes'
					and a.CSS_MGR_USER_ID = case when coalesce(@cssManagerUserId,'')='' then a.CSS_MGR_USER_ID else @cssManagerUserId end 
					and a.INV_FIN_USER_ID = case when coalesce(@finUserId,'')='' then a.INV_FIN_USER_ID else @finUserId end 
					and a.GRN_USER_ID = case when coalesce(@grnUserId,'')='' then a.GRN_USER_ID else @grnUserId end 
					and a.id = case when coalesce(@cssId,'')='' then a.Id else @cssId end
				group by 
					Case when @groupBy='Region' then a.region else '' end, 
					Case when @groupBy ='BusinessUnit' then a.Business_Unit else '' end ,
					DateName(Month,valid_From) + '-' + Convert(varchar(10),YEAR(valid_From))
			) IB on IB.month_name = a.Month_Name  and IB.region = a.region and IB.BusinessUnit = a.BusinessUnit



			--and 
			-- b.FINAL_GRADE= @grade and 
			--b.SRS_GRADE=@grade and  b.NSS_GRADE=@grade and  b.CSR_GRADE=@grade and  b.wor_grade=@grade and  b.MTTR_GRADE=@grade and  b.PMC_GRADE=@grade and  b.DFR_HBN_GRADE=@grade and  DFR_PPI_GRADE=@grade and 
			--npf_grade=@grade and  attr_grade=@grade and  frs_grade=@grade and  lead_grade=@grade and  ib_Grade= @grade


	FETCH NEXT FROM GRADE_CURSOR INTO @grade
	END
	CLOSE GRADE_CURSOR
	DEALLOCATE GRADE_CURSOR
	select * from #tmpGroup order by BusinessUnit, region, Grade_text
END
