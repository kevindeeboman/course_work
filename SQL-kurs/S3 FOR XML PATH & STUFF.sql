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
	Sales FLOAT)

INSERT INTO @EXAMPLE (EmployeeId, Name, Sales)
VALUES
	(1, 'ERIK', 100),
	(2, 'PETRA', 200),
	(1, 'ERIK', 300),
	(1, 'ERIK', 300),
	(3, 'PELLE', 100),
	(3, 'PELLE', 400),
	(2, 'PETRA', 100),
	(1, 'ERIK', 50),
	(3, 'PELLE', 600),
	(2, 'PETRA', 250),
	(1, 'ERIK', 500),
	(2, 'PETRA', 100),
	(2, 'PETRA', 200),
	(3, 'PELLE', 150),
	(4, 'GUNILLA', 100),
	(4, 'GUNILLA', 200),
	(4, 'GUNILLA', 300),
	(4, 'GUNILLA', 300),
	(4, 'GUNILLA', 100)

SELECT 
	Id
	, Name
	, AllSales  =
	STUFF(
(
SELECT ',' + CAST(Sales AS VARCHAR) FROM @EXAMPLE AS B
WHERE A.Id = B.EmployeeId
FOR XML PATH ('')
)
, 1 , 1 , '' )
FROM @EMPLOYEES AS A

/* Real testy PRO
Here we select 1000 random instruments and print all ONA values in one cell
We can add condition in the WHERE-clause, such as ONA > 0
*/

SELECT InstrumentUniqueIdentifier, InstrumentKey 
INTO #TestKeys
FROM Krita.DimInstrument
WHERE InstrumentUniqueIdentifier IN (SELECT TOP 1000 InstrumentUniqueIdentifier FROM Krita.DimInstrument ORDER BY NEWID())

SELECT TOP 100
	InstrumentUniqueIdentifier
	, InstrumentKey
	, AllONA =
	STUFF(
	(
	SELECT 
	',' + CAST(OutstandingNominalAmountCreditorView AS VARCHAR) 
	FROM Krita.FactCounterpartyInstrument AS B
	WHERE B.InstrumentKey = A.InstrumentKey 
	AND OutstandingNominalAmountCreditorView > 0
	FOR XML PATH('')
	)
	, 1,1,'')
FROM #TestKeys AS A

DROP TABLE #TestKeys

