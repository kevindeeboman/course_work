/* Control Flow With IF Statements */
/* IF ELSE but i SQL */

DECLARE @MyInput INT = 4

IF @MyInput > 1
	BEGIN
		SELECT 'Hello World'
	END
ELSE
	BEGIN
		SELECT 'Farewell For Now'
	END


/* We can easily implement IF ELSE in our Stored Procedures */

CREATE PROCEDURE dbo.TestyResty (@NrRows INT, @Type INT)

AS

BEGIN
	IF @Type = 1
			BEGIN
			SELECT TOP @NrRows
				* 
			FROM GDB_DW2.Krita.FactInstrument
			END
	IF @Type = 2
			BEGIN
			SELECT TOP @NrRows
						* 
			FROM GDB_DW2.Krita.FactProtection
			END
	IF @Type = 3
			BEGIN
			SELECT TOP @NrRows
						* 
			FROM GDB_DW2.Krita.FactProtection
			END
	ELSE 
			BEGIN
			SELECT 'HELLO'
			END
END
