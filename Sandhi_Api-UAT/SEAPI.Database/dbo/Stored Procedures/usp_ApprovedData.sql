CREATE procedure [dbo].[usp_ApprovedData]
	@finUserId			varchar(max),
	@businessUnit		varchar(max),
	@monthName			varchar(max),
	@gid				Varchar(max)
AS
--drop TABLE SE_CSS_APPROVED_WORKORDER
--go
--drop TABLE SE_CSS_APPROVED_DATA
--go

--CREATE TABLE SE_CSS_APPROVED_DATA
--(
--	[Id] 						[bigint] IDENTITY(1,1) NOT NULL,
--	[CSS_Id]					bigint			not null,
--	[CSS_Manager]				Varchar(max) null,
--	[CSS_Name]					Varchar(max) null,
--	[Region]					varchar(max)	null,
--	Month_Name					VArchar(max)	null,
--	Approval_Date				DateTime		null,
--	Inv_Amt						decimal(18,2)	null,
--	Inv_Id						bigint			not null,
--	Gid							Varchar(max)	not null,
-- CONSTRAINT [PK_SE_CSS_APPROVED_DATA] PRIMARY KEY  NONCLUSTERED
--(
--	Id asc
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--CREATE TABLE SE_CSS_APPROVED_WORKORDER
--(
--	[Id] 							[bigint] IDENTITY(1,1) NOT NULL,
--	[Approved_Id]					bigint			not null,
--	WO_BusinessUnit					Varchar(max) null,
--	Work_Order_Number				Varchar(max) null,
--	Installed_At_Account			varchar(max)	null,
--	Month_Name						VArchar(max)	null,
--	Work_Order_Type					VArchar(max)	null,
--	WO_Completed_Date				Varchar(max)		null,
--	Claim							decimal(18,2)	null,
--	Labour_Cost						decimal(18,2)	null,
--	Supply_Cost						decimal(18,2)	null,
--	Gid								Varchar(max)	not null,
--	[Case] [nvarchar](max) NULL,
--	[First_Assigned_DateTime] [nvarchar](max) NULL,
--	[Main_Installed_Product] [nvarchar](max) NULL,
--	[IP_Serial_Number] [nvarchar](max) NULL,
--	[Product_Grouping] [nvarchar](10) NULL,
--	[Work_Order_Sub_Type] [nvarchar](max) NULL,
--	[Completed_On] [nvarchar](max) NULL,
--	[Work_Order_Reason] [nvarchar](max) NULL,
--	[Product] [nvarchar](max) NULL,
--	[Is_Billable] [nvarchar](max) NULL,
--	[Non_Billing_Reason] [nvarchar](max) NULL,
--	[Street] [nvarchar](max) NULL,
--	[City] [nvarchar](max) NULL,
--	[Zip] [nvarchar](max) NULL,
--	[State] [nvarchar](max) NULL,
--	[Service_Team] [nvarchar](max) NULL,
--	[Primary_FSR] [nvarchar](max) NULL,
--	[Partner_Account] [nvarchar](max) NULL,
--	[Work_Performed] [nvarchar](max) NULL,
--	[WO_Process_Status] [bigint] NULL,
--	[Distance_Slab] [nvarchar](max) NULL,
--	[Actual_Expense_converted] [int] NULL,
--	[WO_Completed_Timestamp] [nvarchar](max) NULL,
--	[Claim_Type] [nvarchar](max) NULL,
--	[LABOUR_DESC] [varchar](max) NULL,
--	[SUPPLY_DESC] [varchar](max) NULL,
--	[MILEAGE_DESC] [varchar](max) NULL,
--	[Actual_Expenses_Gas] [decimal](18, 5) NULL,
--	[Actual_Expenses_Mileage] [decimal](18, 5) NULL,
--	[Actual_Expenses_Supplies] [decimal](18, 5) NULL,
--	[ACTUAL_LABOUR_COST] [decimal](18, 2) NULL,
--	[ACTUAL_SUPPLY_COST] [decimal](18, 2) NULL,
--[Actual_Cost] [decimal](20, 2) NULL,
--	[CSS_Reason] [varchar](max) NULL,	
-- CONSTRAINT [PK_SE_CSS_APPROVED_WORKORDER] PRIMARY KEY  NONCLUSTERED
--(
--	Id asc
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--ALTER TABLE dbo.SE_CSS_APPROVED_WORKORDER   WITH CHECK ADD  CONSTRAINT [FK_WO_approved] FOREIGN KEY([Approved_Id])
--REFERENCES [dbo].SE_CSS_APPROVED_DATA ([Id])

--Alter Table SE_CSS_Approved_Data add Tax_Amt				Decimal(18,2) null
--Alter Table SE_CSS_Approved_Data add Inc_Tax_Amt			Decimal(18,2) null
--Alter Table SE_CSS_Approved_Data add Inv_Type				varchar(max) null
--Alter Table SE_CSS_Approved_Data add PO_No				varchar(max) null

--Alter Table SE_CSS_Approved_Data add AMC_Amt				Decimal(18,2) null
--Alter Table SE_CSS_Approved_Data add Warranty_Amt			Decimal(18,2) null
--declare @gid			varchar(max)='1111-111-111'
--declare @finUserId			varchar(max)='-1'


declare @sql			Varchar(max)
set @sql ='Insert into SE_CSS_Approved_Data(Css_Id, Css_Manager, Css_Name, Region, Month_Name,
			Approval_Date, Inv_Amt,Tax_Amt,Inc_Tax_Amt,Inv_type, Inv_Id, PO_NO, Gid) 
			select 
				a.css_id, b.CSS_Manager, b.css_Name_in_BFS_To_be_Referred, b.Region, a.Month_Name,
				a.PRF_Gen_Date as Approval_Date, Inv_Amt as Total_Cost, Tax_Amt, Inc_Tax_Amt,a.inv_type, a.id as Inv_Id, c.PO_No, ''' + @gid + '''
			from 
			SE_CSS_INVOICE a 
			inner join se_css_master b on a.css_id = b.Id
			left outer join SE_CSS_PURCHASE_ORDER c on a.po_id = c.id 
			Where
				a.Status_Type < 15	
				and a.wo_businessunit=''' + @businessUnit +'''
				and a.Month_Name ='''+ @monthName +''''


if Coalesce(@finUserId,'-1')<>'-1'
begin
	set @sql = @sql + ' and b.Inv_Fin_User_Id=''' + @finUserId + ''''
end
exec(@sql)

select * from se_css_invoice 

update a set a.AMC_Amt = b.INV_AMT
from SE_CSS_APPROVED_DATA a
inner join SE_CSS_INVOICE_DETAIL b on a.inv_id = b.inv_id and b.AMC_WARRANTY_FLAG='AMC'
where a.gid=@gid

update a set a.Warranty_Amt = b.INV_AMT
from SE_CSS_APPROVED_DATA a
inner join SE_CSS_INVOICE_DETAIL b on a.inv_id = b.inv_id and b.AMC_WARRANTY_FLAG='Warranty'
where a.gid=@gid
			


Insert into SE_CSS_APPROVED_WORKORDER
(Approved_Id, Wo_BusinessUnit, Work_Order_Number,Installed_At_Account,Month_Name,Work_Order_Type,
WO_Completed_Date, Claim, LAbour_Cost, Supply_Cost, Gid,
	[Case] ,	[First_Assigned_DateTime] ,	[Main_Installed_Product] ,	[IP_Serial_Number] ,	[Product_Grouping] ,	[Work_Order_Sub_Type] ,
	[Completed_On] ,	[Work_Order_Reason] ,	[Product] ,	[Is_Billable] ,	[Non_Billing_Reason] ,	[Street] ,	[City] ,	[Zip] ,	[State] ,
	[Service_Team] ,	[Primary_FSR] ,	[Partner_Account] ,	[Work_Performed] ,	[WO_Process_Status] ,	[Distance_Slab] ,	[Actual_Expense_converted],	
	[WO_Completed_Timestamp] ,	[Claim_Type] ,	[LABOUR_DESC] ,	[SUPPLY_DESC] ,	[MILEAGE_DESC] ,	[Actual_Expenses_Gas] ,	[Actual_Expenses_Mileage] ,
	[Actual_Expenses_Supplies] ,	[ACTUAL_LABOUR_COST],	[ACTUAL_SUPPLY_COST],	[CSS_Reason], Actual_Cost)


select 
	a.id, b.WO_BusinessUnit, b.Work_Order_Number, b.Installed_At_Account, b.month_name, b.Work_Order_Type,	
	b.WO_Completed_Timestamp, claim, LABOUR_COST, SUPPLY_COST, @gid,
	[Case] ,	[First_Assigned_DateTime] ,	[Main_Installed_Product] ,	[IP_Serial_Number] ,	[Product_Grouping] ,	[Work_Order_Sub_Type] ,
	[Completed_On] ,	[Work_Order_Reason] ,	[Product] ,	[Is_Billable] ,	[Non_Billing_Reason] ,	[Street] ,	[City] ,	[Zip] ,	[State] ,
	[Service_Team] ,	[Primary_FSR] ,	[Partner_Account] ,	[Work_Performed] ,	[WO_Process_Status] ,	[Distance_Slab] ,	[Actual_Expense_converted],	
	[WO_Completed_Timestamp] ,	[Claim_Type] ,	[LABOUR_DESC] ,	[SUPPLY_DESC] ,	[MILEAGE_DESC] ,	[Actual_Expenses_Gas] ,	[Actual_Expenses_Mileage] ,
	[Actual_Expenses_Supplies] ,	[ACTUAL_LABOUR_COST],	[ACTUAL_SUPPLY_COST],	coalesce(c.reason,[CSS_Reason]), Actual_Cost
from 
	SE_CSS_APPROVED_DATA a 
	inner join SE_Work_Order b on a.css_id = b.css_id and (b.inv_id=a.inv_id or b.SUPPLY_INV_ID=a.Inv_Id)
	left outer join (Select reason, Work_Order_Id, row_number() Over(Partition by work_order_id order by id desc) as RowNum from Se_work_order_Status where Status_Type=4) c on b.id = c.Work_Order_Id and c.RowNum=1
where a.gid = @gid and b.WO_BusinessUnit=@businessUnit







