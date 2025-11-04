-- =============================================
-- Author:		GANESAN MANI
-- Create date: 24/11/2022
-- Description:	INSERT PSI PRODUCT
-- =============================================
--EXEC INSERTPSIPRODUCT
CREATE PROCEDURE [dbo].[INSERTPSIPRODUCT]
AS
BEGIN
SET IDENTITY_INSERT PSI_Product_category ON;
TRUNCATE TABLE PSI_Product_category;

INSERT INTO PSI_Product_category (ID,[Type],[Product],[Group])
SELECT ID,[Type],[Product],[Group] FROM PSI_Product_category_List_Source;

SET IDENTITY_INSERT PSI_Product_category OFF;
END