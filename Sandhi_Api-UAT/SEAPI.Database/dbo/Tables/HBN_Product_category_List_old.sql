CREATE TABLE [dbo].[HBN_Product_category_List_old] (
    [Id]                           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Product_Grouping]             NVARCHAR (MAX) NULL,
    [Product_Commercial_Reference] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_HBN_ProductCategory] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);

