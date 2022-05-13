/* Indexes */
/*
* Indexes are database objects that can make queries against your tables faster
* They do this by sorting the data in the fields they apply to - either in the table itself (clustered), or in a separate data stracture (non-clustred)
* This sorting allows the database engine to locate records within a table without having to search through the table row-by-row

--- Clustred Index ---
*** Actual sorting of the table - After 1, comes 2 etc..***
* The rows of a table with a clusterd index are physically sorted based on the field or fields the index is applied to.
* A table with a primary key is given a clustred index (based on the primary key field) by default -->
* Most tables should have at least one clustered index, as queries against tables without a clustered index generally tends to be faster
* A table may only have ONE clustered index --> You cannot sort the phone book by last name AND phone number values at the same time, same principle applies!

- Strategies -
* Apply clustered index to whatever field - or fields - are most likely to be used in a join against a table
* Ideally this field (or a combination of fields) should also be the one that most UNIQUELY defines a record in the table
* Whatevery field would be good a good candidate for a primary key of a table, is usually also a good candidate for a clustered index

--- Non-clustered index ---
*** The Table of Contets (innehållsförteckning) of a cooking book - The table is not sorted by the index, but a instruction of how to find specific recepies (values) is included***
*** Note that, as in real life, if we add another table of content, the size of the book grows, and it becomes harder, not easier to find what you are looking for, think carefully if inclusion is necessary ***
* A table may have many non-clustered indexes
* Non-clustered indexes do not physically sort the data in the table like a clustered index does
* The sorterd order of the field or fields non-clustered indexes apply to is stored in an external data structure, which works like a table of contents for the table

- Strategies -
* If you will be joining your table on field besides the one "covered" by the clustered index, consider non-clustered indexes on those fields
* You can add as many as you like, but storing additional exeternal data structures (tables of content) can penalize performace
* Fields covered by a non-clustered index should still have a high level of unqieuness

--- Indexes: General Approach ---
* Its how our table is utilized in JOINs that should drive our use and design of indexes
* You should generally add a clustered index first, and then layer in non-clustered indexes as neede to "cover" additional fields used in joins against our table
* Indexes take up memory in the database, only add them when they are NEEDED
* Indexes make inserts to tables take longer, thus you should generally add indexes AFTER data has been inserted to the table
*/

USE GDB_DW2;
DROP TABLE IF EXISTS #TESTY, #TESTY2
--- Create Clustered Index on existing temp tables ---
--- Applying Index after insert ---
SELECT 
	  FCI.ReferencePeriod
	, InstrumentUniqueIdentifier
	, FCI.InstrumentKey
INTO #TESTY
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
WHERE FCI.NextInterestRateResetDate IS NOT NULL
AND FiIdentificationNumber = '11123'
AND ReferencePeriod > '2020-01-01'

-- COMMAND					Name of index					Talbe name					Index column
CREATE CLUSTERED INDEX MaxInterestrateResetDate_idx ON #TESTY (InstrumentUniqueIdentifier)
-- Similarly for non-clustered indexes
CREATE NONCLUSTERED INDEX MaxInterestrateResetDate_idx1 ON #TESTY (InstrumentKey, ReferencePeriod)
-- As InstrumentKey does not uniquely identify an instrument over time, we need to set our index on both InstrumentKey and ReferecePeriod so that the index is UNIQUE
SELECT TOP 100 * FROM #TESTY -- As seen in the output, our table is now ordered by InstrumentUniqueIdentifier, which we have set as clustered index

--- Applying Index before insert, at table creation ---
CREATE TABLE #TESTY2
(
		ReferencePeriod DATE NOT NULL
		, InstrumentUniqueIdentifier INT NOT NULL
		, InstrumentKey INT NOT NULL
		, INDEX IUD_idx CLUSTERED (InstrumentUniqueIdentifier)
		, INDEX RefInstKey_idx NONCLUSTERED (ReferencePeriod, InstrumentKey)
)

INSERT INTO #TESTY2 (ReferencePeriod, InstrumentUniqueIdentifier, InstrumentKey)
(
	SELECT 
		  FCI.ReferencePeriod
		, InstrumentUniqueIdentifier
		, FCI.InstrumentKey
	FROM Krita.FactCounterpartyInstrument AS FCI
	JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
	JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
	WHERE FCI.NextInterestRateResetDate IS NOT NULL
	AND FiIdentificationNumber = '11123'
	AND ReferencePeriod > '2020-01-01'
)

SELECT TOP 100 * FROM #TESTY2

SELECT COUNT(*) FROM #TESTY
UNION ALL
SELECT COUNT(*) FROM #TESTY2

-- The result is the same but it is more efficient to add an index AFTER inserting data --
-- To enhance insert performance, indexes should be dropped before inserting data --





