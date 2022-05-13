
/* Using LEAD and LAG we can peer into the past and future
LEAD and LAG work with either cronological Id values or Dates
When adding an additional column this works well, but we can also use Self-joins with CTE's/EOMONTH where dates are used, to add all cols from future/past dates
*/

DECLARE @EXAMPLE TABLE(	
	SalesId INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50),
	Sales FLOAT)

INSERT INTO @EXAMPLE (Name, Sales)
VALUES
	('ERIK', 100),
	('PETRA', 200),
	('ERIK', 300),
	('ERIK', 300),
	('PELLE', 100),
	('PELLE', 400),
	('PETRA', 100),
	('ERIK', 50),
	('PELLE', 500),
	('PETRA', 300),
	('ERIK', 500),
	('PETRA', 100),
	('PETRA', 200),
	('PELLE', 150)

SELECT 
	SalesId
	, Name
	, Sales
	, NextSale = LEAD(Sales, 1) OVER(ORDER BY SALESID)
	, DiffFromNextSale = Sales - LEAD(Sales, 1) OVER(ORDER BY SALESID)
	, Sales
	, LastSale = LAG(Sales, 1) OVER(ORDER BY SALESID)
	, DiffFromLastSale = Sales - LAG(Sales, 1) OVER(ORDER BY SALESID)
FROM @EXAMPLE

/* LEAD and LAG is used over all rows, the Next or Last sale is regardless of which person made the sale
If ORDER BY is set to DESC with LEAD and LAG the functions are reversed i.e. LEAD becomes LAG and vice versa, do not use DESC
In the example above we LEAD and LAG 1 step but steps can be set to any value
*/

SELECT 
	SalesId
	, Name
	, Sales
	, PersonalLastSale = LAG(Sales, 1) OVER(PARTITION BY Name ORDER BY SALESID)
	, DiffFromPersonalLastSale = Sales - LAG(Sales, 1) OVER(PARTITION BY Name ORDER BY SALESID)
FROM @EXAMPLE

/* Here the LAG function is in relation to the partitioned groups, the last sale is not the conologically last sale, but the last sale from the given person. We can also see the difference between current and last sale by sales person.
*/


--WITH TESTY AS (
--SELECT 
--	FI.ReferencePeriod
--	, DI.InstrumentUniqueIdentifier
--	, OutstandingNominalAmount
--FROM Krita.FactInstrument AS FI
--JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FI.InstrumentKey 
--WHERE InstrumentUniqueIdentifier <= 5
--)
--SELECT 
--	ReferencePeriod
--	, InstrumentUniqueIdentifier
--	, OutstandingNominalAmount
--	, LastPeriodValue = LAG(OutstandingNominalAmount,1) OVER(PARTITION BY InstrumentUniqueIdentifier ORDER BY REFERENCEPERIOD)
--	, AcutalChangeInValue = OutstandingNominalAmount - LAG(OutstandingNominalAmount,1) OVER(PARTITION BY InstrumentUniqueIdentifier ORDER BY REFERENCEPERIOD)
--	, [%ChangeInValue] = (OutstandingNominalAmount - LAG(OutstandingNominalAmount,1) OVER(PARTITION BY InstrumentUniqueIdentifier ORDER BY REFERENCEPERIOD)) / NULLIF(LAG(OutstandingNominalAmount,1) OVER(PARTITION BY InstrumentUniqueIdentifier ORDER BY REFERENCEPERIOD), 0) * 100
--FROM TESTY
