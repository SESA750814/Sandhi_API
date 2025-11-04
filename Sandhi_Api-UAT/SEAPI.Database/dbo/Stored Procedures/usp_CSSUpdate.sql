
CREATE procedure [dbo].[usp_CSSUpdate]
	@updateType				int,
	@userId					Varchar(max),
	@cssIds					Varchar(max)
AS
begin

--exec usp_cssupdate 2,'9AD1B78C-1DC9-4037-828D-1EC02E6761AC','80619,80618,80617'

	-- SCM User = 5
	-- Finance Invoice Validator - 4
	-- CSS Manager - 2
	-- css User -- 3
	declare @cssManager int	=	2
	declare @cssUser	int	=	3
	declare @finUser	int	=	4
	declare @scmUser	int	=	5

	declare @name		varchar(max)
	declare @email		varchar(max)
	select @name=FirstName + ' ' + LastName, @email=UserName from aspnetusers where id = @userId
	
	Update a
	Set 
		a.CSS_Manager = case when @updateType=@cssManager then @name else a.CSS_Manager end,
		a.CSS_Manager_Email_ID = case when @updateType=@cssManager then @email else a.CSS_Manager_Email_ID end,
		a.CSS_MGR_USER_ID = case when @updateType=@cssManager then @userId else a.CSS_MGR_USER_ID end,

		a.Invoice_Validator_from_Finance_Team = case when @updateType=@finUser then @name else a.Invoice_Validator_from_Finance_Team end,
		a.INV_FIN_USER_ID = case when @updateType=@finUser then @userId else a.INV_FIN_USER_ID end,
		
		a.GRN_Creater = case when @updateType=@scmUser then @name else a.GRN_Creater end,
		a.GRN_Creater_Email_ID = case when @updateType=@scmUser then @email else a.GRN_Creater_Email_ID end,
		a.GRN_USER_ID = case when @updateType=@scmUser then @userId else a.GRN_USER_ID end,

		a.Authorised_UserEmail = case when @updateType=@cssUser then @userId else a.Authorised_UserEmail end 
	from SE_CSS_MASTER a  where id in (select convert(bigint,value) from string_split(@cssIds,','))

end
