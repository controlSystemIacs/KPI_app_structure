SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[cs_main]
    @Frequency NVARCHAR(50)  -- Parameter to determine the frequency ('hourly', 'daily', 'running')
AS
BEGIN
    SET NOCOUNT ON;

    -- Call Time Temporal Calulation
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    -- Time Range Variables
    DECLARE @StartDate DATETIME;
    DECLARE @EndDate DATETIME;

    EXEC [dbo].[cs_GetStartEndTimes] @Frequency, @StartDate OUTPUT, @EndDate OUTPUT;
    
    -- debug 
    /* 
    SELECT 'Main Start Date: ' + CONVERT(NVARCHAR(50), @StartDate, 121) AS [Main Start Date],
             'Main End Date: ' + CONVERT(NVARCHAR(50), @EndDate, 121) AS [Main End Date];
    */

    
    -- Call Production Calculation
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    -- Production Related Variables
    DECLARE @MinuteDifference INT
    DECLARE @MassFactor FLOAT;
    DECLARE @Multiplier DECIMAL(18, 2)
    DECLARE @TagName_prefix NVARCHAR(50)
    DECLARE @SourceTagName NVARCHAR(50)
    DECLARE @Production_output FLOAT;
    DECLARE @main_production_json NVARCHAR(MAX)

    SET @MassFactor = 7.39; 
   
    SET @MinuteDifference = DATEDIFF(MINUTE, @StartDate, @EndDate)
    IF @MinuteDifference < 60
        SET @Multiplier = CAST(@MinuteDifference AS DECIMAL(18, 2)) / 60.0
    ELSE
        SET @Multiplier = CAST(@MinuteDifference AS DECIMAL(18, 2)) / 60.0
    END
    
    SET @TagName_prefix = 'beam_b'
    SET @SourceTagName = 'dp_test_speed_motor_2'
    
    EXEC [dbo].[cs_production_kg] 
    @Multiplier, 
    @MassFactor, 
    @StartDate, 
    @EndDate,
    @TagName_prefix,
    @SourceTagName,
    @Production_output OUTPUT,
    @main_production_json OUTPUT;

    -- debug
    /* select 
        @Production_output as 'prod_value_output',
        @main_production_json as 'json from main' */

    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    -- Call Energy Calculation
    -------------------------------------------------------------------------
    ------------------------------------------------------------------------- 

    -- Energy Related Variables
    DECLARE @TagName_List NVARCHAR(MAX)
    DECLARE @main_energy_json NVARCHAR(MAX)

    -- debug
    DECLARE @debug_StartDate DATETIME;
    DECLARE @debug_EndDate DATETIME; 
    SET @debug_StartDate = '20240101 10:12:26.000'
    SET @debug_EndDate = '20240401 10:12:26.000'
    
    SET @TagName_List = 
    '
        ''dp_test_energy_line_1'',
        ''dp_test_energy_line_12'',
        ''dp_test_energy_line_2'',
        ''dp_test_energy_line_22''
    ';

    EXEC [dbo].[cs_energy] 
    @debug_StartDate, 
    @debug_EndDate,
    @TagName_List,
    @main_energy_json OUTPUT;

    -- debug
    -- SELECT @main_energy_json , OBJECT_NAME(@@PROCID) 

    
    -- Call Intensity Calculation
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------
    DECLARE @main_intensity_json NVARCHAR(MAX)


    EXEC [dbo].[cs_intensity] 
    @main_production_json, 
    @main_energy_json,
    @main_intensity_json OUTPUT;

    -- debug
    -- SELECT @main_intensity_json, OBJECT_NAME(@@PROCID) 

    -- Call Insertion Function
    -------------------------------------------------------------------------
    ------------------------------------------------------------------------- 
    DECLARE @merged_json NVARCHAR(MAX);

    -- Combine the two JSON strings into a single JSON array
    SET @merged_json = (
        SELECT 
            JSON_QUERY(@main_production_json) AS main_production_json,
            JSON_QUERY(@main_energy_json) AS main_energy_json,
            JSON_QUERY(@main_intensity_json) AS main_intensity_json
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    -- debug
    select @merged_json, OBJECT_NAME(@@PROCID) 

    EXEC [dbo].[cs_insert_to_Analog_History] 
    @Frequency,
    @main_production_json, 
    @main_energy_json,
    @main_intensity_json
GO
