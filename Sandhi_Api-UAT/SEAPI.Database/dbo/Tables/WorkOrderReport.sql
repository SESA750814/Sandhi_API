CREATE TABLE [dbo].[WorkOrderReport] (
    [Guid]              UNIQUEIDENTIFIER NULL,
    [CSS_Id]            BIGINT           NULL,
    [Month_Name]        VARCHAR (50)     NULL,
    [AMC_WARRANTY_FLAG] VARCHAR (100)    NULL,
    [WO_BusinessUnit]   NVARCHAR (MAX)   NULL,
    [WorkOrderCount]    INT              NULL,
    [FromDate]          DATETIME         NULL,
    [ToDate]            DATETIME         NULL,
    [UpdatedDateTime]   DATETIME         NULL
);

