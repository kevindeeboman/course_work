/* Variables */
USE GDB_DW2;
-- Declaring directly
DECLARE @MyVar2 INT = 12

-- Declaring using SET
DECLARE @MyVar INT
SET @MyVar = 11

SELECT @MyVar, @MyVar2

---- Vaiables are efficient when same value in both SELECT and WHERE -clause ----
/* Using this method, we follow the principle of DRY -> Dont Repeat Yourself */
DECLARE @MyRef DATE = '2022-02-28'
DECLARE @AvgONA MONEY = (
	SELECT 
		AVG(OutstandingNominalAmountCreditorView)
	FROM Krita.FactCounterpartyInstrument AS FCI
	WHERE ReferencePeriod = @MyRef
	)

SELECT 
	ReferencePeriod
	, InstrumentUniqueIdentifier
	, DAD.Name
	, OutstandingNominalAmountCreditorView
	, AvgONA = @AvgONA
	, ONAdiffFromAvg = OutstandingNominalAmountCreditorView - @AvgONA
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN AR.DimActor AS DAD ON DAD.ActorKey = FCI.DebtorActorKey
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
WHERE OutstandingNominalAmountCreditorView >= @AvgONA
AND ReferencePeriod = @MyRef
ORDER BY ONAdiffFromAvg DESC

/* Useful for DATE-attributes */

DECLARE @Today DATE = GETDATE()

DECLARE @BOM DATE = DATEFROMPARTS(YEAR(@Today), MONTH(@Today), 1)

DECLARE @EOM DATE = EOMONTH(@Today)

SELECT @Today, @BOM, @EOM

UNION ALL

SELECT DATEADD(M, -1, @Today), DATEADD(M, -1, @BOM), EOMONTH(@EOM, -1) 


