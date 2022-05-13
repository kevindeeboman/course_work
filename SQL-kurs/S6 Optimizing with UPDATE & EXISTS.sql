/* Optimization */
/* Rules of thumb:
1. Define a filtered dataset as early as possible in our process, so we can JOIN additional tables to a smaller core population

2. Avoid several JOINs in a single SELECT query, especially those involving large tables.

3. Instead, use UPDATE statements to populate fields in a temp table, one source table at a time.

Why is UPDATE better than a JOIN (most of the time) -> The UPDATE statement will grab the first possible match, while in JOINs, there typically is always a possibilty of muliple matches, this leads to more table scans (SQL looking for a value) thus leading to longer query time.

4. If using JOINs, apply indexes on columns which are joined such that SQL does not have to scan the whole table to find a match
*/

/* Leverange the overall critera as early as possible! 
   For example, only instruments from 2021-12 
	If you find that your Query runs slowly, it might be worth trying UPDATE-statements instead
*/

USE GDB_DW2;


DROP TABLE IF EXISTS #FCISBABDec, #SBABDecemberInstruments

SELECT 
	InstrumentKey
	, OutstandingNominalAmountCreditorView
	, InterestRate
INTO #FCISBABDec
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
WHERE ReferencePeriod = '2021-12-31' 
AND DAR.ActorEntityId = (
SELECT ReportingAgentActorEntityId FROM Krita.DimReportingAgent
WHERE ReportingAgentValidTo IS NULL AND ReportingAgentName LIKE '%SBAB%'
)

CREATE TABLE #SBABDecemberInstruments
(
	id INT IDENTITY(1, 1) NOT NULL
	, InstrumentUniqueIdentifier BIGINT NOT NULL
	, TypeOfInstrument INT
	, TypeOfInstrumentName VARCHAR(64)
	, Purpous INT
	, PurpousName VARCHAR(64)
	, ONA FLOAT
	, InterestRateType INT
	, InterestRateTypeName VARCHAR(64)
	, InterestRate FLOAT
)

INSERT INTO #SBABDecemberInstruments
(
	InstrumentUniqueIdentifier
	, TypeOfInstrument
	, Purpous
	, ONA
	, InterestrateType
	, InterestRate
)

SELECT 
	DI.InstrumentUniqueIdentifier
	, TypeOfInstrument
	, Purpose
	, A.OutstandingNominalAmountCreditorView
	, DI.InterestRateType
	, A.InterestRate
FROM #FCISBABDec AS A
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = A.InstrumentKey

SELECT TOP 10 
	* 
FROM #SBABDecemberInstruments

-- Now we use UPDATE to fill empty fields

UPDATE #SBABDecemberInstruments
SET 
	TypeOfInstrumentName = TI.TypeOfInstrumentName
	, PurpousName = P.PurposeName
	, InterestrateTypeName = IRT.InterestRateTypeName
FROM #SBABDecemberInstruments AS A
JOIN DW.RefTypeOfInstrument AS TI ON TI.TypeOfInstrument = A.TypeOfInstrument
JOIN DW.RefPurpose AS P ON P.Purpose = A.Purpous
JOIN DW.RefInterestRateType AS IRT ON IRT.InterestRateType = A.InterestrateType

SELECT TOP 10 
	* 
FROM #SBABDecemberInstruments

DROP TABLE #FCISBABDec, #SBABDecemberInstruments
;

/* When should you use what technique?
- If you need to see all matches/information from the many side of the relationship use JOIN
- If you dont want to see matches/information from the many side, EXISTS can be used to filter
- If you want to see any (one) match/point of information from the many side, UPDATE can be used
*/

SELECT ReportingAgentParentActorEntityId, ReportingAgentFiIdentificationNumber
FROM Krita.DimReportingAgent
WHERE ReportingAgentName LIKE '%SBAB%'

SELECT 
	ReferencePeriod
	, FCI.InstrumentKey
	, TypeOfInstrument
	, Purpose
	, OutstandingNominalAmountCreditorView
INTO #SBABFebInstruments
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
WHERE DAR.FiIdentificationNumber = '32017'
AND ReferencePeriod = '2022-02-28'


SELECT * 
FROM #SBABFebInstruments AS A
WHERE EXISTS (
SELECT 'YOLO'
FROM #SBABFebInstruments AS B
WHERE A.InstrumentKey = B.InstrumentKey
AND OutstandingNominalAmountCreditorView BETWEEN 1000 AND 10000
)


DROP TABLE #SBABFebInstruments

