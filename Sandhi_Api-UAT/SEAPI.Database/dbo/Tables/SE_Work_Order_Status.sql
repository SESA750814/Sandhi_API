CREATE TABLE [dbo].[SE_Work_Order_Status] (
    [Id]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [Work_Order_Id] BIGINT          NOT NULL,
    [Status_Type]   INT             NOT NULL,
    [Updated_User]  VARCHAR (100)   NOT NULL,
    [Updated_Date]  DATETIME        NOT NULL,
    [Auto_Approval] BIT             DEFAULT ((0)) NOT NULL,
    [Remarks]       VARCHAR (MAX)   NULL,
    [WO_AMT]        NUMERIC (18, 2) NULL,
    [Reason]        VARCHAR (MAX)   NULL,
    [Reason_Desc]   VARCHAR (MAX)   NULL,
    [Attachment]    VARCHAR (MAX)   NULL,
    [LABOUR_COST]   DECIMAL (18, 2) NULL,
    [SUPPLY_COST]   DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_SE_Work_Order_Status] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_WO_STATUS_WO] FOREIGN KEY ([Work_Order_Id]) REFERENCES [dbo].[SE_Work_Order] ([Id])
);

