/* Tests from part 1  */

--SELECT
--	FI.ReferencePeriod
--	, DI.InstrumentUniqueIdentifier
--	, DRA.ReportingAgentName
--	, DRA.ReportingAgentActorEntityId
--	, DOA.ObservedAgentName
--	, DOA.ObservedAgentActorEntityId
--	, OutstandingNominalAmount
--INTO #TESTY
--FROM Krita.FactInstrument AS FI
--JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FI.InstrumentKey 
--JOIN Krita.DimReportingAgent AS DRA ON DRA.ReportingAgentActorKey = FI.ReportingAgentActorKey
--JOIN Krita.DimObservedAgent AS DOA ON DOA.ObservedAgentActorKey = FI.ObservedAgentActorKey
--WHERE DI.InstrumentUniqueIdentifier IN (SELECT TOP 1 PERCENT InstrumentUniqueIdentifier FROM Krita.DimInstrument ORDER BY NEWID())

--SELECT 
--	*
--	, RankTotalPerRAOA = DENSE_RANK() OVER(ORDER BY SubTotalsPerRAOA DESC)
--FROM
--(
--SELECT
--	ReferencePeriod
--	, InstrumentUniqueIdentifier
--	, ReportingAgentName
--	, ObservedAgentName
--	, OutstandingNominalAmount
--	--, MaxValueLoan = MAX(OutstandingNominalAmount) OVER ()
--	, RankONAInstrument = DENSE_RANK() OVER (PARTITION BY InstrumentUniqueIdentifier ORDER BY OutstandingNominalAmount DESC)
--	, [ONA T-1] = LAG(OutstandingNominalAmount, 1) OVER (PARTITION BY InstrumentUniqueIdentifier ORDER BY Referenceperiod)
--	, [ONA T-1 RAOA] = LAG(OutstandingNominalAmount, 1) OVER (PARTITION BY ReportingAgentActorEntityId, ObservedAgentActorEntityId, InstrumentUniqueIdentifier ORDER BY Referenceperiod)
--	, [%ChangeONA] = (OutstandingNominalAmount/ NULLIF(LAG(OutstandingNominalAmount, 1) OVER (PARTITION BY InstrumentUniqueIdentifier ORDER BY ReferencePeriod), 0) - 1)
--	, [RankTotalONARAOA] = DENSE_RANK() OVER(PARTITION BY ReportingAgentActorEntityId ORDER BY OutstandingNominalAmount DESC)
--	, SubTotalsPerRAOA = SUM(OutstandingNominalAmount) OVER(PARTITION BY ReportingAgentActorEntityId, ObservedAgentActorEntityId)
--FROM #TESTY
--) AS T
--ORDER BY DENSE_RANK() OVER(ORDER BY SubTotalsPerRAOA) DESC

--DROP TABLE #TESTY

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
*
, RankBySubtotal = DENSE_RANK() OVER(ORDER BY TotalBySalesperson DESC)
, RankByAvg = DENSE_RANK() OVER(ORDER BY AvgBySalesperson DESC)
FROM
(
SELECT 
	SalesId
	, Name
	, Sales
	, [SalesBySalesperson T-1] = COALESCE(LAG(Sales, 1) OVER(PARTITION BY Name ORDER BY SalesId), 0)
	, [DiffFromLastSaleBySalesperson] = COALESCE(Sales - LAG(Sales, 1) OVER(PARTITION BY Name ORDER BY SalesId), Sales)
	, AvgBySalesperson = AVG(Sales) OVER(PARTITION BY NAME)
	, TotalBySalesperson = SUM(Sales) OVER(PARTITION BY Name)
	, RankBySalesperson = DENSE_RANK() OVER(PARTITION BY Name ORDER BY SALES DESC)
FROM @EXAMPLE
) as t
ORDER BY Name,  SalesId