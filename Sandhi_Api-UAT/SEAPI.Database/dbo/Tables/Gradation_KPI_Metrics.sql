CREATE TABLE [dbo].[Gradation_KPI_Metrics] (
    [Gradation_KPI_MetricsID] INT            IDENTITY (1, 1) NOT NULL,
    [Index]                   NVARCHAR (MAX) NULL,
    [Parameter]               NVARCHAR (MAX) NULL,
    [Measurment_criteria]     NVARCHAR (MAX) NULL,
    [BU]                      NVARCHAR (MAX) NULL,
    [Grade_Value]             NVARCHAR (MAX) NULL,
    [From]                    DECIMAL (5, 2) NULL,
    [To]                      DECIMAL (5, 2) NULL,
    [Grade]                   NVARCHAR (MAX) NULL,
    [ParameterGroup]          INT            NULL,
    [FromMinutes]             INT            NULL,
    [ToMinutes]               INT            NULL,
    [CityClassGroup]          VARCHAR (500)  NULL,
    [GradeID]                 INT            NULL,
    [BusinessUnit]            VARCHAR (2000) NULL,
    PRIMARY KEY CLUSTERED ([Gradation_KPI_MetricsID] ASC)
);

