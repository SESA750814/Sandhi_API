CREATE TABLE [dbo].[IBTrackingKPIHistories] (
    [IBTrackingKPIHistoryID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [IBTrackingKPIID]        BIGINT          NULL,
    [CssCode]                VARCHAR (MAX)   NULL,
    [Percentage]             DECIMAL (18, 2) NULL,
    [KPI]                    INT             NULL,
    [UpdatedDateTime]        DATETIME        NULL,
    [HistoryCreatedDateTime] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IBTrackingKPIHistoryID] ASC)
);

