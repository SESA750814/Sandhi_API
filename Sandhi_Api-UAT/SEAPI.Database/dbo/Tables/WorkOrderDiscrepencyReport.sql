CREATE TABLE [dbo].[WorkOrderDiscrepencyReport] (
    [Guid]             UNIQUEIDENTIFIER NULL,
    [CSS_Id]           BIGINT           NULL,
    [Month_Name]       VARCHAR (50)     NULL,
    [WO_BusinessUnit]  NVARCHAR (MAX)   NULL,
    [WorkOrderCount]   INT              NULL,
    [DiscrepencyCount] INT              NULL,
    [Percentage]       DECIMAL (18, 2)  NULL,
    [FromDate]         DATETIME         NULL,
    [ToDate]           DATETIME         NULL,
    [UpdatedDateTime]  DATETIME         NULL
);

