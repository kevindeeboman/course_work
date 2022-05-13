/* Using PARTITION BY we can add GROUP BY values to our output without losing row level detail */

DECLARE @EXAMPLE TABLE(	
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50),
	Sales FLOAT)

INSERT INTO @EXAMPLE (Name, Sales)
VALUES
	('ERIK', 100),
	('PETRA', 200),
	('ERIK', 300),
	('PELLE', 100),
	('PELLE', 400),
	('PETRA', 100)

SELECT 
	Name
	, [SalesSubtotals] =  SUM(Sales)
FROM @EXAMPLE
GROUP BY Name

SELECT 
	Name
	, Sales
	, [SalesSubtotals] = SUM(Sales) OVER(PARTITION BY NAME)
FROM @EXAMPLE

/* As we see in the output, we can use GROUP BY without aggregating and losing row level detail */


SELECT TOP 100000
	ReferencePeriod
	, IRT.InterestRateTypeName
	, TOI.TypeOfInstrumentName
	, OutstandingNominalAmountCreditorView
	, InterestRate
INTO #TESTY
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
JOIN DW.RefTypeOfInstrument AS TOI ON TOI.TypeOfInstrument = DI.TypeOfInstrument
JOIN DW.RefInterestRateType AS IRT ON IRT.InterestRateType = DI.InterestRateType

--- Using PARTITION BY OVER 1 GROUP ---
SELECT 
	InterestRateTypeName
	, avg(OutstandingNominalAmountCreditorView)
from #TESTY
GROUP BY InterestRateTypeName

SELECT TOP 100
	*
	, [SalesSubtotals] = AVG(OutstandingNominalAmountCreditorView) OVER (PARTITION BY InterestRateTypeName)
FROM #TESTY

--- Using PARTITION BY OVER 2 GROUPS ---
SELECT 
	InterestRateTypeName
	, TypeOfInstrumentName
	, avg(OutstandingNominalAmountCreditorView)
from #TESTY
GROUP BY InterestRateTypeName, TypeOfInstrumentName

SELECT
	*
	, [SalesSubtotals] = AVG(OutstandingNominalAmountCreditorView) OVER (PARTITION BY InterestRateTypeName, TypeOfInstrumentName)
	, [SalesSubtotalsDifferential] = OutstandingNominalAmountCreditorView - AVG(OutstandingNominalAmountCreditorView) OVER (PARTITION BY InterestRateTypeName, TypeOfInstrumentName)
FROM #TESTY

DROP TABLE #TESTY