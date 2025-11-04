-- =============================================
-- Author:		GANESAN MANI
-- Create date: 24/11/2022
-- Description:	INSERT COOLING PRODUCT
-- =============================================
CREATE PROCEDURE [dbo].[INSERTCOOLINGPRODUCT]
AS
BEGIN
SET IDENTITY_INSERT Cooling_Product_Category_list ON;
TRUNCATE TABLE Cooling_Product_Category_list;

INSERT INTO Cooling_Product_Category_list (ID,[Type],[Product],[Group])
SELECT ID,[Type],[Product],[Group] FROM Cooling_Product_Category_list_Source;

SET IDENTITY_INSERT Cooling_Product_Category_list OFF;
END