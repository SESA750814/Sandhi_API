CREATE TABLE [dbo].[PSI_Product_Category] (
    [Id]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [Type]    NVARCHAR (MAX) NULL,
    [Product] NVARCHAR (MAX) NULL,
    [Group]   NVARCHAR (MAX) NULL
);

