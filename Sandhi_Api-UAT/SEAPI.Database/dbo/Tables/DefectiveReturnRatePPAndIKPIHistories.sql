CREATE TABLE [dbo].[DefectiveReturnRatePPAndIKPIHistories] (
    [DefectiveReturnRatePPAndIKPIHistoryID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [DefectiveReturnRatePPAndIKPIID]        BIGINT          NULL,
    [CssCode]                               VARCHAR (MAX)   NULL,
    [BusinessUnit]                          VARCHAR (MAX)   NULL,
    [Percentage]                            DECIMAL (18, 2) NULL,
    [KPI]                                   INT             NULL,
    [UpdatedDateTime]                       DATETIME        NULL,
    [HistoryCreatedDateTime]                DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([DefectiveReturnRatePPAndIKPIHistoryID] ASC)
);

