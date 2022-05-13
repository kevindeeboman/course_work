/* Experimentation Query */

SELECT
	FI.ReferencePeriod
	, DI.InstrumentUniqueIdentifier
	, DRA.ReportingAgentName
	, DRA.ReportingAgentActorEntityId
	, DOA.ObservedAgentName
	, DOA.ObservedAgentActorEntityId
	, OutstandingNominalAmount
INTO #TESTY
FROM Krita.FactInstrument AS FI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FI.InstrumentKey 
JOIN Krita.DimReportingAgent AS DRA ON DRA.ReportingAgentActorKey = FI.ReportingAgentActorKey
JOIN Krita.DimObservedAgent AS DOA ON DOA.ObservedAgentActorKey = FI.ObservedAgentActorKey
WHERE DI.InstrumentUniqueIdentifier IN (SELECT TOP 1 PERCENT InstrumentUniqueIdentifier FROM Krita.DimInstrument ORDER BY NEWID())
