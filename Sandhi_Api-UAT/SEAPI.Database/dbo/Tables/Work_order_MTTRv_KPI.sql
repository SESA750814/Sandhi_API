CREATE TABLE [dbo].[Work_order_MTTRv_KPI] (
    [Work_order_MTTRv_KPIID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [CSSCode]                NVARCHAR (MAX)  NULL,
    [CityClass]              NVARCHAR (MAX)  NULL,
    [Category_BU]            NVARCHAR (MAX)  NULL,
    [NoOfRecords]            INT             NULL,
    [Total]                  NVARCHAR (100)  NULL,
    [AVG]                    DECIMAL (10, 2) NULL,
    [KPI]                    INT             NULL,
    [Minutes]                INT             NULL,
    [AVGDaysHoursMinutes]    VARCHAR (2000)  NULL,
    [UpdatedDateTime]        DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Work_order_MTTRv_KPIID] ASC)
);

