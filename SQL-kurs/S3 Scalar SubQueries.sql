/* Scalar SubQueries i.e. singel value  */

SELECT 
	FI.ReferencePeriod
	, DI.InstrumentUniqueIdentifier
	, OutstandingNominalAmount
INTO #TESTY
FROM Krita.FactInstrument AS FI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FI.InstrumentKey 
WHERE InstrumentUniqueIdentifier <= 5

SELECT 
	ReferencePeriod
	, InstrumentUniqueIdentifier
	, OutstandingNominalAmount
	--, WindowFunctionAverage = AVG(OutstandingNominalAmount) OVER() /*Both work!*/
	, SubQueryAverage = (SELECT AVG(OutstandingNominalAmount) FROM #TESTY)
	, DiffFromAvgLoanValue = OutstandingNominalAmount - (SELECT AVG(OutstandingNominalAmount) FROM #TESTY)
FROM #TESTY
ORDER BY InstrumentUniqueIdentifier, OutstandingNominalAmount DESC

/* As we see above, we can use both scalar subqueries and window functions to do the same thing.
BUT, we cannot use window functions in the WHERE clause, and this is where subqueries come in handy!
*/

SELECT 
	ReferencePeriod
	, InstrumentUniqueIdentifier
	, OutstandingNominalAmount
	, AvgLoanValue = (SELECT AVG(OutstandingNominalAmount) FROM #TESTY)
FROM #TESTY
WHERE OutstandingNominalAmount > (SELECT AVG(OutstandingNominalAmount) FROM #TESTY)
ORDER BY InstrumentUniqueIdentifier, OutstandingNominalAmount DESC

/* Using the scalar subquery in the WHERE clause we get only loans which are above the average value of loans */

SELECT 
	ReferencePeriod
	, InstrumentUniqueIdentifier
	, OutstandingNominalAmount
	, [ShareOfMax] = OutstandingNominalAmount/(SELECT MAX(OutstandingNominalAmount) FROM #TESTY)
FROM #TESTY
WHERE OutstandingNominalAmount/(SELECT MAX(OutstandingNominalAmount) FROM #TESTY) >= 0.6

/* Here we include rows only if the loan value is equal or above 60% of the highest value loan */

DROP TABLE #TESTY