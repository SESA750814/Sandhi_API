CREATE function [dbo].[RemoveCharSpecialSymbolValue](@str varchar(500))  
returns varchar(500)  
begin  

set @str = REPLACE(@str,'&', '')
set @str = REPLACE(@str,' ', '')
set @str = REPLACE(@str,'/', '')
set @str = REPLACE(@str,'-', '')


return @str  
end   
