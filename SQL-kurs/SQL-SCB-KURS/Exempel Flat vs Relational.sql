USE GDB_DW2;

DROP TABLE IF EXISTS #Anställda, #Sektion

CREATE TABLE #Chef
(
	ChefId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Chef VARCHAR(50)
	, Tele VARCHAR(50)
)

CREATE TABLE #Sektion
(
	SektionId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Sektion VARCHAR(50)
)


INSERT INTO #Chef (Chef, Tele)
VALUES
	(
	 'Jennie'
	, '0706594234'
	),
	(
	 'Anna'
	, '0760421322'
	)

	
INSERT INTO #Sektion (Sektion)
VALUES
	(
	 'VK'
	),
	(
	 'FM'
	)

CREATE TABLE #Anställda
(
	AnställdId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Namn VARCHAR(30)
	, SektionId INT
	, ChefId INT
)

INSERT INTO #Anställda(Namn, SektionId, ChefId)
VALUES
(	
	'Johannes'
	, 1
	, 1
),
(
	'Jörgen'
	, 2
	, 2
),
(
	'Farzad'
	, 2
	, 2
),
(
	'Jenny'
	, 1
	, 1
),
(
	'Maksat'
	, 2
	, 2
),
(
	'Lucy'
	, 2
	, 2
),
(
	'Sanna'
	, 1
	, 1
),
(
	'Simon'
	, 1
	, 1
)


SELECT * FROM #Anställda
SELECT * FROM #Chef
SELECT * FROM #Sektion



SELECT
	AnställdId
	, Namn
	, Sektion
	, Chef
	, Tele
FROM #Anställda AS A
JOIN #Sektion AS S ON S.SektionId = a.SektionId
JOIN #Chef AS C ON C.ChefId = A.ChefId
ORDER BY Sektion




---------------------------------------------
USE GDB_DW2;

DROP TABLE IF EXISTS #Anställda, #Sektion, #Chef

CREATE TABLE #Chef
(
	ChefId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Namn VARCHAR(50)
	, EfterNamn VARCHAR(50)
	, Tele VARCHAR(50)
)


INSERT INTO #Chef (Namn, EfterNamn, Tele)
VALUES
	(
	 'Jennie'
	 , 'Bergman'
	, '0706594234'
	),
	(
	 'Anna'
	, 'Fahlén'
	, '0760421322'
	)

	

CREATE TABLE #Anställda
(
	AnställdId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Namn VARCHAR(50)
	, EfterNamn VARCHAR(50)
	, ChefId INT
)

INSERT INTO #Anställda(Namn, EfterNamn, ChefId)
VALUES
(	
	'Johannes'
	, 'Andersson'
	, 1
),
(
	'Jörgen'
	, 'Jörgensson'
	, 2
),
(
	'Farzad'
	, 'Ashouri'
	, 2
),
(
	'Jenny'
	, 'Strandell'
	, 1
),
(
	'Maksat'
	, 'Allaberdyev'
	, 2
),
(
	'Lucy'
	, 'Lucysson'
	, 2
),
(
	'Sanna'
	, 'Stafstedt'
	, 1
),
(
	'Simon'
	, 'Simonsson'
	, 1
)


SELECT AnställdId, Namn, EfterNamn, ChefId FROM #Anställda
SELECT * FROM #Chef



SELECT
	AnställdId
	, A.Namn
	, A.EfterNamn
	, C.Namn
	, C.EfterNamn
	, Tele
FROM #Anställda AS A
JOIN #Chef AS C ON C.ChefId = A.ChefId
ORDER BY C.Namn



