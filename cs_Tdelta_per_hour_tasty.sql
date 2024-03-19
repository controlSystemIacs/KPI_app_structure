USE [Runtime]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[cs_Tdelta_per_hour]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @Tdelta_tagnamelist NVARCHAR(MAX),
    @OutputJSON NVARCHAR(MAX) OUTPUT

AS
BEGIN

CREATE TABLE #TdeltaRate (
        EndDate DATETIME,
        TagName NVARCHAR(100),
        Tdelta_rate FLOAT
    );

DECLARE @Sql NVARCHAR(MAX)

SET @Sql = '
INSERT INTO #TdeltaRate (EndDate,TagName,Tdelta_rate)
SELECT @EndDate, TagName, AVG(Value) FROM AnalogHistory
WHERE TagName IN ('+@Tdelta_tagnamelist+')
        AND DateTime >= @StartDate
		AND DateTime <= @EndDate
        AND wwVersion = "LATEST"
        AND wwRetrievalMode = "Slope"
GROUP BY TagName
'

EXEC sp_executesql @Sql, 
                       N'@StartDate DATETIME, @EndDate DATETIME', 
                       @StartDate = @StartDate, 
                       @EndDate = @EndDate;

UPDATE #TdeltaRate
SET TagName = TagName + '_rate';

--DECLARE @OutputJSON NVARCHAR(MAX)
SET @OutputJSON = (
        SELECT 
            @EndDate AS EndDate,
            TagName, 
            CONVERT(DECIMAL(18, 5), Tdelta_rate) AS 'Value'
        FROM 
            #TdeltaRate
        FOR JSON PATH
    );

    -- Drop the temporary table
    DROP TABLE #TdeltaRate;
END
GO

 