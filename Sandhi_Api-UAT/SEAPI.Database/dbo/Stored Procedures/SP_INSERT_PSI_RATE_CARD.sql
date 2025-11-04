
CREATE PROCEDURE [dbo].[SP_INSERT_PSI_RATE_CARD]  
AS  
BEGIN  
    SET NOCOUNT ON;  
    -- Insert only records that don't already exist  
    INSERT INTO [PSI_Rate_Card] ([Product_Grouping], [Distance_Slab], [Rate])  
    SELECT temp.[Product_Grouping], temp.[Distance_Slab], temp.[Rate]  
    FROM [PSI_Rate_Card_List] temp  
    WHERE NOT EXISTS (  
        SELECT 1  
        FROM [PSI_Rate_Card] existing  
        WHERE existing.[Product_Grouping] = temp.[Product_Grouping]  
          AND existing.[Distance_Slab] = temp.[Distance_Slab]  
          AND existing.[Rate] = temp.[Rate]  
    );  
    SELECT @@ROWCOUNT as 'New Records Inserted';  
END  
