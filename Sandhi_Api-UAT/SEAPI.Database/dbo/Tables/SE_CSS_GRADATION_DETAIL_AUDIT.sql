CREATE TABLE [dbo].[SE_CSS_GRADATION_DETAIL_AUDIT] (
    [GradationDetailAuditId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Id]                     BIGINT        NOT NULL,
    [GRADATION_ID]           BIGINT        NOT NULL,
    [GRADE_TYPE]             VARCHAR (100) NOT NULL,
    [CITY_CLASS]             VARCHAR (100) NOT NULL,
    [BUSINESS_UNIT]          VARCHAR (100) NOT NULL,
    [GRADE_SCORE]            VARCHAR (100) NULL,
    [GRADE]                  VARCHAR (100) NOT NULL,
    [Updated_User]           VARCHAR (100) NOT NULL,
    [Updated_Date]           DATETIME      NOT NULL,
    [Audit_CreatedDateTime]  DATETIME      NOT NULL,
    CONSTRAINT [PK_SE_CSS_GRADATION_DETAIL_AUDIT] PRIMARY KEY NONCLUSTERED ([GradationDetailAuditId] ASC)
);

