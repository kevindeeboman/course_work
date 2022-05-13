/* #Temporary tables# 
The advantage of Temp over CTEs is that we can study each step more easily
Be we cannot simply re-run our code without first dropping our table 
*/

-- DROP TABLE IF EXISTS #Testy /* If Testy EXISTS, drop it */

SELECT 
	ReferencePeriod
	, ContractIdentifier
	, InstrumentUniqueIdentifier
	, FCI.InstrumentKey
	, OutstandingNominalAmountCreditorView
	, InterestRate
INTO #Testy
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
WHERE DI.InstrumentUniqueIdentifier IN (SELECT TOP 100 InstrumentUniqueIdentifier FROM Krita.DimInstrument ORDER BY NEWID())


SELECT * FROM #Testy
ORDER BY ContractIdentifier, InstrumentUniqueIdentifier, ReferencePeriod


/* As a best practice, we drop our temp tables at the end of our script */

DROP TABLE #Testy

/* When is there an advantage in using Temporary tables?
- You need to reference one of your viritual tables in multiple outputs
- You need to join massive datasets in your virtual tables 
- You need a script instead of a query

Rule of thumb: Use CTEs when you need a single query output and when querying small to medium sized datasets.
If a CTE is running slow, use Temporary tables with optimization
*/

/* Temp tables vs Variable tables (i.e. DECLARE) 
When inserting from existing tables, check the set data type for the column to match in CREATE/DECLARE */

/* Create & Insert */

/* Using INTO we both create AND INSERT INTO our table. 
When using INTO, SQL decides which data types to use, but sometimes it can be advantageous to set these ourselves to increase perfomace
*/

DECLARE @TableVariable TABLE
(
	id INT IDENTITY(1,1) NOT NULL
	, ActorEntityId UNIQUEIDENTIFIER
	, Name NVARCHAR(200)
)

CREATE TABLE #TempTable 
(
	id int IDENTITY(1,1) NOT NULL
	, ActorEntityId UNIQUEIDENTIFIER
	, Name NVARCHAR(200)
)


INSERT INTO #TempTable (ActorEntityId, Name) /* OBS! If you dont specify the order as done here, SQL will assume selected columns are in the same order as in the created table */
SELECT 
	ReportingAgentActorEntityId 
	, ReportingAgentName
FROM Krita.DimReportingAgent
WHERE ReportingAgentValidTo IS NULL

INSERT INTO @TableVariable (ActorEntityId, Name)
SELECT 
	ReportingAgentActorEntityId 
	, ReportingAgentName
FROM Krita.DimReportingAgent
WHERE ReportingAgentValidTo IS NULL

SELECT * FROM #TempTable
SELECT * FROM @TableVariable

DROP TABLE #TempTable

/* Variable tables need to be created, inserted and used in the same query while temp tables exist even after we run our query, as such variable tables liken CTEs
The perfomace difference between temp and variable tables is minimal*/
