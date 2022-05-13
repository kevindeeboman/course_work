/* Pivot is used to flatten our data, to transpose row values into columns */

DECLARE @EMPLOYEES TABLE (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL
)

INSERT INTO @EMPLOYEES (Name)
VALUES
	('ERIK'),
	('PETRA'),
	('PELLE'),
	('GUNILLA')

DECLARE @EXAMPLE TABLE(	
	SalesId INT IDENTITY(1,1) PRIMARY KEY,
	EmployeeId INT,
	Name VARCHAR(50),
	Sales FLOAT,
	Gender VARCHAR(1))

INSERT INTO @EXAMPLE (EmployeeId, Name, Sales, Gender)
VALUES
	(1, 'ERIK', 100, 'M'),
	(2, 'PETRA', 200, 'F'),
	(1, 'ERIK', 300, 'M'),
	(1, 'ERIK', 300, 'M'),
	(3, 'PELLE', 100, 'M'),
	(3, 'PELLE', 400, 'M'),
	(2, 'PETRA', 100, 'F'),
	(1, 'ERIK', 50, 'M'),
	(3, 'PELLE', 600, 'M'),
	(3, 'PELLE', 600, 'M'),
	(2, 'PETRA', 250, 'F'),
	(1, 'ERIK', 500, 'M'),
	(2, 'PETRA', 100, 'F'),
	(2, 'PETRA', 200, 'F'),
	(3, 'PELLE', 150, 'M'),
	(4, 'GUNILLA', 100, 'F'),
	(4, 'GUNILLA', 200, 'F'),
	(4, 'GUNILLA', 300, 'F'),
	(4, 'GUNILLA', 300, 'F'),
	(4, 'GUNILLA', 100, 'F')


SELECT 
	Name
	, Sales
	, [SubTotals] = SUM(Sales) OVER(PARTITION BY NAME)
	, Gender
FROM @EXAMPLE

SELECT 
	*
FROM
(
SELECT 
	Name
	, Sales
FROM @EXAMPLE
) AS A
PIVOT (
SUM(SALES)
FOR Name IN (ERIK, GUNILLA, PELLE, PETRA)
) AS B

SELECT 
	*
FROM
(
SELECT 
	Name
	, Sales
	, Gender
FROM @EXAMPLE
) AS A
PIVOT (
SUM(SALES)
FOR Name IN (ERIK, GUNILLA, PELLE, PETRA)
) AS B

/* Any column you include in the subquery, which is not beeing aggregated or transposed, becomes a new column in our output, and our aggregated values under each (specified) column becomes are now broken down -
by each unique value in the additional column in the subquery*/