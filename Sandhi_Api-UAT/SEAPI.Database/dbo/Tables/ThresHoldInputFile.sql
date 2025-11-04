CREATE TABLE [dbo].[ThresHoldInputFile] (
    [ThresHoldInputFileID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CSSCode]              VARCHAR (100) NULL,
    [WorkOrderNumber]      VARCHAR (100) NULL,
    [ServiceTeam]          VARCHAR (MAX) NULL,
    [Category_r]           VARCHAR (100) NULL,
    [UpdatedDateTime]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ThresHoldInputFileID] ASC)
);

