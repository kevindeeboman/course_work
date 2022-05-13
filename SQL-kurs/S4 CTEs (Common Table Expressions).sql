/* CTE:s = Common Table Expression. Using CTE:s we can conveniently do multistep SQL analysis
This would also be possible using SubQuerys, but these are VERY hard to read */

USE GDB_DW2;

DROP TABLE IF EXISTS #rRdmKeys

SELECT TOP 100 InstrumentUniqueIdentifier 
INTO #RdmKeys
FROM Krita.DimInstrument
ORDER BY NEWID()

WITH TESTY AS (
SELECT 
	StartMonth
	, SUMTOP10 = SUM(OutstandingNominalAmountCreditorView)
	, USING_LAG = LAG(SUM(OutstandingNominalAmountCreditorView), 1) OVER(ORDER BY StartMonth)
FROM (
SELECT 
	ReferencePeriod 
	, OutstandingNominalAmountCreditorView
	, StartMonth = DATEFROMPARTS(YEAR(ReferencePeriod), MONTH(ReferencePeriod), 1)
	, Ranks = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(ReferencePeriod), MONTH(ReferencePeriod), 1) ORDER BY OutstandingNominalAmountCreditorView DESC)
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
WHERE DI.InstrumentUniqueIdentifier IN (SELECT InstrumentUniqueIdentifier FROM #RdmKeys)
) AS T
WHERE Ranks <= 10
GROUP BY StartMonth
)

SELECT 
	A.StartMonth
	,A.SUMTOP10
	,A.USING_LAG
	, B.StartMonth
	,[USING_JOIN] = B.SUMTOP10
FROM TESTY AS A
LEFT JOIN TESTY AS B ON B.StartMonth = DATEADD(MONTH, -1, A.StartMonth)

/* The self-joins can be done using both LAG or DATEADD/EOMONTH. 
Doing this with only SubQueries would be REALLY difficult
Remember how to think about DATEADD/EOMONTH: 
A-table is TODAY (T), adding +1 to table B move B one step UP (NULL at last comparison), -1 would move B DOWN (NULL at first comparison)  */

/* Recursive CTEs - Generating lists of dates/values 
To start, we need to create our "anchor" member,
*/

WITH NumberSeries AS 
(
SELECT 1 AS MyNumber	/* Anchor memeber */

UNION ALL

SELECT 
	MyNumber + 1
FROM NumberSeries		/* Recursive part */
WHERE MyNumber < 10
)
SELECT * FROM NumberSeries; /* Use semi-colon to end CTE list */

WITH DateSeries AS /* Start a-new! */
(
SELECT CAST('2000-01-01' AS date) AS MyDate

UNION ALL

SELECT 
	DATEADD(DAY, 1, MyDate)
FROM DateSeries
WHERE MyDate < EOMONTH('2000-12-01')
)

SELECT 
* 
FROM DateSeries
OPTION(MAXRECURSION 365) /* Max recursion is by default 100, set as option when recursion > 100 */

/*EOMONTH Recursion*/

WITH Date_Range AS (
SELECT EOMONTH('2018-03-01') AS Start

UNION ALL

SELECT EOMONTH(DATEADD(MONTH, +1, Start))
FROM Date_Range
WHERE Start <= DATEADD(MONTH, -1 , GETDATE())
)

SELECT * FROM Date_Range


