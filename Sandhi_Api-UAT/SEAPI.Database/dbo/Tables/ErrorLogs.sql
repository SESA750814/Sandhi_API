CREATE TABLE [dbo].[ErrorLogs] (
    [ErrorLogID]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProcMethodName]  VARCHAR (1000) NULL,
    [AppType]         VARCHAR (1000) NULL,
    [ErrorMessage]    VARCHAR (1000) NULL,
    [Createdby]       BIGINT         NULL,
    [CreatedDateTime] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
);

