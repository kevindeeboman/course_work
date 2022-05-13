/*
 --- Good 2 know ---
* DDL = Data Definiton Language
-- Commands pretain to the structure and definition of tables, and include CREATE, DROP, and TRUNCATE
* DML = Data Manipulation Language
-- Commands pretain to manipulate data within tables, and include INSERT, UPDATE and DELETE
*/

/* Lookup Tables */
/*
--- Make somethin permanent with your knowledge of temp tables! ---
-- Benefits of Lookup tables
 * Eliminates duplicated effort by locating frequently used attributes in one place
 * Promotes data integrity by consolidating a "single version of the truth" in a central location
Example of useful Lookup table --> Date table 
*/

DROP TABLE IF EXISTS #DateLookUp

CREATE TABLE #DateLookUp
(
	  DateValue DATE
	, DayOfWeekNumber INT
	, DayOfWeekName VARCHAR(32)
	, DayOfMonthNumber INT
	, MonthNumber INT
	, YearNumber INT
	, WeekendFlag TINYINT
	, HolidayFlag TINYINT
);

WITH Dates AS
(
SELECT MyDate = CAST('01-01-2018' AS DATE)

UNION ALL

SELECT DATEADD(D, 1, MyDate)
FROM Dates
WHERE MyDate < CAST('12-31-2030' AS DATE)
)

INSERT INTO #DateLookUp (DateValue)
SELECT * FROM Dates
OPTION (MAXRECURSION 10000)

--SELECT * FROM #DateLookUp

/*
"d"	The day of the month, from 1 through 31.
"dd"	The day of the month, from 01 through 31.
"ddd"	The abbreviated name of the day of the week.
"dddd"	The full name of the day of the week.
*/

UPDATE #DateLookUp
SET
	  DayOfWeekNumber = DATEPART(WEEKDAY, DateValue)
	, DayOfWeekName = FORMAT(DateValue, 'dddd')
	, DayOfMonthNumber = DAY(DateValue)
	, MonthNumber = MONTH(DateValue)
	, YearNumber = YEAR(DateValue)


UPDATE #DateLookUp
SET 
	WeekendFlag = 
		CASE 
			WHEN DayOfWeekName IN ('lördag', 'söndag') THEN 1 
			ELSE 0 
		END


SELECT 
	  ReferencePeriod
	, DAR.Name
	, InstrumentUniqueIdentifier
	, SettlementDate
	, SettlementDateDayName = D.DayOfWeekName
	, WeekendFlag
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
JOIN #DateLookUp AS D ON D.DateValue = DI.SettlementDate
WHERE DAR.FiIdentificationNumber = '11123'
AND WeekendFlag = 1
AND ReferencePeriod >= '2022-01-01'

