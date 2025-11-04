CREATE TABLE [dbo].[PSI_Product_Category_backup_14112022] (
    [Id]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [Type]    NVARCHAR (MAX) NULL,
    [Product] NVARCHAR (MAX) NULL,
    [Group]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PSI_ProductCategory] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);

