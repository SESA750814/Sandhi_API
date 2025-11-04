CREATE TABLE [dbo].[Cooling_Rate_Card] (
    [Sr_no]             NVARCHAR (MAX) NULL,
    [Payout_Type]       NVARCHAR (MAX) NULL,
    [Work_Description]  NVARCHAR (MAX) NULL,
    [Description]       NVARCHAR (MAX) NULL,
    [Short_Description] NVARCHAR (MAX) NULL,
    [Unit_details]      NVARCHAR (MAX) NULL,
    [Product_Grouping]  NVARCHAR (MAX) NULL,
    [CSS_Code]          NVARCHAR (MAX) NULL,
    [Region]            NVARCHAR (MAX) NULL,
    [Distance_Slab]     NVARCHAR (MAX) NULL,
    [Rate]              NVARCHAR (MAX) NULL,
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

