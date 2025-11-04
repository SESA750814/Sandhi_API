CREATE TABLE [dbo].[HBN_Rate_Card] (
    [Product_Grouping] NVARCHAR (MAX) NULL,
    [PayOut_Type]      NVARCHAR (MAX) NULL,
    [Service_Type]     NVARCHAR (MAX) NULL,
    [Distance_Slab]    NVARCHAR (MAX) NULL,
    [Rate]             NVARCHAR (MAX) NULL,
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

