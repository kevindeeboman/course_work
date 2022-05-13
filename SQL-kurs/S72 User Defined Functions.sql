/* User Defined Functions */
/* We do not have DB permission to create DB-functions */


-- Function with no Vars --
USE GDB_DW2
GO

CREATE FUNCTION dbo.ufnCurrentDate()

RETURNS DATE -- What datatype the function returns

AS

BEGIN -- Everything contained between BEGIN and END is our function
	RETURN CAST(GETDATE() AS DATE)
END

-- Function that takes Vars --

GO

CREATE FUNCTION dbo.ufnTestyResty(@StartDate DATE, @EndDate DATE)

RETURNS INT

AS

BEGIN
RETURN
(
	SELECT DATEDIFF(D, @StartDate, @EndDate)
)
END

-- Basic example of fuction that takes variables --

SELECT 
	dbo.ufnTestyResty(StartingDateOfInterestRateFixation, NextInterestRateResetDate) -- Calling a function demands (), with or without variables 
FROM Krita.FactCounterpartyInstrument AS FCI
JOIN Krita.DimInstrument AS DI ON DI.InstrumentKey = FCI.InstrumentKey

/* If multipe analysts are using some function X and declare these locally, all need to be edited if there is a change
If using a saved function, it can be edited and then used by all in the DB
*/