
/* EXISTS works similarly to JOINS in situations where there is a one-to-one relationsship between tables, BUT, when working with a one-to-many i.e. Dim-to-Fact EXISTS is much more useful
Using EXIST we can check for example, how many InstrumentUniqueId:s, which connect to different instrumentkeys over time in the fact table, contain at least on row where ONA > 10 mdkr
*/

DECLARE @EMPLOYEES TABLE (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL
)

INSERT INTO @EMPLOYEES (Name)
VALUES
	('ERIK'),
	('PETRA'),
	('PELLE'),
	('GUNILLA')

DECLARE @EXAMPLE TABLE(	
	SalesId INT IDENTITY(1,1) PRIMARY KEY,
	EmployeeId INT,
	Name VARCHAR(50),
	Sales FLOAT)

INSERT INTO @EXAMPLE (EmployeeId, Name, Sales)
VALUES
	(1, 'ERIK', 100),
	(2, 'PETRA', 200),
	(1, 'ERIK', 300),
	(1, 'ERIK', 300),
	(3, 'PELLE', 100),
	(3, 'PELLE', 400),
	(2, 'PETRA', 100),
	(1, 'ERIK', 50),
	(3, 'PELLE', 600),
	(2, 'PETRA', 250),
	(1, 'ERIK', 500),
	(2, 'PETRA', 100),
	(2, 'PETRA', 200),
	(3, 'PELLE', 150),
	(4, 'GUNILLA', 100),
	(4, 'GUNILLA', 200),
	(4, 'GUNILLA', 300),
	(4, 'GUNILLA', 300),
	(4, 'GUNILLA', 100)

select * from @EMPLOYEES


SELECT 
	Id
	, A.Name
FROM @EMPLOYEES AS A
WHERE EXISTS (
SELECT 'IT DOES NOT MATTER WHAT YOU TYPE HERE'
FROM @EXAMPLE AS B
WHERE Sales >= 300 AND B.EmployeeId = A.Id
)

/* Above we se the same condition used with JOIN and EXISTS
The difference is that EXISTS returns TRUE or FALSE while JOIN returns all actual values which satify the condition 
EXISTS stops as soon as TRUE or FLASE has been found */

SELECT 
	InstrumentUniqueIdentifier
	, InstrumentKey 
INTO #TestKeys
FROM Krita.DimInstrument
WHERE InstrumentUniqueIdentifier IN (SELECT TOP 1000 InstrumentUniqueIdentifier FROM Krita.DimInstrument ORDER BY NEWID())

SELECT 
	InstrumentUniqueIdentifier, 
	InstrumentKey 
FROM #TestKeys AS T
WHERE EXISTS 
(
SELECT 
'LETS GO'
FROM Krita.FactInstrument AS FI
WHERE OutstandingNominalAmount = 0 AND T.InstrumentKey = FI.InstrumentKey
)

SELECT 
	ReferencePeriod 
	, InstrumentKey
	, OutstandingNominalAmount
FROM Krita.FactInstrument
WHERE InstrumentKey = '11935850'

DROP TABLE #TestKeys

/* All instruments where ONA has been 0 once is returned */

/* Test case -> Show us all instruments from RA SBAB where PAV has ever been 0 */
;
WITH listOfInst AS (
SELECT InstrumentUniqueIdentifier FROM Krita.DimInstrument AS DI
WHERE EXISTS 
(
SELECT * 
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN AR.DimActor AS DA ON DA.ActorKey = FCI.ReportingAgentActorKey
WHERE DI.InstrumentKey = FCI.InstrumentKey 
AND FCI.ProtectionAllocatedValueInstrumentAggregateCreditorView = 0
AND DA.ActorEntityId = 'D4D27782-5BCC-4375-9784-44EB6DE5249E'
))

SELECT 
	ReferencePeriod
	, InstrumentUniqueIdentifier
	, FCI.InstrumentKey
	, ProtectionAllocatedValueInstrumentAggregateCreditorView
	, OutstandingNominalAmountCreditorView
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
WHERE DI.InstrumentUniqueIdentifier IN (SELECT * FROM listOfInst)
ORDER BY InstrumentUniqueIdentifier, ReferencePeriod

/* Above Query is useful when studying unique instruments where some condition has been met.
Remember to start from the aggregate level, Dim-to-Fact, using this technique in combination with SubQuerys as seen above
*/

;

/* Below is repitition!
- We find all loans that have had a load value above 10 mdkr
- We find collect all the unique identifiers for these loans
- We SUM the value of total outstaind value over time and rank the instruments by highest value
*/
SELECT
	InstrumentUniqueIdentifier
INTO #HighValueKeys
FROM Krita.DimInstrument AS DI
WHERE EXISTS
(
SELECT 'I CAN DO WHAT I WANT'
FROM Krita.FactCounterpartyInstrument AS FCI
WHERE FCI.InstrumentKey = DI.InstrumentKey
AND OutstandingNominalAmountCreditorView > 100000000000
)

SELECT * FROM #HighValueKeys
ORDER BY InstrumentUniqueIdentifier

SELECT 
	*
	, DENSE_RANK() OVER (ORDER BY MaxLoan DESC)
FROM (
SELECT 
	ReferencePeriod
	, InstrumentUniqueIdentifier
	, ReportingAgentName = DAR.Name
	, DebtorName = DAD.Name
	, OutstandingNominalAmountCreditorView
	, InterestRate
	, MaxLoan = SUM(OutstandingNominalAmountCreditorView) OVER (PARTITION BY InstrumentUniqueIdentifier)
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
JOIN AR.DimActor AS DAD ON DAD.ActorKey = FCI.DebtorActorKey
JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
WHERE DI.InstrumentUniqueIdentifier IN (SELECT InstrumentUniqueIdentifier FROM #HighValueKeys)
) AS T
ORDER BY MaxLoan DESC

DROP TABLE #HighValueKeys

