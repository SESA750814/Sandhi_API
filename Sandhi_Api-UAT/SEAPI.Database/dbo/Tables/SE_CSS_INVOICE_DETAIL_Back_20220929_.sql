CREATE TABLE [dbo].[SE_CSS_INVOICE_DETAIL_Back_20220929_] (
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [INV_ID]            BIGINT          NOT NULL,
    [AMC_WARRANTY_FLAG] VARCHAR (100)   NOT NULL,
    [INV_AMT]           NUMERIC (18, 2) NOT NULL,
    [Updated_User]      VARCHAR (100)   NOT NULL,
    [Updated_Date]      DATETIME        NOT NULL
);

