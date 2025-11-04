CREATE TABLE [dbo].[temp_99] (
    [Work_Order_Number]        NVARCHAR (50)   NOT NULL,
    [WO_Process_Status]        BIGINT          NULL,
    [claim]                    DECIMAL (18, 2) NULL,
    [Distance_Slab]            NVARCHAR (MAX)  NULL,
    [Actual_Expenses_Mileage]  DECIMAL (18, 5) NULL,
    [Actual_Expenses_Supplies] DECIMAL (18, 5) NULL,
    [LABOUR_COST]              DECIMAL (18, 2) NULL,
    [actual_cost]              DECIMAL (20, 2) NULL,
    [labour_desc]              VARCHAR (MAX)   NULL,
    [Mileage_desc]             VARCHAR (MAX)   NULL
);

