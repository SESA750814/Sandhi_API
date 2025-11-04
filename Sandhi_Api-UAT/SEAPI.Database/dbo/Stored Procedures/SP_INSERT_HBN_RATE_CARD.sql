


-- Stored Procedure for HBN_Rate_Card
CREATE PROCEDURE [dbo].[SP_INSERT_HBN_RATE_CARD]  
AS  
BEGIN  
    SET NOCOUNT ON;  
    -- Insert only records that don't already exist  
    INSERT INTO [HBN_Rate_Card] ([Product_Grouping], [PayOut_Type], [Service_Type], [Distance_Slab], [Rate])  
    SELECT temp.[Product_Grouping], temp.[PayOut_Type], temp.[Service_Type], temp.[Distance_Slab], temp.[Rate]  
    FROM [HBN_Rate_Card_List] temp  
    WHERE NOT EXISTS (  
        SELECT 1  
        FROM [HBN_Rate_Card] existing  
        WHERE existing.[Product_Grouping] = temp.[Product_Grouping]  
          AND existing.[PayOut_Type] = temp.[PayOut_Type]  
          AND existing.[Service_Type] = temp.[Service_Type]  
          AND existing.[Distance_Slab] = temp.[Distance_Slab]  
          AND existing.[Rate] = temp.[Rate]  
    );  
    SELECT @@ROWCOUNT as 'New Records Inserted';  
END  
