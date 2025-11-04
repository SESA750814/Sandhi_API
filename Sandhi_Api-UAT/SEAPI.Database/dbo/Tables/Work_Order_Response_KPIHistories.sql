CREATE TABLE [dbo].[Work_Order_Response_KPIHistories] (
    [Work_Order_Response_KPIHistoryID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Work_Order_Response_KPIID]        BIGINT          NULL,
    [CSSCode]                          NVARCHAR (MAX)  NULL,
    [Category_BU]                      NVARCHAR (MAX)  NULL,
    [NoOfRecords]                      INT             NULL,
    [Total]                            NVARCHAR (2000) NULL,
    [AVG]                              DECIMAL (10, 2) NULL,
    [KPI]                              INT             NULL,
    [Minutes]                          INT             NULL,
    [AVGHoursMinutes]                  VARCHAR (2000)  NULL,
    [UpdatedDateTIme]                  DATETIME        NULL,
    [HistoryCreatedDate]               DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Work_Order_Response_KPIHistoryID] ASC)
);

