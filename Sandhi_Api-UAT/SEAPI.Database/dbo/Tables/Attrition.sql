CREATE TABLE [dbo].[Attrition] (
    [CSS_Code]                 NVARCHAR (MAX) NULL,
    [CSS_Name_BFS]             NVARCHAR (MAX) NULL,
    [Percentage]               NVARCHAR (MAX) NULL,
    [UpdatePercentageDateTime] DATETIME       NULL,
    [Id]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

