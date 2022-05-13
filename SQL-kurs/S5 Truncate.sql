/* TURNCATE - For clearing and re-using tables! */

CREATE TABLE #InstProt
(
	Referenceperiod DATE,
	InstrumentKey VARCHAR(100),
	Valuess FLOAT,
	Ranks INT
)

INSERT INTO #InstProt (Referenceperiod, InstrumentKey, Valuess, Ranks)
SELECT 
	ReferencePeriod
	, InstrumentKey
	, OutstandingNominalAmountCreditorView
	, Ranks = ROW_NUMBER() OVER(PARTITION BY ReferencePeriod ORDER BY OutstandingNominalAmountCreditorView DESC)
FROM Krita.FactCounterpartyInstrument AS FCI

CREATE TABLE #Top10InstProt
(
	ReferencePeriod DATE
	, Typez VARCHAR(50)
	, Valuess FLOAT
)

INSERT INTO #Top10InstProt (ReferencePeriod, Typez, Valuess)
SELECT 
	Referenceperiod
	, Typez = 'Instrument'
	, SUM(Valuess)
FROM #InstProt
WHERE Ranks <= 10
GROUP BY Referenceperiod

TRUNCATE TABLE #InstProt /* Here we clear the table for re-use since the data uses the same structure */

INSERT INTO #InstProt (Referenceperiod, InstrumentKey, Valuess, Ranks)
SELECT 
	ReferencePeriod
	, ProtectionKey
	, ProtectionValue
	, ROW_NUMBER() OVER(PARTITION BY ReferencePeriod ORDER BY ProtectionValue DESC)
FROM Krita.FactProtection


INSERT INTO #Top10InstProt (ReferencePeriod, Typez, Valuess)
SELECT
	Referenceperiod
	, Typez = 'Protection'
	, SUM(Valuess)
FROM #InstProt
WHERE Ranks <= 10
GROUP BY Referenceperiod


SELECT 
	A.ReferencePeriod
	, A.Typez
	, A.Valuess / 1000000000
	, B.Valuess / 1000000000
FROM #Top10InstProt AS A
LEFT JOIN #Top10InstProt AS B ON A.Typez = B.Typez
AND B.ReferencePeriod = EOMONTH(A.ReferencePeriod, -1)
ORDER BY Typez, ReferencePeriod

DROP TABLE #InstProt
DROP TABLE #Top10InstProt