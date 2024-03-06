SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[cs_insert_to_Analog_History]
    @Frequency NVARCHAR(50),
    @Production_JSON NVARCHAR(MAX),
    @Energy_JSON NVARCHAR(MAX),
    @Intensity_JSON NVARCHAR(MAX)

    AS
BEGIN
    DECLARE @Suffix NVARCHAR(50);
    SET @Suffix = 
        CASE 
            WHEN @Frequency = 'running' THEN 'running'
            WHEN @Frequency = 'hourly' THEN 'hourly'
            WHEN @Frequency = 'daily' THEN 'daily'
            ELSE 'default_suffix' -- Adjust as needed
        END;
    
    -- Create a temporary table to store the JSON data
    CREATE TABLE #Temp_Analog_History (
        EndDate DATETIME,
        TagName NVARCHAR(100),
        Value DECIMAL(18, 5) -- Adjust the precision and scale as needed
    );

    INSERT INTO #Temp_Analog_History (EndDate, TagName, Value)
    SELECT 
        EndDate,
        TagName,
        Value
    FROM OPENJSON(@Production_JSON)
    WITH (
        EndDate DATETIME '$.EndDate',
        TagName NVARCHAR(100) '$.TagName',
        Value DECIMAL(18, 5) '$.Value' 
    );

    INSERT INTO #Temp_Analog_History (EndDate, TagName, Value)
    SELECT 
        EndDate,
        TagName,
        Value
    FROM OPENJSON(@Energy_JSON)
    WITH (
        EndDate DATETIME '$.EndDate',
        TagName NVARCHAR(100) '$.TagName',
        Value DECIMAL(18, 5) '$.Value' -- Adjust the precision and scale as needed
    );

    UPDATE #Temp_Analog_History
    SET TagName = TagName + @Suffix;

    -- Return the temporary table with the inserted data
    -- SELECT * FROM #Temp_Analog_History;

    -- Drop the temporary table
    DROP TABLE #Temp_Analog_History;

    -- UNCOMMENT FOR REAL INSERTION
    /* INSERT INTO INSQL.Runtime.dbo.AnalogHistory (DateTime, TagName, Value, OPCQuality, wwVersion)
    SELECT 
        EndDate AS DateTime,
        TagName,
        Value,
        192 AS OPCQuality,
        'Latest' AS wwVersion
    FROM #Temp_Analog_History; */

END

GO
