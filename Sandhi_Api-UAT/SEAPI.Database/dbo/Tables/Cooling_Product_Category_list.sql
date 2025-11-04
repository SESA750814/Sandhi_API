CREATE TABLE [dbo].[Cooling_Product_Category_list] (
    [Id]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [Product] NVARCHAR (MAX) NULL,
    [Type]    NVARCHAR (MAX) NULL,
    [Group]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Cooling_ProductCategory] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);

