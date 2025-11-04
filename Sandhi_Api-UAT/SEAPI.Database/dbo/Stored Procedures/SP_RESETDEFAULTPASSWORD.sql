-- =============================================
-- Author:		GANESAN MANI
-- Create date: 26/10/2022
-- Description:	RESET DEFAULT PASSWORD
-- =============================================
CREATE PROCEDURE [dbo].[SP_RESETDEFAULTPASSWORD] 
	@EMAIL VARCHAR(50)
AS
BEGIN
	UPDATE ASPNETUSERS SET PASSWORDHASH='AQAAAAEAACcQAAAAELuXEgMNXiz6lPkYoMmpC9wE2Ds1JIjdfPhDGKiTK7wnQ3F4zIgGmNJx5IisCMQx5Q==' WHERE EMAIL=@EMAIL;
END
