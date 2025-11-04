CREATE TABLE [dbo].[WorkOrderSemiDraft] (
    [Guid]            UNIQUEIDENTIFIER NULL,
    [CSS_Id]          BIGINT           NULL,
    [Month_Name]      VARCHAR (50)     NULL,
    [WO_BusinessUnit] NVARCHAR (MAX)   NULL,
    [Status_Type]     INT              NULL,
    [CSS_Status]      VARCHAR (100)    NULL,
    [Central_Status]  VARCHAR (100)    NULL,
    [CSS_UpdatedDate] DATETIME         NULL,
    [FromDate]        DATETIME         NULL,
    [ToDate]          DATETIME         NULL,
    [UpdatedDateTime] DATETIME         NULL
);

