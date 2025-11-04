CREATE TABLE [dbo].[PSI_RepeatCalls] (
    [Work_Order_Number]       NVARCHAR (50)  NOT NULL,
    [IP_Serial_Number]        NVARCHAR (MAX) NULL,
    [WO_Completed_Timestamp]  NVARCHAR (MAX) NULL,
    [First_Assigned_DateTime] NVARCHAR (MAX) NULL,
    [IsMaterialUsed]          BIT            NULL,
    [Work_Order_Type]         NVARCHAR (MAX) NULL,
    [Work_Performed]          NVARCHAR (MAX) NULL,
    [Date_Back_30_Days]       DATE           NULL,
    [Date_Last_Call_Assigned] DATE           NULL,
    [Calls]                   INT            NULL
);

