CREATE TABLE [dbo].[ThresHold] (
    [CssCode]              NVARCHAR (MAX) NULL,
    [CSS_Name]             NVARCHAR (MAX) NULL,
    [CityClass]            NVARCHAR (MAX) NULL,
    [GradationEligibility] NVARCHAR (MAX) NULL,
    [UpdatedDateTime]      DATETIME       NULL,
    [Id]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

