CREATE TABLE [dbo].[DefectiveReturnRatePPAndIKPI] (
    [DefectiveReturnRatePPAndIKPIID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [CssCode]                        VARCHAR (MAX)   NULL,
    [BusinessUnit]                   VARCHAR (MAX)   NULL,
    [Percentage]                     DECIMAL (18, 2) NULL,
    [KPI]                            INT             NULL,
    [UpdatedDateTime]                DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([DefectiveReturnRatePPAndIKPIID] ASC)
);

