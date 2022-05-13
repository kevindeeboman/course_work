/*
* Vi har en SQL-server (Login) - Databaser (user, role)
  Windows sl�pper in oss i databasen

* Win-PC (Klient) - Management studio -> SQL-server 
  T-SQL (Tansact-SQL) -> Microsofts verison av SQL. Query (fr�ga) -- fr�ga skickas till servern --> Respons (Kontrollerar tabellplaner, index och cachar svar)

* RDBMS (Relational Database Management System) --> SQL �r en relationsdatabashanterare

* Normalisera data -> Skapar tabeller f�r att lagra saker effektivt. En rad per sak, en sak per rad. Konsistens, integritet, ej dubbellagring.
  OBS! Detta �r det f�rsta vi ska ha koll p� n�r det g�ller databaser!
  --> Exempel
	1. Liza, Marklund, De G�mda, Bonnier
	2. Bror, Marklund, V�gen, Bonnier
	3. Liza, Jansson, Bron, Bonnier
	4. Patrik, Lennart, NULL
	Vad �r det p� raden som �r kopplat till saken (i detta fall f�rfattaren)?
	 -> VAD FINNS P� RADEN SOM INTE �R DIREKT KOPPLAT TILL ID:et?
		* Boktitel �r inget som identifierar F�rfattare, d�rf�r f�r de inte vara p� samma rad, dessa b�r flyttas till en egen tabell -> Titel
		* F�rlag har inte heller med f�rfattaren att g�ra. Det �r �ven en dublett eftersom vi repeterar SAMMA entitet flera g�nger -> Det finns bara ETT Bonnier (i.e. f�rlagstabell), ETT Stockholm (i.e. Stadstabell)
		* Vi hade sannolikt �ven samlat f�rlagID i Titeltabellen
-> Vi lagrar bara en identitet/enhet per tabell, i tabellen F�rfattare lagras endast f�rfattar, samma g�ller 

* Identitetsnyckeln = Primary Key = F�rs�krar att varje rad �r unik

Standardformat och exekveringsf�ljd:

5 SELECT
1 FROM + JOIN
2 WHERE
3 GROUP BY
4 HAVING  (Som en WHERE f�r GROUP BY)
6 ORDER BY
Execute order differs from write order
-> Varf�r kan vi inte anv�nda ett synonym i WHERE? Eftersom SELECT sker sist!

Prioriteringsregler
1. ~
2. *, /, %
3. +, -
4. NOT
5. AND
6. ALL, ANY
7. =

BETWEEN -> Allt inom ett intervall
IN -> Inom alla angivna v�rden

N�r du har ett attribut i kolumnlistan som ej �r aggregerat s� m�ste den inneh�llas i din GROUP BY


Temptabell:
SELECT
INTO #Testy (#=local temp, last connection drops table) -> Endast anv�ndbar i din nuvarande session 
			 ##=global temp
Tempor�ra tabeller hanmnar i System Databases -> Temporary Tables 

N�r vi designar v�ra tabeller s� t�nk f�ljande f�r att f� till Normalisering:
Varjetabell ska bara vid givet namn, ska endast anv�ndas f�r att identifiera det som tabellen heter.
T.ex. Tabelle F�rfattare ska endast inneh�lla data f�r att identifiera den givna f�rfattaren 

Primary Key och Foreign Key m�ste agnes vid uppskapande av tabeller

-----------------------JOINS ------------------------
LEFT, RIGHT och FULL �r alla OUTER JOINS
Po�ngen med Normalisering �r delvis att JOINS inte ska ge NULL

INNER JOIN 
WHERE sker efter din JOIN!
-----------------------------------------------------
Anpassa datatyp utefter faktiska storleken p� v�rdena i kolumnen
				   tinyint
				   smallint
32 miljoner tecken int


fixerad teckenstr�ng    -> char(50) inneh�ller alltid 50 tecken, kommer fylla ut till 50 om du inte angivit
variernade teckenstr�ng -> varchar(50) kan inneh�lla f�rre eller lika med 50 tecken, d�remot m�ste SQL kontrollera antal h�r

*/

DROP TABLE IF EXISTS Employees, City

CREATE TABLE City
(
	CityID INT IDENTITY(1,1) PRIMARY KEY
	, City VARCHAR(50) NOT NULL
	, CityRank INT NOT NULL
)

INSERT INTO City (City, CityRank)
VALUES
	('�rebro', 5)
	, ('G�teborg', 4)
	, ('Stockholm', 3)
	, ('V�nersborg', 2)
	, ('Varberg', 1)
	, ('Falkenberg', 6)
	, ('Kungsbacka', 7)

CREATE TABLE Employees 
(
	EmployeeID INT IDENTITY(1,1) PRIMARY KEY
	, Fname VARCHAR(50) NOT NULL
	, Mname VARCHAR(50) NULL
	, Lname VARCHAR(50) NOT NULL
	, CityID INT NOT NULL FOREIGN KEY REFERENCES City (CityID) -- Refererar tillbaka till CITY. Snubben satta CONSTRAINT framf�r sin skapelse, se mer varf�r...
	--ON DELETE CASCADE/SET NULL, finns alternativ p� vad som kan h�nda om saker �ndras med CityID. CASCADE hade tagit bort alla anst�llda givet att CityID i city-tabellen f�rsvunnit. D�rmed, om G�teborg f�rsvinner s� skulle Patrik f�rsvinna.
	--ON UPDATE XXXX, samma sak h�r, vi kan ha automatiska reponser p� utdates givet att CityID �ndras.
)


INSERT INTO Employees(Fname, Lname, CityID)
VALUES
	('Patrik', 'Rhenberg', 1)
	, ('Tim', 'Sandstr�m', 3)
	, ('Kevin', 'Dee', 3)
	, ('Kine', 'Boman', 5)
	-- F�r att testa att FK funkar -- ('FEL', 'FEL', 100)

-- FROM [UTB_ElevO03].[dbo].[MinTestInforKurs] -- FQN = Fully Qualified Name

/* N�r relationen City till Employees finns, kan vi inte l�ngre l�gga till rader i employees till st�der som inte finns i City */


SELECT 
	EmployeeID
	, Fname
	, Lname
	, City
FROM Employees AS E
CROSS JOIN City 


--DROP TABLE Employees, City


-------- �terigen JOINS ---------

/* 
LEFT JOIN kommer alltid referera till tabellen som �r i FROM
RIGHT JOIN kommer alltid referea till tabellen som �r i JOIN:en

LEFT JOIN .WHERE IS NULL -> Tar fram de som �r exklusiva f�r en tabell, t.ex. f�rfattare som inte har skrivit n�gon bok.

Anv�ndningsomr�de f�r FULL OUTER JOIN?
Fr�gan kan svara p� b�de:
Vilka kunder har inte handlat?
Vilka produkter har inte k�pts av en kund?


CROSS JOIN (NYHET) Samtliga v�rden i enda tabellen joinas mot varje rad i den andra tabellen
Givet tv� tabeller -> T1 3 rader och T2 4 rader kommer 12 kombinationer skapas
En "Kartesisk produk" se mer

Inget ON i CROSS JOIN eftersom alla joinas p� allt

Anv�ndningsomr�den?
F�r att skapa en mega-tabell kan vi CROSS JOIN:a tv� stora tabeller t.ex. 1 000 * 100 000 = 1 000 000 000

*/
-- Self join tillsammans med City-tabellen 
SELECT 
	C1.City
	, C2.City
FROM City AS C1
CROSS JOIN City C2


SELECT 
	C1.City
	, Ranking = C1.CityRank
	, C2.City
	, C2.CityRank
FROM City AS C1
JOIN City AS C2 ON C2.CityRank = C1.CityRank + 1
ORDER BY Ranking -- Det funkar att anv�nda denna synonym eftersom FROM �r f�re i exikveringsordern, ORDER BY sker sist!

--UNION tar endast med UNIKA rader
SELECT 1
UNION
SELECT 1
UNION 
SELECT 1 -- Blir en rad

-- UNION ALL tar med alla rader oavsett
SELECT 1
UNION ALL
SELECT 1
UNION ALL
SELECT 1 -- Blir tre rader

-- INTERSECT & EXCEPT --> T-SQL COMMANDON

-- EXCEPT    --> Ge mig alla i den f�rsta som inte finns i den andra (LEFT JOIN WHERE, alla unika f�r f�rsta)
-- Vi kan l�tt v�nda p� EXCEPT f�r f� unika f�r andra tabellen
-- INTERSECT --> Ge mig alla som finns i b�da (INNER JOIN MATCH, alla som finns i b�da)

-- VIEWS ------------------------------------------------------------------------------------------------------------------------------
-- Databaser har objekt. En vy �r en definition, vyn i sig inneh�ller ingen information utan definitionen av informationen som ska visas
-- Se mer om Matrialiserade vyer --
USE UTB_ElevO03;
CREATE VIEW NuvarandeKrita_View -- CREATE m�ste k�ra f�rsig
WITH ENCRYPTION -- L�ser objektet 
AS
(
SELECT 
	* 
FROM dbo.DimTeamKrita
WHERE ValidTo IS NULL
)

SELECT * FROM NuvarandeKrita_View

SELECT * FROM sys.objects
WHERE type_desc = 'view' -- H�r ser vi objekten i DB som �r Vy

UPDATE NuvarandeKrita_View -- Vi kan modifiera tabellerna via en Vy! Det �r mycket "billigare" att editera mot grundtabellerna, se exekveringsplan
SET ValidFrom = '2020-01-01', ValidTo = '2021-01-01'
WHERE UserId = 5

SELECT * FROM DimTeamKrita -- Mitt Start och Slutdatum har modifierats
--DROP VIEW NuvarandeKrita_View
------------------------------------------------------------------------------------------------------------------------------------------

-- STORED PROCEDURE --
-- St�djer variabler som input, kan ta emot argument (UTVECKLARKURSEN)
CREATE PROC USP_UpdateDates
@StartDate DATE
, @EndDate DATE
, @Id INT
AS
UPDATE DimTeamKrita
SET ValidFrom = @StartDate, ValidTo = @EndDate
WHERE UserId = @Id

SET STATISTICS IO ON
-- Update through proc
--
EXEC USP_UpdateDates ('2020-01-01', '2040-01-01', 5)

SELECT * FROM DimTeamKrita

-- VIEWS och STORED PROCEDURE --
-- Samma princip fast en procedur kan ta emot en variabel -- i.e. det �r en funktion som DEF i Python --

-- CREATE - Skapa
-- ALTER  - �ndra
-- UPDATE - Uppdatera

------------------- Dag 2 ----------------------
--- Funktioner ---
/*
Str�ngfunktioner
SubString och CharIndex
*/

SELECT 
	Namn = 'Liza Marklund'
INTO #Testys
SELECT
	SUBSTRING(Namn , 1, 1) + SUBSTRING(Namn, CHARINDEX(' ', Namn), LEN(Namn)) 
FROM #Testys
DROP TABLE #Testys

-- Datumfunktioner
SELECT YEAR(GETDATE()) + 10 AS YEAR

-- Konvertera format
SELECT CAST(GETDATE() AS VARCHAR)
SELECT CONVERT(VARCHAR, GETDATE())

-- Variabler
DECLARE @myvar AS CHAR(10) = '25'
DECLARE @myvar2 AS INT = 25
SELECT @myvar + @myvar2
-- SQL klarar av att konvertera variabler �t oss �ven om datatyp inte st�mmer

SELECT CAST('test' AS INT)	   -- G�r inte att konvertera text till heltal
SELECT TRY_CAST('test' AS INT) -- F�rs�ker att konvertera, om det ej funkar s� g�r den vidare och s�tter NULL

--- CASE och PIVOT ---
USE UTB_Kurs1;

SELECT 
	INV = 
		CASE 
			WHEN INV BETWEEN 0 AND 1000 THEN 'LITEN'
			WHEN INV BETWEEN 1001 AND 5000 THEN 'MEDEL'
			WHEN INV > 5000 THEN 'STOR'
		END
	, ANTAL_INV = COUNT(*)
FROM KommunInv2001_2005
GROUP BY CASE 
			WHEN INV BETWEEN 0 AND 1000 THEN 'LITEN'
			WHEN INV BETWEEN 1001 AND 5000 THEN 'MEDEL'
			WHEN INV > 5000 THEN 'STOR'
		END
ORDER BY ANTAL_INV DESC

-- PIVOT kan vara mer effektiv �n CASE i vissa komplicerade fall, se exec plan 

SELECT * FROM SYS.objects

-- FQN & Linked Server
-- SQL

-- OPENROWSET (Se dokumentation)
-- OPENQUERY

-- �va p� beroende SubQueries
-- PIVOT

--G�r �vningar 8-10


-- Efterlunch pass

SELECT CONCAT('HEJ', ' ',  'P�', ' ', 'DIG')

SELECT ISNULL(NULL, 'jaha..')

-- F�r att hantera stora datam�ngder kan vi anv�nda partitionering, se mer vid behov

-- Konsistens i databasen
-- PK -> Unik identifierare
-- FK -> Nyckel till unikt v�rde i annan tabell
-- Unique Constraint -> Denna kol m�ste ocks� inneh�lla unika v�rden
-- Check Constraint -> Kontroll av v�rden t.ex. l�ner f�r inte vara negativa
-- Default

USE UTB_ElevO03;
CREATE TABLE TESTY1
(
	ID INT IDENTITY(1,1) PRIMARY KEY
	, ColA VARCHAR(300) DEFAULT('AAA')
	, ColB VARCHAR(300)	DEFAULT('BBB')	
	, ColC VARCHAR(300) DEFAULT('CCC')
)

WHILE (SELECT COUNT(*) FROM TESTY1) < 100000
INSERT INTO TESTY1
VALUES
(
	DEFAULT
	, DEFAULT
	, DEFAULT
)

--SET STATISTICS IO ON
SELECT * FROM TESTY1 --logiska l�sningar 189
--WHERE ID = 4

--- Clustrade och icke-clustrade index ---
-- Clustered = Physically sorted --> Som en telefonkatalog, vi sorterar t.ex. efter efernamn. 
-- Vi kan endast ha ett klustrat index, eftersom vi fysiskt endast kan sortera efter en variabel som t.ex. efternamn i en telefonkatalog

--CREATE CLUSTERED INDEX testy_id_clusteredIdx ON TESTY1(ID)
CREATE NONCLUSTERED INDEX testy_id_NonClusteredIdx ON TESTY1(ColA)
---- SE EXECUTION PLAN ----
SELECT ColA, ColB FROM TESTY1 --logiska l�sningar 
WHERE ID BETWEEN 10 AND 300

SELECT ColA, ColB FROM TESTY1 --logiska l�sningar 
WITH (INDEX(testy_id_NonClusteredIdx))
WHERE ID BETWEEN 10 AND 300

-- CREATE NONCLUSTERED INDEX -> Inneh�llsf�rteckning i boken, ej fysisk sortering utan en f�rteckning p� sorteringar 
-- Att l�gga p� icke-klustrade index, att l�gga p� en inneh�llsf�rteckning i boken, kommer g�ra att boken v�xer med ett antal sidor i.e. 
-- Att uppdatera kolumner som har ett icke-klustrat index, s� m�ste ocks� indexet uppdateras 

DROP TABLE TESTY1



-- Data (Model, Analys, Report)
--