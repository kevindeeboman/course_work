/*
Using OVER we can combine different levels of granualarity in one single query

When we aggregate using say SUM, we aggregate all data in the table into one value
When we then use GROUP BY we spread this SUM out by grouping all parts of the whole into small groups
When grouping our SUM, spreading it out over different groups, we cannot retain the answer of what the actual total is
Using OVER we can create a total column while still grouping, this way we can also compare our groups to some total

To do this we use WINDOW functions we can COUNT or SUM over groups of data or all data

*/

DECLARE @EXAMPLE TABLE(	
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50),
	Sales FLOAT)

INSERT INTO @EXAMPLE (Name, Sales)
VALUES
	('ERIK', 100),
	('PETRA', 200),
	('ERIK', 300),
	('PELLE', 100),
	('PELLE', 400),
	('PETRA', 100)

SELECT 
	Name
	, Sales
FROM @EXAMPLE

SELECT 
	Name
	, SUM(Sales)
FROM @EXAMPLE
GROUP BY Name

SELECT 
	Name
	, Sales
	, [Total sales] = SUM(Sales) OVER ()
	, [Max sales] = MAX(Sales) OVER ()
	, [%Of Best Performer] = Sales/MAX(Sales) OVER ()
FROM @EXAMPLE

/* Sales is a row level field which is specific to each sales person, while our window function find the max over all rows/sales persons */

WITH TESTY AS(
SELECT TOP 10000 * FROM Krita.FactCounterpartyInstrument
)

SELECT
	InstrumentKey
	, InterestRate
	, OutstandingNominalAmountCreditorView
	, [Average loan value] = AVG(OutstandingNominalAmountCreditorView) OVER ()
	, [Max loan value] = MAX(OutstandingNominalAmountCreditorView) OVER ()
	, [%Of Max loan value] = OutstandingNominalAmountCreditorView / MAX(OutstandingNominalAmountCreditorView) OVER ()
	, [Min loan value] = MIN(OutstandingNominalAmountCreditorView) OVER ()
	, [Average interest rate] = AVG(InterestRate) OVER ()
	, [Interet rate differential] = InterestRate - AVG(InterestRate) OVER ()
FROM TESTY
--- Above we find lots of examples of using the OVER clause and how we can combine row level fields with our window functions which aggreagate over all rows ---