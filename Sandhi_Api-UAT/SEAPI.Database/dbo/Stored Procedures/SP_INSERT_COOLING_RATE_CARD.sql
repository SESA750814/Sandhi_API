

-- Stored Procedure for Cooling_Rate_Card
CREATE PROCEDURE [dbo].[SP_INSERT_COOLING_RATE_CARD]  
AS  
BEGIN  
    SET NOCOUNT ON;  
    -- Insert only records that don't already exist  
    INSERT INTO [Cooling_Rate_Card] ([Sr_no], [Payout_Type], [Work_Description], [Description], 
                                     [Short_Description], [Unit_details], [Product_Grouping], [CSS_Code], 
                                     [Region], [Distance_Slab], [Rate])  
    SELECT temp.[Sr_no], temp.[Payout_Type], temp.[Work_Description], temp.[Description],  
           temp.[Short_Description], temp.[Unit_details], temp.[Product_Grouping], temp.[CSS_Code],  
           temp.[Region], temp.[Distance_Slab], temp.[Rate]  
    FROM [Cooling_Rate_Card_List] temp  
    WHERE NOT EXISTS (  
        SELECT 1  
        FROM [Cooling_Rate_Card] existing  
        WHERE existing.[Sr_no] = temp.[Sr_no]  
          AND existing.[Payout_Type] = temp.[Payout_Type]  
          AND existing.[Work_Description] = temp.[Work_Description]  
          AND existing.[Description] = temp.[Description]  
          AND existing.[Short_Description] = temp.[Short_Description]  
          AND existing.[Unit_details] = temp.[Unit_details]  
          AND existing.[Product_Grouping] = temp.[Product_Grouping]  
          AND existing.[CSS_Code] = temp.[CSS_Code]  
          AND existing.[Region] = temp.[Region]  
          AND existing.[Distance_Slab] = temp.[Distance_Slab]  
          AND existing.[Rate] = temp.[Rate]  
    );  
    SELECT @@ROWCOUNT as 'New Records Inserted';  
END  
