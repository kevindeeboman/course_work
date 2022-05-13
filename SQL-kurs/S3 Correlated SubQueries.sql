/* Correlated SubQueries */

SELECT
*
INTO #TESTY
FROM Krita.DimInstrument

SELECT * FROM
(
SELECT 
	InstrumentUniqueIdentifier
	, NrOfInstruments = 
	(
	SELECT 
	COUNT(*)
	FROM Krita.FactCounterpartyInstrument AS B
	WHERE A.InstrumentKey = B.InstrumentKey
	AND OutstandingNominalAmountCreditorView > 0
	)
	, MaxONA = 
	(
	SELECT MAX(OutstandingNominalAmountCreditorView)
	FROM Krita.FactCounterpartyInstrument AS B
	WHERE A.InstrumentKey = B.InstrumentKey
	)
	, MinONA = 
	(
	SELECT MIN(OutstandingNominalAmountCreditorView)
	FROM Krita.FactCounterpartyInstrument AS B
	WHERE A.InstrumentKey = B.InstrumentKey
	)
FROM #TESTY AS A
) AS T
WHERE NrOfInstruments > 20

/* For each InstrumentKey we count the number of row occurances in FactCounterpartyInstrument where ONA > 0
This is done through connecting the tables with the WHERE caluse in the subquery
*/

SELECT 
	InstrumentKey
	, Counts = COUNT(*) FROM Krita.FactCounterpartyInstrument
GROUP BY InstrumentKey
HAVING COUNT(*) > 2 AND InstrumentKey = '375115'

SELECT
	ReferencePeriod
	, InstrumentKey
	, OutstandingNominalAmountCreditorView
FROM Krita.FactCounterpartyInstrument
WHERE InstrumentKey = '375115'
ORDER BY ReferencePeriod

DROP TABLE #TESTY