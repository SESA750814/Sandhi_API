CREATE TABLE [dbo].[SPLoadLogs] (
    [SPLoadLogID]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ObjectName]    VARCHAR (1000) NULL,
    [StartDateTime] DATETIME       NULL,
    [EndTime]       DATETIME       NULL,
    [TotalTime]     VARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([SPLoadLogID] ASC)
);

