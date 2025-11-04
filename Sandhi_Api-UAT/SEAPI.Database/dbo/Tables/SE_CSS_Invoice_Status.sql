CREATE TABLE [dbo].[SE_CSS_Invoice_Status] (
    [Id]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [Inv_Id]        BIGINT          NOT NULL,
    [Status_Type]   INT             NOT NULL,
    [Ref_No]        VARCHAR (MAX)   NULL,
    [Ref_Date]      DATETIME        NULL,
    [Ref_Amt]       DECIMAL (18, 2) NULL,
    [Remarks]       VARCHAR (MAX)   NULL,
    [Attachment]    VARCHAR (MAX)   NULL,
    [Updated_User]  VARCHAR (100)   NOT NULL,
    [Updated_Date]  DATETIME        NOT NULL,
    [Auto_Approval] BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SE_INVOICE_Status] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_INV_STATUS_INV] FOREIGN KEY ([Inv_Id]) REFERENCES [dbo].[SE_CSS_INVOICE] ([Id])
);

