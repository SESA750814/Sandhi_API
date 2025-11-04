CREATE TABLE [dbo].[tempCssList] (
    [id]                         BIGINT         NOT NULL,
    [CSSCode]                    VARCHAR (50)   NULL,
    [CSS_Code]                   NVARCHAR (MAX) NULL,
    [CSS_Name_as_per_Oracle_SAP] NVARCHAR (MAX) NULL,
    [UserName]                   NVARCHAR (256) NULL,
    [ManagerUSer]                NVARCHAR (256) NULL,
    [FinUser]                    NVARCHAR (256) NULL,
    [GRNUser]                    NVARCHAR (256) NULL
);

