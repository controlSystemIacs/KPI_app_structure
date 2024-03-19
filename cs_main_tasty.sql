USE [Runtime]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[cs_main_tasty]
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
    
    /* SELECT 'Main Start Date: ' + CONVERT(NVARCHAR(50), @StartDate, 121) AS [Main Start Date],
             'Main End Date: ' + CONVERT(NVARCHAR(50), @EndDate, 121) AS [Main End Date];
    */

    
    -- Call Production Calculation
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @Tdelta_tagnamelist NVARCHAR(MAX)
    DECLARE @main_Tdelta_per_hour_json NVARCHAR(MAX)




    SET @Tdelta_tagnamelist = ' "Mixer100_Temperature_PV","Mixer200_Temperature_PV","Mixer300_Temperature_PV","Mixer400_Temperature_PV" '
 
    

    EXEC [dbo].[cs_Tdelta_per_hour] 
    @StartDate, 
    @EndDate,
    @Tdelta_tagnamelist,
    @main_Tdelta_per_hour_json OUTPUT;

select @main_Tdelta_per_hour_json
 
DECLARE @Line NVARCHAR(100)
DECLARE @ProdRate_tagnamelist NVARCHAR(50)
DECLARE @Production_value FLOAT
DECLARE @main_production_json NVARCHAR(MAX)

SET @Line = 'Potato_Line_1'
SET @ProdRate_tagnamelist = 'Mixer100_Level_PV'

EXEC [dbo].[cs_production_kg_tasty]
@StartDate,
@EndDate,
@Line,
@ProdRate_tagnamelist,
@Production_value OUTPUT,
@main_production_json OUTPUT

--select @Production_value
select @main_production_json


DECLARE @ElecEnergy_tagnamelist NVARCHAR(MAX)
DECLARE @main_electrical_energies_json NVARCHAR(MAX)

SET @ElecEnergy_tagnamelist = ' "Mixer100_Level_PV","Mixer200_Level_PV","Mixer300_Level_PV","Mixer400_Level_PV" '

EXEC [dbo].[cs_electrical_energy_tasty]
@StartDate,
@EndDate,
@ElecEnergy_tagnamelist,
@main_electrical_energies_json OUTPUT

SELECT @main_electrical_energies_json


DECLARE @NGEnergy_tagnamelist NVARCHAR(MAX)
DECLARE @main_naturalgas_energies_json NVARCHAR(MAX)

SET @NGEnergy_tagnamelist = ' "Mixer100_Temperature_PV","Mixer200_Temperature_PV","Mixer300_Temperature_PV","Mixer400_Temperature_PV" '

EXEC [dbo].[cs_naturalgas_energy_tasty]
@StartDate,
@EndDate,
@NGEnergy_tagnamelist,
@main_naturalgas_energies_json OUTPUT

SELECT @main_naturalgas_energies_json


DECLARE @Water_tagnamelist NVARCHAR(MAX)
DECLARE @main_water_json NVARCHAR(MAX)

SET @Water_tagnamelist = ' "Mixer100_Temperature_PV","Mixer200_Temperature_PV","Mixer300_Temperature_PV","Mixer400_Temperature_PV" '

EXEC [dbo].[cs_water_tasty]
@StartDate,
@EndDate,
@Water_tagnamelist,
@main_water_json OUTPUT

SELECT @main_water_json


/*
DECLARE @Elec_tagnamelist NVARCHAR(MAX)
DECLARE @main_intensities_json NVARCHAR(MAX)

SET @Elec_tagnamelist = ' "Mixer100_Temperature_PV","Mixer200_Temperature_PV","Mixer300_Temperature_PV","Mixer400_Temperature_PV" '

 EXEC [dbo].[cs_intensity_tasty]
@StartDate,
@EndDate,
@Elec_tagnamelist,
@main_intensities_json

select @main_Tdelta_per_hour_json
SELECT @main_intensities_json

 */


 END
 GO
 --exec [dbo].[cs_main_tasty] @Frequency = 'running'
 
 