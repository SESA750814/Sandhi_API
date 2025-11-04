CREATE TABLE [dbo].[SE_Notification] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [Status_Type]  INT           NOT NULL,
    [Ref_No]       VARCHAR (MAX) NULL,
    [Ref_Type]     VARCHAR (MAX) NULL,
    [CSS_Id]       BIGINT        NULL,
    [User_Id]      VARCHAR (MAX) NULL,
    [User_Type]    VARCHAR (MAX) NULL,
    [Remarks]      VARCHAR (MAX) NULL,
    [Action]       VARCHAR (MAX) NULL,
    [Created_User] VARCHAR (100) NOT NULL,
    [Created_Date] DATETIME      NOT NULL,
    [Expiry_Date]  DATETIME      NOT NULL,
    [IsActive]     BIT           DEFAULT ((1)) NOT NULL,
    [Email_Date]   DATETIME      NULL,
    [SUBJECT]      VARCHAR (MAX) NULL,
    [Body]         VARCHAR (MAX) NULL,
    [ToEmail]      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_SE_Notification] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);

