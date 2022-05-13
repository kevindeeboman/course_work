CREATE TABLE #TESTY
(
	ReferencePeriod DATE
	, UniqueInstrument INT
	, ONA MONEY
	, OBSA MONEY
	, [Total utlåning] MONEY
	, [Andel utstående] MONEY
	, [Lånetyp] VARCHAR(50)
	, InsertId INT
	, QUARTERZ INT
)

INSERT INTO #TESTY 
(
	ReferencePeriod
	, UniqueInstrument
	, ONA
	, OBSA
	, InsertId
)

SELECT 
	ReferencePeriod
	, DI.InstrumentUniqueIdentifier
	, OutstandingNominalAmountCreditorView
	, OffBalanceSheetAmountCreditorView
	, InsertId = 1
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON FCI.InstrumentKey = DI.InstrumentKey
WHERE DI.InstrumentUniqueIdentifier IN (SELECT TOP 10000 InstrumentUniqueIdentifier FROM Krita.DimInstrument ORDER BY NEWID())
AND OffBalanceSheetAmountCreditorView IS NOT NULL


UPDATE #TESTY
SET 
	[Andel utstående] = ONA/NULLIF((ONA+OBSA), 0)
	, [Total utlåning] = ONA + OBSA
	, Lånetyp =
		CASE
			WHEN ONA > OBSA THEN 'Utstående lån'
			WHEN ONA < OBSA THEN 'Kreditlina'
			ELSE 'VAD HÄNDER' END

UPDATE #TESTY
SET
	Lånetyp = 
		CASE
			WHEN [Andel utstående] > 0.5 THEN 'Utstående lån 2'
			WHEN [Andel utstående] < 0.5 THEN 'Kreditlina 2'
			ELSE 'FAKK' END

UPDATE #TESTY
SET 
	QUARTERZ = 4
WHERE DATEPART(QUARTER, ReferencePeriod) = 4

DELETE FROM #TESTY
WHERE QUARTERZ IS NULL

SELECT * FROM #TESTY

DROP TABLE #TESTY

