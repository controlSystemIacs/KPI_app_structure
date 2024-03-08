USE [RUNTIME]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--QUERING THE TEMPERATURE DIFFERENCES (DT)

SELECT EndDateTime, TagName, Average ,OPCQuality FROM AnalogSummaryHistory
WHERE TAGNAME in ('Mixer100_Temperature_PV','Mixer200_Temperature_PV','Mixer300_Temperature_PV','Mixer400_Temperature_PV')
		AND StartDateTime >= '2024-3-6 10:20:00'
		AND EndDateTime <= '2024-3-6 10:30:00'
        AND wwCycleCount = 1
        AND wwVersion = 'LATEST'


--QUERING THE KG PRODUCTION 

DECLARE @kg1 FLOAT

SELECT  @kg1=INTEGRAL FROM AnalogSummaryHistory
WHERE TAGNAME LIKE 'Mixer100_Level_PV'
    AND StartDateTime >= '2024-3-6 10:20:00'
	AND EndDateTime <= '2024-3-6 10:30:00'
    AND wwCycleCount = 1
    AND wwVersion = 'LATEST'

SELECT @kg1 AS PRODUCTION_KG
