CREATE TABLE [dbo].[LeadGeneration] (
    [CSS_Code]                 NVARCHAR (MAX) NULL,
    [CSS_Name]                 NVARCHAR (MAX) NULL,
    [Percentage]               NVARCHAR (MAX) NULL,
    [UpdatePercentageDateTime] DATETIME       NULL,
    [Id]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

