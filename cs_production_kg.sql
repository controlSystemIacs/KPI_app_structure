SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[cs_production_kg]
    @Multiplier FLOAT,
    @MassFactor FLOAT,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @TagNamePrefix NVARCHAR(50),
    @SourceTagName NVARCHAR(50),
    @Production_value FLOAT OUTPUT,
    @OutputJSON NVARCHAR(MAX) OUTPUT
    AS

BEGIN

    /* 
    select 
    @Multiplier,
    @MassFactor,
    @StartDate,
    @EndDate,
    @TagNamePrefix,
    @SourceTagName,
    OBJECT_NAME(@@PROCID) 
    */

    DECLARE @TagName1 NVARCHAR(100);

    SET @Production_value = (
        SELECT CASE WHEN AnalogSummaryHistory.TagName = @SourceTagName THEN round((Average * @MassFactor * @Multiplier), 2) ELSE 0 END
        FROM AnalogSummaryHistory
        WHERE
            AnalogSummaryHistory.TagName = @SourceTagName
            AND wwVersion = 'Latest'
            AND wwRetrievalMode = 'Cyclic'
            AND wwCycleCount = 1
            AND StartDateTime >= @StartDate
            AND EndDateTime <= @EndDate
    );
   

    SET @TagName1 = @TagNamePrefix + '_production_'

    -- Construct the JSON string
    SET @OutputJSON = 
         '[' +
        (
            SELECT
                CONVERT(NVARCHAR(23), @EndDate, 121) AS EndDate,
                @TagName1 AS TagName,
                CONVERT(DECIMAL(18, 5), @Production_value) AS 'Value'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )  
        + ']';

END

GO
