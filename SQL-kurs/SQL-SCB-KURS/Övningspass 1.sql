/* Övningar, pass 1

Fråga 1-5

*/



-- Övning 1
USE UTB_Kurs1;

DROP TABLE IF EXISTS #Resultat

-- A&B
SELECT
	--L.Lan
	 Länsnamn = L.Namn
	--, Kommun
	, Kommunnamn = K.Namn
INTO #Resultat
FROM Lan AS L
JOIN Kommun AS K ON K.Lan = L.Lan

SELECT * FROM #Resultat

DROP TABLE #Resultat


-- C

SELECT
	T.Titel
	, F.Forlag
FROM Forlag AS F
JOIN Titlar AS T ON T.ForlId = F.ForlID
ORDER BY Titel, Forlag

-- D

SELECT DISTINCT 
	L.LanNamn
	, K.KommunNamn
FROM Lan2001_2005 AS L
JOIN KommunInv2001_2005 AS K ON K.Lan = L.Lan
ORDER BY LanNamn, KommunNamn

-- E

SELECT
	KA.KommunNamn
	, KommunArealKvKm = 1.0*KA.Areal / 100
	, KommunInv = SUM(KI.Inv)
	, BefTäthet = SUM(KI.Inv) / (1.0*KA.Areal/100)
FROM KommunAreal2000 AS KA
JOIN KommunInv2001_2005 AS KI ON KI.Kommun = KA.Kommun
WHERE KI.Ar = '2005'
GROUP BY KA.KommunNamn, 1.0*KA.Areal / 100
ORDER BY BefTäthet DESC

-- Övning 2
-- A
SELECT 
	Man
	, Kvinna
FROM Man AS M 
LEFT JOIN Kvinna AS K ON K.ID = M.ID 
ORDER BY Man

-- B

SELECT 
	KI.KommunNamn
	, SUM(Inv)
	, Areal
FROM KommunInv2001_2005 AS KI
LEFT JOIN KommunAreal2000 AS KA ON KA.Kommun = KI.Kommun
WHERE Ar = '2005'
GROUP BY KI.KommunNamn, Areal
ORDER BY Areal

-- C
SELECT 
	KommunNamn
	, K2000.Kommun
	--, Namn
FROM KommunAreal2000 AS K2000
LEFT JOIN Kommun AS K ON K.Namn = K2000.KommunNamn
WHERE NAMN IS NULL
ORDER BY KommunNamn

-- D
SELECT 
	KommunNamn
	, Namn
FROM KommunAreal2000 AS K2000
FULL OUTER JOIN Kommun AS K ON K.Namn = K2000.KommunNamn
WHERE (NAMN IS NULL OR KommunNamn IS NULL)
ORDER BY KommunNamn

-- E

SELECT KommunNamn FROM KommunInv2001_2005
EXCEPT
SELECT KommunNamn FROM KommunAreal2000

-- Övning 3
-- A

SELECT 
	M1.ID
	, M2.ID
	, Produkt =  M1.ID * M2.ID
FROM Man AS M1
CROSS JOIN Man AS M2

-- Övning 4
-- A

SELECT * FROM Kommun -- Se mer om selfjoin med nyckel som är teckensträng
WHERE Lan = '23'


-- B




-- Övning 7
-- A
USE UTB_Kurs1;

SELECT Namn, Kommun FROM Kommun
UNION
SELECT KommunNamn, Kommun  FROM KommunInv2001_2005
ORDER BY Namn

-- ÖVNING 8
-- A
SELECT 
	Lan = LEFT(Kommun, 2)
	, Kommun
FROM Kommun
WHERE RIGHT(Kommun, 1) = 9	

-- B
SELECT 
	PersonNr
	, SUBSTRING(PersonNr, 3, 2)
FROM Person2
WHERE SUBSTRING(PersonNr, 3, 2) BETWEEN 70 AND 79

-- C & D
SELECT DATEPART(YEAR, GETDATE())
SELECT DATEADD(M, 12, GETDATE())
SELECT DATEDIFF(D, GETDATE(), DATEADD(M,3, GETDATE()))

-- Övning 9

SELECT TOP 10 * FROM KommunInv2001_2005

SELECT 
	AlderGrp
	, SUB
	--, AlderGrpNamn =
	--	CASE	
	--		WHEN  BETWEEN 0 AND 14 THEN '1. Barn'
	--		else 'bajs'
	--	end
FROM KommunInv2001_2005

