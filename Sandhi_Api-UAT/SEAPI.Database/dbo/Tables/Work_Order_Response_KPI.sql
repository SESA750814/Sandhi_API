CREATE TABLE [dbo].[Work_Order_Response_KPI] (
    [Work_Order_Response_KPIID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [CSSCode]                   NVARCHAR (MAX)  NULL,
    [Category_BU]               NVARCHAR (MAX)  NULL,
    [NoOfRecords]               INT             NULL,
    [Total]                     NVARCHAR (100)  NULL,
    [AVG]                       DECIMAL (10, 2) NULL,
    [KPI]                       INT             NULL,
    [Minutes]                   INT             NULL,
    [AVGHoursMinutes]           VARCHAR (2000)  NULL,
    [UpdatedDateTime]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Work_Order_Response_KPIID] ASC)
);

