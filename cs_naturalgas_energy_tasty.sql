USE [Runtime]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[cs_naturalgas_energy_tasty]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @NGEnergy_tagnamelist NVARCHAR(MAX),
    @Json NVARCHAR(MAX) OUTPUT

    AS
BEGIN

    CREATE TABLE #EnergyResults (
        TagName NVARCHAR(100),
        Energy FLOAT,
        EndDate DATETIME
    );

    -- Dynamic SQL to construct the query with the provided tag names
    DECLARE @Sql NVARCHAR(MAX);

    SET @Sql = '
        INSERT INTO #EnergyResults (TagName, Energy, EndDate)
        SELECT 
            TagName, 
            Last - First AS Energy,
            @EndDate AS EndDate
        FROM 
            AnalogSummaryHistory
        WHERE 
            TagName IN (' + @NGEnergy_tagnamelist + ')
            AND wwVersion = ''Latest''
            AND wwRetrievalMode = ''Cyclic''
            AND wwCycleCount = 1
            AND StartDateTime >= @StartDate
            AND EndDateTime <= @EndDate
    ';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @Sql, 
                       N'@StartDate DATETIME, @EndDate DATETIME', 
                       @StartDate = @StartDate, 
                       @EndDate = @EndDate;

    -- Update the TagName column to append '_Energy_' to each value
    UPDATE #EnergyResults
    SET TagName = TagName + '_ng_energy';

    -- DECLARE @Json NVARCHAR(MAX);
    SET @Json = (
        SELECT 
            CONVERT(NVARCHAR(23), @EndDate, 121) AS EndDate,
            TagName, 
            CONVERT(DECIMAL(18, 5), Energy) AS 'Value'
        FROM 
            #EnergyResults
        FOR JSON PATH
    );

    -- Drop the temporary table
    DROP TABLE #EnergyResults;
END

GO

