CREATE TABLE [dbo].[SE_CSS_APPROVED_DATA] (
    [Id]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [CSS_Id]        BIGINT          NOT NULL,
    [CSS_Manager]   VARCHAR (MAX)   NULL,
    [CSS_Name]      VARCHAR (MAX)   NULL,
    [Region]        VARCHAR (MAX)   NULL,
    [Month_Name]    VARCHAR (MAX)   NULL,
    [Approval_Date] DATETIME        NULL,
    [Inv_Amt]       DECIMAL (18, 2) NULL,
    [Inv_Id]        BIGINT          NOT NULL,
    [Gid]           VARCHAR (MAX)   NOT NULL,
    [Tax_Amt]       DECIMAL (18, 2) NULL,
    [Inc_Tax_Amt]   DECIMAL (18, 2) NULL,
    [Inv_Type]      VARCHAR (MAX)   NULL,
    [AMC_Amt]       DECIMAL (18, 2) NULL,
    [Warranty_Amt]  DECIMAL (18, 2) NULL,
    [PO_No]         VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_SE_CSS_APPROVED_DATA] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);

