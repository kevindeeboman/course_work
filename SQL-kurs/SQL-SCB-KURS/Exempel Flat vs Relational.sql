USE GDB_DW2;

DROP TABLE IF EXISTS #Anst�llda, #Sektion

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

CREATE TABLE #Anst�llda
(
	Anst�lldId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Namn VARCHAR(30)
	, SektionId INT
	, ChefId INT
)

INSERT INTO #Anst�llda(Namn, SektionId, ChefId)
VALUES
(	
	'Johannes'
	, 1
	, 1
),
(
	'J�rgen'
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


SELECT * FROM #Anst�llda
SELECT * FROM #Chef
SELECT * FROM #Sektion



SELECT
	Anst�lldId
	, Namn
	, Sektion
	, Chef
	, Tele
FROM #Anst�llda AS A
JOIN #Sektion AS S ON S.SektionId = a.SektionId
JOIN #Chef AS C ON C.ChefId = A.ChefId
ORDER BY Sektion




---------------------------------------------
USE GDB_DW2;

DROP TABLE IF EXISTS #Anst�llda, #Sektion, #Chef

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
	, 'Fahl�n'
	, '0760421322'
	)

	

CREATE TABLE #Anst�llda
(
	Anst�lldId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Namn VARCHAR(50)
	, EfterNamn VARCHAR(50)
	, ChefId INT
)

INSERT INTO #Anst�llda(Namn, EfterNamn, ChefId)
VALUES
(	
	'Johannes'
	, 'Andersson'
	, 1
),
(
	'J�rgen'
	, 'J�rgensson'
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


SELECT Anst�lldId, Namn, EfterNamn, ChefId FROM #Anst�llda
SELECT * FROM #Chef



SELECT
	Anst�lldId
	, A.Namn
	, A.EfterNamn
	, C.Namn
	, C.EfterNamn
	, Tele
FROM #Anst�llda AS A
JOIN #Chef AS C ON C.ChefId = A.ChefId
ORDER BY C.Namn



