CREATE TABLE [dbo].[Grade] (
    [GradeID]    INT          IDENTITY (1, 1) NOT NULL,
    [Grade]      VARCHAR (50) NULL,
    [GradeOrder] INT          NULL,
    [IsActive]   BIT          NULL,
    PRIMARY KEY CLUSTERED ([GradeID] ASC)
);

