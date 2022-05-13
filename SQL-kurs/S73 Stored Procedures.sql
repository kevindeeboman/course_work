/* Stored Procedures */


/* SP with one var */
CREATE PROCEDURE dbo.TestPurpous (@Filter INT)

AS

BEGIN
	SELECT 
		  ReferencePeriod
		, SUM(OutstandingNominalAmountCreditorView)
		, PurposeName
		, Rank_ONA = DENSE_RANK() OVER(ORDER BY SUM(OutstandingNominalAmountCreditorView) DESC)
	FROM Krita.FactCounterpartyInstrument AS FCI
	JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey
	JOIN DW.RefPurpose AS P ON P.Purpose = DI.Purpose
	WHERE ReferencePeriod = '2022-02-28'
	AND DENSE_RANK() OVER(ORDER BY SUM(OutstandingNominalAmountCreditorView) DESC) >= @Filter
	GROUP BY ReferencePeriod, PurposeName
	ORDER BY Rank_ONA
END

/* The finished SP is found under DB -> Programmability -> Stored Procedures */

EXEC dbo.TestPurpous 5 -- To run the SP. Note that for functions we need to add (), but not for SP:s

  
