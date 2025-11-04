CREATE TABLE [dbo].[CustomerSatisfactionScoreNSS_KPI] (
    [CustomerSatisfactionScoreNSS_KPIID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [CssCode]                            VARCHAR (MAX)   NULL,
    [BusinessUnit]                       VARCHAR (MAX)   NULL,
    [Percentage]                         DECIMAL (18, 2) NULL,
    [KPI]                                INT             NULL,
    PRIMARY KEY CLUSTERED ([CustomerSatisfactionScoreNSS_KPIID] ASC)
);

