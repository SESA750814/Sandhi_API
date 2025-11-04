-- =============================================
-- Author:		GANESAN MANI
-- Create date: 24/11/2022
-- Description:	INSERT HBN PRODUCT
-- =============================================
CREATE PROCEDURE [dbo].[INSERTHBNPRODUCT]
AS
BEGIN
SET IDENTITY_INSERT HBN_Product_category_List ON;
TRUNCATE TABLE HBN_Product_category_List;

INSERT INTO HBN_Product_category_List (ID,[Type],[Product],[Group])
SELECT ID,[Type],[Product],[Group] FROM HBN_Product_category_List_Source;

SET IDENTITY_INSERT HBN_Product_category_List OFF;
END