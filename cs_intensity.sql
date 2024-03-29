SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[cs_intensity]
    @Production_JSON NVARCHAR(MAX),
    @Energy_JSON NVARCHAR(MAX),
    @Intensity_JSON NVARCHAR(MAX) OUTPUT
AS
BEGIN

    DECLARE @Production_Value DECIMAL(18, 2);
    DECLARE @Energy_JSON_Table TABLE (
        EndDate DATETIME,
        TagName NVARCHAR(100),
        EnergyValue  DECIMAL(18, 2)
    );

    -- Parse the production JSON to get the value
    SELECT @Production_Value = ParsedValue.Value
    FROM OPENJSON(@Production_JSON)
    CROSS APPLY OPENJSON([value])
    WITH (
        Value DECIMAL(18, 2) '$.Value'
    ) AS ParsedValue;

    -- Parse the energy JSON and divide the values by the production value
    INSERT INTO @Energy_JSON_Table (EndDate, TagName, EnergyValue)
    SELECT 
        EndDate,
        TagName,
        CAST([Value] / @Production_Value AS DECIMAL(18, 2)) AS EnergyValue
    FROM OPENJSON(@Energy_JSON)
    WITH (
        EndDate DATETIME '$.EndDate',
        TagName NVARCHAR(100) '$.TagName',
        [Value] DECIMAL(18, 2) '$.Value'
    );

    UPDATE @Energy_JSON_Table
    SET TagName = REPLACE(TagName, '_energy_', '_intensity_');

    -- Construct the final JSON output
    SET @Intensity_JSON = 
    '[' +
    (
        SELECT 
            EndDate,
            TagName,
            EnergyValue
        FROM @Energy_JSON_Table
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
    + ']' ;

    -- select @Intensity_JSON, OBJECT_NAME(@@PROCID)

END
GO
