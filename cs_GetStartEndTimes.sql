SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[cs_GetStartEndTimes]
    @Frequency NVARCHAR(50),  -- Parameter to determine the frequency ('hourly', 'daily', 'running')
    @StartDate DATETIME OUTPUT, -- Output parameter for start date
    @EndDate DATETIME OUTPUT -- Output parameter for end date
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Set @EndDate and @StartDate based on the specified frequency
    IF @Frequency = 'hourly'
    BEGIN
        SET @EndDate = GETDATE();
        SET @StartDate = DATEADD(hour, -1, @EndDate);
    END
    ELSE IF @Frequency = 'daily' 
    BEGIN
        SET @EndDate = CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 101) + ' 6:00:00.000');
        SET @StartDate = DATEADD(hour, -24, @EndDate);
    END
    ELSE IF @Frequency = 'running'
    BEGIN
        SET @EndDate = GETDATE();
        IF DATEPART(HOUR, @EndDate) >= 6
            SET @StartDate = CONVERT(DATETIME, CONVERT(VARCHAR, @EndDate, 101) + ' 6:00:00.000');
        ELSE
            SET @StartDate = CONVERT(DATETIME, CONVERT(VARCHAR, @EndDate - 1, 101) + ' 6:00:00.000');
    END
    ELSE
    BEGIN
        -- Handle invalid frequency here, or set default behavior
        PRINT 'Invalid frequency specified.';
        RETURN;
    END
END
GO
