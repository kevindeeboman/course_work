/* Dymaic SQL */
/*
--- Using string concatenation we can construct SQL-code based on user input ---
In Stored Procedures, we can use IF-blocks to change output base on user input. But when the amount of outcomes grows, repetition can occure, which is not in line with DRY priciples
A solution is DynamicSQL, where we through string concatenation, can construct SQL-code using user input 

* Pros of using this technique is that no repetition means we do not have to change conditions in multiple places
* Code becomes neater and we follow the DRY-principle
*/
--USE GDB_DW2;
---- Example
--DECLARE @DynamicSQL VARCHAR(MAX)
--SET @DynamicSQL = 'SELECT TOP 100 *  FROM KRITA.FACTCOUNTERPARTYINSTRUMENT'
--EXEC(@DynamicSQL) -- Must be wrapped in parenthesis
------------------------------
-- If we could create SP:s, we would CREATE here. Variables would go in the user input slots
/*CREATE PROCEDURE dbo.DynamicSQL(@TopN VARCHAR(10), @AggFunction VARCHAR(50))*/
-- AS
-- BEGIN
DECLARE @TopN VARCHAR(10) = 3
DECLARE @AggFunction VARCHAR(50) = 'MAX'
		DECLARE @DynamicSQL1 VARCHAR(MAX)

		SET @DynamicSQL1 = 
							'
					SELECT
							*
						FROM 
						(
							SELECT 
									ReferencePeriod
								, DAR.Name
								, ONA = 
							'
		SET @DynamicSQL1 = @DynamicSQL1 + @AggFunction

		SET @DynamicSQL1 = @DynamicSQL1 + '(OutstandingNominalAmountCreditorView/1000000000), OBSA = '

		SET @DynamicSQL1 = @DynamicSQL1 + @AggFunction

		SET @DynamicSQL1 = @DynamicSQL1 + '(OffBalanceSheetAmountCreditorView/1000000000)
				, LOAN_RANK = DENSE_RANK() OVER(PARTITION BY REFERENCEPERIOD 
				  ORDER BY SUM(OutstandingNominalAmountCreditorView)+COALESCE(SUM(OffBalanceSheetAmountCreditorView),0) DESC)
			FROM Krita.FactCounterpartyInstrument AS FCI
			JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
			GROUP BY ReferencePeriod, DAR.Name
		) AS T
		WHERE LOAN_RANK <= '

		SET @DynamicSQL1 = @DynamicSQL1 + @TopN

		SET @DynamicSQL1 = @DynamicSQL1 + 'ORDER BY ReferencePeriod DESC, LOAN_RANK'

		--SELECT @DynamicSQL1

		EXEC(@DynamicSQL1)
-- END

/*
* If we did above with IF-statements, we would have to have many different verisons of the same code saved. Using this dynamic method, we dont have to repeat! Se the base query below for referennce.
*/


---- Base query below
--SELECT
--	*
--FROM 
--(
--	SELECT 
--		  ReferencePeriod
--		, DAR.Name
--		, ONA = SUM(OutstandingNominalAmountCreditorView/1000000000)
--		, OBSA = SUM(OffBalanceSheetAmountCreditorView/1000000000)
--		, LOAN_RANK = DENSE_RANK() OVER(PARTITION BY REFERENCEPERIOD 
--		  ORDER BY SUM(OutstandingNominalAmountCreditorView)+COALESCE(SUM(OffBalanceSheetAmountCreditorView),0) DESC)
--	FROM Krita.FactCounterpartyInstrument AS FCI
--	JOIN AR.DimActor AS DAR ON DAR.ActorKey = FCI.ReportingAgentActorKey
--	GROUP BY ReferencePeriod, DAR.Name
--) AS T
--WHERE LOAN_RANK <= 5
--ORDER BY ReferencePeriod DESC, LOAN_RANK
