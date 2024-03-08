USE [RUNTIME]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--QUERING THE TEMPERATURE DIFFERENCES (DT)
--HERE WE WOULD PUT THE TDELTA TAGS E.G. Mixer100_Temperature_PV --> PC1.Fry.Oil.Tdelta.PV

DECLARE @DATE NVARCHAR(100)
SET @DATE = '2024-03-06 10:30:00.000'

SELECT CONVERT(DATETIME, @DATE) AS EndDateTime, TagName, AVG(Value) AS MEAN_DTH FROM AnalogHistory
WHERE TAGNAME IN ('Mixer100_Temperature_PV','Mixer200_Temperature_PV','Mixer300_Temperature_PV','Mixer400_Temperature_PV')
		AND DateTime >= '2024-3-6 10:20:00'
		AND DateTime <= '2024-3-6 10:30:00'
        --AND wwCycleCount = 1
        AND wwVersion = 'LATEST'
        AND wwRetrievalMode = 'Slope'
GROUP BY TagName

--QUERING THE KG PRODUCTION 
--HERE WE WOULD PUT THE PROD.RATE TAGS E.G. Mixer100_Level_PV --> PC1.Fry.Prod.Rate

DECLARE @kg1 FLOAT

SELECT  @kg1=INTEGRAL FROM AnalogSummaryHistory
WHERE TAGNAME LIKE 'Mixer100_Level_PV'
    AND StartDateTime >= '2024-3-6 10:20:00'
	AND EndDateTime <= '2024-3-6 10:30:00'
    AND wwCycleCount = 1
    AND wwVersion = 'LATEST'

SELECT EndDateTime, TagName, @kg1 AS PRODUCTION_KG, OPCQuality FROM AnalogSummaryHistory
WHERE TAGNAME LIKE 'Mixer100_Level_PV'
    AND StartDateTime >= '2024-3-6 10:20:00'
	AND EndDateTime <= '2024-3-6 10:30:00'
    AND wwCycleCount = 1
    AND wwVersion = 'LATEST'


--QUERING THE INTENSITY KPI
--HERE WE WOULD PUT THE ELEC TAGS AND THE KG TAGS E.G. Mixer100_Temperature_PV --> Elec_El_L1 ETC , KG1 = INTEGRAL(PROD.RATE)

/*CREATE TABLE #ENERGIES (EndDateTime DATETIME, TagName NVARCHAR(100), ENERGY FLOAT, OPCQuality INT)

INSERT INTO #ENERGIES (EndDateTime , TagName , ENERGY , OPCQuality)
*/
SELECT EndDateTime, TagName, Last - First AS ENERGY, OPCQuality FROM AnalogSummaryHistory
WHERE TAGNAME IN ('Mixer100_Temperature_PV','Mixer200_Temperature_PV','Mixer300_Temperature_PV','Mixer400_Temperature_PV')
    AND StartDateTime >= '2024-3-6 10:20:00'
	AND EndDateTime <= '2024-3-6 10:30:00'
    AND wwCycleCount = 1
    AND wwVersion = 'LATEST'



DECLARE @INTENSITY_TAGNAME NVARCHAR(100)
SET @INTENSITY_TAGNAME = 'POTATO_LINE1_INTESTITY'

SELECT CONVERT(DATETIME, @DATE) AS EndDateTime, @INTENSITY_TAGNAME AS TagName, SUM(ENERGY)/@kg1 AS INTENSITY_KPI FROM #ENERGIES
--DROP TABLE #ENERGIES
