
-- Exempel 1 --
USE GDB_DW2;
SELECT
	  ReferencePeriod
	, ReportingAgentIdentifier
	, M.ValidationType
	, A.ValidationIdentifier
	, NrOfErrors
	, M.ValidationIdentifier
FROM Krita.Krita_ActiveFileValidationResult AS A
LEFT JOIN Krita.RefKritaValidationRuleMetadata AS M ON M.ValidationIdentifier = A.ValidationIdentifier
WHERE ReferencePeriod >= DATEADD(m,-1,(SELECT MAX(ReferencePeriod) FROM Krita.DimKritaFileMetadata))


SELECT
	  A.ReferencePeriod
	, A.ReportingAgentIdentifier
	, M.ValidationType
	, M.ValidationIdentifier
	, A.NrOfErrors
FROM Krita.RefKritaValidationRuleMetadata AS M
LEFT JOIN Krita.Krita_ActiveFileValidationResult AS A ON A.ValidationIdentifier = M.ValidationIdentifier
--WHERE ReferencePeriod >= DATEADD(m,-1,(SELECT MAX(ReferencePeriod) FROM Krita.DimKritaFileMetadata))
ORDER BY NrOfErrors DESC


/* Problem: Vid 0 antal valideringsfel görs ingen hämtning av data. I grafer hoppas dessa perioder över eftersom data fattas
   En lösning är således att ta med samtliga valideringsidentifierar för alla UL:s oavsett om den finns eller inte, om den ej existerar i perioden sätt antal fel = 0
   Vi kan lösa detta tekniskt genom att skapa upp en lista på alla unika kombinationer av UL, valideringsidentifierare och referensperiod med CROSS APPLY och DISTINCT
*/


SELECT DISTINCT 
	m.ValidationIdentifier
FROM Krita.RefKritaValidationRuleMetadata AS M

SELECT DISTINCT 
	  ReferencePeriod
	, m.ValidationIdentifier
	, ReportingAgentIdentifier = InstitutionCode
INTO #RaIdentifier
FROM Krita.RefKritaValidationRuleMetadata AS M
CROSS JOIN 
		(
		SELECT ReferencePeriod, DAR.InstitutionCode FROM Krita.FactCounterpartyInstrument AS FCI
		JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
		) AS T
WHERE ReferencePeriod >= DATEADD(m,-36,(SELECT MAX(ReferencePeriod) FROM Krita.DimKritaFileMetadata))

SELECT * FROM #RaIdentifier
ORDER BY ValidationIdentifier, ReportingAgentIdentifier, ReferencePeriod

SELECT 
	DRA.ReportingAgentName
	, COUNT(ReportingAgentIdentifier)
	, SUM(COUNT(ReportingAgentIdentifier)) OVER()
FROM #RaIdentifier AS A 
JOIN Krita.DimReportingAgent AS DRA ON DRA.ReportingAgentInstitutionCode = A.ReportingAgentIdentifier
WHERE DRA.ReportingAgentValidTo IS NULL
GROUP BY ReportingAgentName

-- Per UL: 6734   (1*37*182)
-- Danske hypotek ny UL: 121 576 (18*37*182) + (1*2*182)
SELECT 18*37*182+1*2*182
-- Total:  127946 (19*37*182) + (1*2*182)

----Test--
--SELECT 
--	  A.ReferencePeriod
--	, RAI.ReferencePeriod
--	, RAI.ReportingAgentIdentifier
--	, A.ReportingAgentIdentifier
--	, RAI.ValidationIdentifier
--	, A.ValidationIdentifier
--	, NrOfErrors
--FROM #RaIdentifier AS RAI
--LEFT JOIN Krita.Krita_ActiveFileValidationResult AS A 
--ON A.ValidationIdentifier = RAI.ValidationIdentifier AND A.ReportingAgentIdentifier = RAI.ReportingAgentIdentifier AND A.ReferencePeriod = RAI.ReferencePeriod
--WHERE RAI.ReportingAgentIdentifier = '5164010091'
--AND RAI.ReferencePeriod >= DATEADD(m,-36,(SELECT MAX(ReferencePeriod) FROM Krita.DimKritaFileMetadata))
--ORDER BY RAI.ReferencePeriod

------

-- Förväntat resultat --
SELECT 
	  RAI.ReferencePeriod
	, RAI.ReportingAgentIdentifier
	, RAI.ValidationIdentifier
	, COALESCE(NrOfErrors, 0)
FROM #RaIdentifier AS RAI
LEFT JOIN Krita.Krita_ActiveFileValidationResult AS A 
ON A.ValidationIdentifier = RAI.ValidationIdentifier AND A.ReportingAgentIdentifier = RAI.ReportingAgentIdentifier AND A.ReferencePeriod = RAI.ReferencePeriod
WHERE RAI.ReferencePeriod >= DATEADD(m,-36,(SELECT MAX(ReferencePeriod) FROM Krita.DimKritaFileMetadata))
ORDER BY RAI.ReferencePeriod, NrOfErrors DESC

DROP TABLE #RaIdentifier

SELECT DATEADD(m,-36,(SELECT MAX(ReferencePeriod) FROM Krita.DimKritaFileMetadata))
-------------- Antal förväntade rader ------------------
SELECT COUNT(ValidationIdentifier) FROM Krita.RefKritaValidationRuleMetadata
SELECT COUNT(DISTINCT ReportingAgentIdentifier) FROM Krita.Krita_ActiveFileValidationResult
SELECT 19*182 -- 19 UL:s och 182 valideringsregler
SELECT 1*182*37 -- Per UL, 37 eftersom innevarande månad räknas med!
SELECT 19*182*37 -- Total

-- Exempel 2--

USE GDB_DW2;
DROP TABLE IF EXISTS #CustomRef, #StatusFrame, #Data
-- Notera att attributet endast rapporteras på kvartalsfrekvens --
DECLARE @AntalKvartal INT = 1 -- Ställ in antal kvartalsperioder här
DECLARE @StartDatum DATE = DATEADD(Q,-1*@AntalKvartal, GETDATE())
------------------------------------------------------------------
SELECT 
	StatusOfForbearanceAndRenegotiation
	, StatusOfForbearanceAndRenegotiationName
INTO #CustomRef
FROM DW.RefStatusOfForbearanceAndRenegotiation

INSERT INTO #CustomRef 
VALUES
	(0, 'IS_NULL')

SELECT DISTINCT
	ReferencePeriod
	, ReportingAgentIdentifier = FiIdentificationNumber
	, ReportingAgentName = Name
	, StatusOfForbearanceAndRenegotiation
	, StatusOfForbearanceAndRenegotiationName
INTO #StatusFrame
FROM #CustomRef
CROSS JOIN
		(
		SELECT ReferencePeriod, DAR.FiIdentificationNumber, DAR.Name FROM Krita.FactAccounting AS FA
		JOIN AR.DimActor AS DAR ON DAR.ActorKey = FA.ReportingAgentActorKey
		) AS T
WHERE ReferencePeriod BETWEEN @StartDatum AND EOMONTH(GETDATE())

SELECT 
	  FA.ReferencePeriod
	, ReportingAgentIdentifier = DAR.FiIdentificationNumber
	, StatusOfForbearanceAndRenegotiation = COALESCE(StatusOfForbearanceAndRenegotiation, 0)
	, Count_SOFAR = COUNT(*)
	, Count_RA_RefTot = SUM(COUNT(*)) OVER(PARTITION BY FA.ReferencePeriod, DAR.FiIdentificationNumber)
	, SOFAR_SHARE = CAST(1.0*COUNT(*) / NULLIF(SUM(COUNT(*)) OVER(PARTITION BY FA.ReferencePeriod, DAR.FiIdentificationNumber), 0) AS DECIMAL(18,4))
	, NULL_SHARE_DATE = CAST(1.0*SUM(CASE WHEN DateOfTheForbearanceAndRenegotiationStatus IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(18,4))
	, ONA_MKR = SUM(OutstandingNominalAmountCreditorView)/1000000
	, CAI_MKR = SUM(CommitmentAmountAtInceptionCreditorView)/1000000
	, OBSA_MKR = SUM(OffBalanceSheetAmountCreditorView)/1000000
INTO #Data
FROM Krita.FactAccounting AS FA
JOIN Krita.DimAccounting AS DA ON DA.AccountingKey = FA.AccountingKey
JOIN AR.DimActor AS DAR ON DAR.ActorKey = FA.ReportingAgentActorKey
JOIN Krita.FactCounterpartyInstrument AS FCI ON FCI.InstrumentKey = FA.InstrumentKey AND FCI.ReferencePeriod = FA.ReferencePeriod
WHERE FA.ReferencePeriod BETWEEN @StartDatum AND EOMONTH(GETDATE())
GROUP BY FA.ReferencePeriod, FiIdentificationNumber, StatusOfForbearanceAndRenegotiation
ORDER BY ReportingAgentIdentifier, FA.ReferencePeriod DESC, StatusOfForbearanceAndRenegotiation DESC


SELECT 
	  F.ReferencePeriod
	, F.ReportingAgentIdentifier
	, ReportingAgentName
	, F.StatusOfForbearanceAndRenegotiation
	, StatusOfForbearanceAndRenegotiationName
	, Count_SOFAR = COALESCE(Count_SOFAR,0)
	, Count_RA_RefTot = COALESCE(Count_RA_RefTot, MAX(Count_RA_RefTot) OVER(PARTITION BY F.ReportingAgentIdentifier, F.ReferencePeriod), 0)
	, SOFAR_SHARE = COALESCE(SOFAR_SHARE,0)
	, NULL_SHARE_DATE = COALESCE(NULL_SHARE_DATE,0)
	, ONA_MKR = COALESCE(ONA_MKR,0)
	, CAI_MKR = COALESCE(CAI_MKR,0)
	, OBSA_MKR = COALESCE(OBSA_MKR,0)
FROM #StatusFrame AS F
LEFT JOIN #Data AS D ON D.ReferencePeriod = F.ReferencePeriod AND D.ReportingAgentIdentifier = F.ReportingAgentIdentifier AND D.StatusOfForbearanceAndRenegotiation = F.StatusOfForbearanceAndRenegotiation
ORDER BY ReportingAgentIdentifier, F.ReferencePeriod DESC, StatusOfForbearanceAndRenegotiation DESC

