USE [Runtime]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[cs_production_kg_tasty]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @MinuteDifference INT,
    @Line NVARCHAR(100),
    @ProdRate_tagnamelist NVARCHAR(50),
    @Production_value FLOAT OUTPUT,
    @OutputJSON NVARCHAR(MAX) OUTPUT
    
AS
BEGIN


SET @Production_value=(
SELECT CASE WHEN AnalogSummaryHistory.TagName = @ProdRate_tagnamelist THEN Average*@MinuteDifference ELSE 0 END
FROM AnalogSummaryHistory
WHERE AnalogSummaryHistory.TagName = @ProdRate_tagnamelist
    AND StartDateTime >= @StartDate
	AND EndDateTime <= @EndDate
    AND wwRetrievalMode = 'Cyclic'
    AND wwCycleCount = 1
    AND wwVersion = 'LATEST'
);
   


    -- Construct the JSON string
    SET @OutputJSON = 
         '[' +
        (
            SELECT
                CONVERT(NVARCHAR(23), @EndDate, 121) AS EndDate,
                @Line +'_production' AS TagName,
                CONVERT(DECIMAL(18, 5), @Production_value) AS 'Value'
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )  
        + ']';

END

GO
