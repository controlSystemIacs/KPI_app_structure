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

    
    -- Call Tdelta rate Calculation
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
    

    -- Call Production Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @Line NVARCHAR(100)
    DECLARE @ProdRate_tagnamelist NVARCHAR(50)
    DECLARE @Production_value FLOAT
    DECLARE @main_production_line1_json NVARCHAR(MAX)
    DECLARE @main_production_line2_json NVARCHAR(MAX)

    --Potato Line 1
    SET @Line = 'Potato_Line_1'
    SET @ProdRate_tagnamelist = 'Mixer100_Level_PV'

    EXEC [dbo].[cs_production_kg_tasty]
    @StartDate,
    @EndDate,
    @Line,
    @ProdRate_tagnamelist,
    @Production_value OUTPUT,
    @main_production_line1_json OUTPUT

    select @main_production_line1_json

    --Potato Line 2
    SET @Line = 'Potato_Line_2'
    SET @ProdRate_tagnamelist = 'Mixer200_Level_PV'

    EXEC [dbo].[cs_production_kg_tasty]
    @StartDate,
    @EndDate,
    @Line,
    @ProdRate_tagnamelist,
    @Production_value OUTPUT,
    @main_production_line2_json OUTPUT

    select @main_production_line2_json


    -- Call Electrical Energy Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @ElecEnergy_tagnamelist NVARCHAR(MAX)
    DECLARE @main_electrical_energies_line1_json NVARCHAR(MAX)
    DECLARE @main_electrical_energies_line2_json NVARCHAR(MAX)

    --Line 1
    SET @ElecEnergy_tagnamelist = ' "Mixer100_Level_PV","Mixer200_Level_PV" '

    EXEC [dbo].[cs_electrical_energy_tasty]
    @StartDate,
    @EndDate,
    @ElecEnergy_tagnamelist,
    @main_electrical_energies_line1_json OUTPUT

    SELECT @main_electrical_energies_line1_json

    --Line 2
    SET @ElecEnergy_tagnamelist = ' "Mixer300_Level_PV","Mixer200_Level_PV" '

    EXEC [dbo].[cs_electrical_energy_tasty]
    @StartDate,
    @EndDate,
    @ElecEnergy_tagnamelist,
    @main_electrical_energies_line2_json OUTPUT

    SELECT @main_electrical_energies_line2_json



    -- Call Natural Gas Energy Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @NGEnergy_tagnamelist NVARCHAR(MAX)
    DECLARE @main_naturalgas_energies_line1_json NVARCHAR(MAX)
    DECLARE @main_naturalgas_energies_line2_json NVARCHAR(MAX)

    --Line1
    SET @NGEnergy_tagnamelist = ' "Mixer100_Temperature_PV" '

    EXEC [dbo].[cs_naturalgas_energy_tasty]
    @StartDate,
    @EndDate,
    @NGEnergy_tagnamelist,
    @main_naturalgas_energies_line1_json OUTPUT

    SELECT @main_naturalgas_energies_line1_json

    --Line 2
    SET @NGEnergy_tagnamelist = ' "Mixer200_Temperature_PV" '

    EXEC [dbo].[cs_naturalgas_energy_tasty]
    @StartDate,
    @EndDate,
    @NGEnergy_tagnamelist,
    @main_naturalgas_energies_line2_json OUTPUT

    SELECT @main_naturalgas_energies_line2_json


    -- Call Water Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @Water_tagnamelist NVARCHAR(MAX)
    DECLARE @main_water_line1_json NVARCHAR(MAX)
    DECLARE @main_water_line2_json NVARCHAR(MAX)

    --Line 1
    SET @Water_tagnamelist = ' "Mixer100_Temperature_PV","Mixer200_Temperature_PV","Mixer300_Temperature_PV" '

    EXEC [dbo].[cs_water_tasty]
    @StartDate,
    @EndDate,
    @Water_tagnamelist,
    @main_water_line1_json OUTPUT

    SELECT @main_water_line1_json

    --Line 2
    SET @Water_tagnamelist = ' "Mixer400_Temperature_PV","Mixer200_Temperature_PV","Mixer300_Temperature_PV" '

    EXEC [dbo].[cs_water_tasty]
    @StartDate,
    @EndDate,
    @Water_tagnamelist,
    @main_water_line2_json OUTPUT

    SELECT @main_water_line2_json


    -- Call Electrical Intensity Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @electrical_intensity_tagname NVARCHAR(50)
    DECLARE @main_electrical_intensity_line1_json NVARCHAR(MAX)
    DECLARE @main_electrical_intensity_line2_json NVARCHAR(MAX)

    --Line 1
    SET @electrical_intensity_tagname = 'Potato_Line_1_electrical_intensity'

    EXEC [dbo].[cs_electrical_intensity_tasty]
    @EndDate,
    @electrical_intensity_tagname,
    @main_production_line1_json,
    @main_electrical_energies_line1_json,
    @main_electrical_intensity_line1_json OUTPUT

    SELECT @main_electrical_intensity_line1_json

    --Line 2
    SET @electrical_intensity_tagname = 'Potato_Line_2_electrical_intensity'

    EXEC [dbo].[cs_electrical_intensity_tasty]
    @EndDate,
    @electrical_intensity_tagname,
    @main_production_line2_json,
    @main_electrical_energies_line2_json,
    @main_electrical_intensity_line2_json OUTPUT

    SELECT @main_electrical_intensity_line2_json


    -- Call Natural Gas Intensity Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @naturalgas_intensity_tagname NVARCHAR(50)
    DECLARE @main_naturalgas_intensity_line1_json NVARCHAR(MAX)
    DECLARE @main_naturalgas_intensity_line2_json NVARCHAR(MAX)

    --Line 1
    SET @naturalgas_intensity_tagname = 'Potato_Line_1_ng_intensity'

    EXEC [dbo].[cs_naturalgas_intensity_tasty]
    @naturalgas_intensity_tagname,
    @main_production_line1_json,
    @main_naturalgas_energies_line1_json,
    @main_naturalgas_intensity_line1_json OUTPUT

    SELECT @main_naturalgas_intensity_line1_json

    --Line 2
    SET @naturalgas_intensity_tagname = 'Potato_Line_2_ng_intensity'

    EXEC [dbo].[cs_naturalgas_intensity_tasty]
    @naturalgas_intensity_tagname,
    @main_production_line2_json,
    @main_naturalgas_energies_line2_json,
    @main_naturalgas_intensity_line2_json OUTPUT

    SELECT @main_naturalgas_intensity_line2_json


    -- Call Water Intensity Calculation for every line
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

    DECLARE @water_intensity_tagname NVARCHAR(50)
    DECLARE @main_water_intensity_line1_json NVARCHAR(MAX)
    DECLARE @main_water_intensity_line2_json NVARCHAR(MAX)

    --Line1
    SET @water_intensity_tagname = 'Potato_Line_1_water_intensity'

    EXEC [dbo].[cs_water_intensity_tasty]
    @EndDate,
    @water_intensity_tagname,
    @main_production_line1_json,
    @main_water_line1_json,
    @main_water_intensity_line1_json OUTPUT

    SELECT @main_water_intensity_line1_json

    --Line2
    SET @water_intensity_tagname = 'Potato_Line_2_water_intensity'

    EXEC [dbo].[cs_water_intensity_tasty]
    @EndDate,
    @water_intensity_tagname,
    @main_production_line2_json,
    @main_water_line2_json,
    @main_water_intensity_line2_json OUTPUT

    SELECT @main_water_intensity_line2_json



 END
 GO
 --exec [dbo].[cs_main_tasty] @Frequency = 'hourly'
 
 