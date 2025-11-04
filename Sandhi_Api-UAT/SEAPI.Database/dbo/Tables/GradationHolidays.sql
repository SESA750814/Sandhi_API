CREATE TABLE [dbo].[GradationHolidays] (
    [HolidayID]          INT            IDENTITY (1, 1) NOT NULL,
    [Holiday]            DATE           NULL,
    [HolidayDescription] VARCHAR (1000) NULL,
    [IsActive]           BIT            NULL,
    [Createdby]          INT            NULL,
    [CreatedDateTime]    DATETIME       NULL,
    [Updatedby]          INT            NULL,
    [UpdatedDateTime]    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([HolidayID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [index_Holiday_IsActive]
    ON [dbo].[GradationHolidays]([Holiday] ASC, [IsActive] ASC);


GO
CREATE NONCLUSTERED INDEX [index_IsActive]
    ON [dbo].[GradationHolidays]([IsActive] ASC);

