/* Subqueries are best suited for two step analysis, when there are more steps, CTE's are better suited to handle this */

DECLARE @EXAMPLE TABLE(	
	SalesId INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50),
	Sales FLOAT)

INSERT INTO @EXAMPLE (Name, Sales)
VALUES
	('ERIK', 100),
	('PETRA', 200),
	('ERIK', 300),
	('ERIK', 300),
	('PELLE', 100),
	('PELLE', 400),
	('PETRA', 100),
	('ERIK', 50),
	('PELLE', 600),
	('PETRA', 300),
	('ERIK', 500),
	('PETRA', 100),
	('PETRA', 200),
	('PELLE', 150)

SELECT 
	SalesId
	, Name
	, Sales
	, RankingByPerson = ROW_NUMBER() OVER(PARTITION BY Name ORDER BY SALES DESC)
FROM @EXAMPLE

/* To find the top two sales amounts for each person, regardless of the number of records are returend, we need to use DENSE_RANK with our Subquery */

SELECT 
	*
FROM (
SELECT 
	SalesId
	, Name
	, Sales
	, RankingByPerson = DENSE_RANK() OVER(PARTITION BY Name ORDER BY SALES DESC)
FROM @EXAMPLE) AS TEST
WHERE RankingByPerson <=2