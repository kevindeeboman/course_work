/*
* Vi har en SQL-server (Login) - Databaser (user, role)
  Windows släpper in oss i databasen

* Win-PC (Klient) - Management studio -> SQL-server 
  T-SQL (Tansact-SQL) -> Microsofts verison av SQL. Query (fråga) -- fråga skickas till servern --> Respons (Kontrollerar tabellplaner, index och cachar svar)

* RDBMS (Relational Database Management System) --> SQL är en relationsdatabashanterare

* Normalisera data -> Skapar tabeller för att lagra saker effektivt. En rad per sak, en sak per rad. Konsistens, integritet, ej dubbellagring.
  OBS! Detta är det första vi ska ha koll på när det gäller databaser!
  --> Exempel
	1. Liza, Marklund, De Gömda, Bonnier
	2. Bror, Marklund, Vägen, Bonnier
	3. Liza, Jansson, Bron, Bonnier
	4. Patrik, Lennart, NULL
	Vad är det på raden som är kopplat till saken (i detta fall författaren)?
	 -> VAD FINNS PÅ RADEN SOM INTE ÄR DIREKT KOPPLAT TILL ID:et?
		* Boktitel är inget som identifierar Författare, därför får de inte vara på samma rad, dessa bör flyttas till en egen tabell -> Titel
		* Förlag har inte heller med författaren att göra. Det är även en dublett eftersom vi repeterar SAMMA entitet flera gånger -> Det finns bara ETT Bonnier (i.e. förlagstabell), ETT Stockholm (i.e. Stadstabell)
		* Vi hade sannolikt även samlat förlagID i Titeltabellen
-> Vi lagrar bara en identitet/enhet per tabell, i tabellen Författare lagras endast författar, samma gäller 

* Identitetsnyckeln = Primary Key = Försäkrar att varje rad är unik

Standardformat och exekveringsföljd:

5 SELECT
1 FROM + JOIN
2 WHERE
3 GROUP BY
4 HAVING  (Som en WHERE för GROUP BY)
6 ORDER BY
Execute order differs from write order
-> Varför kan vi inte använda ett synonym i WHERE? Eftersom SELECT sker sist!

Prioriteringsregler
1. ~
2. *, /, %
3. +, -
4. NOT
5. AND
6. ALL, ANY
7. =

BETWEEN -> Allt inom ett intervall
IN -> Inom alla angivna värden

När du har ett attribut i kolumnlistan som ej är aggregerat så måste den innehållas i din GROUP BY


Temptabell:
SELECT
INTO #Testy (#=local temp, last connection drops table) -> Endast användbar i din nuvarande session 
			 ##=global temp
Temporära tabeller hanmnar i System Databases -> Temporary Tables 

När vi designar våra tabeller så tänk följande för att få till Normalisering:
Varjetabell ska bara vid givet namn, ska endast användas för att identifiera det som tabellen heter.
T.ex. Tabelle Författare ska endast innehålla data för att identifiera den givna författaren 

Primary Key och Foreign Key måste agnes vid uppskapande av tabeller

-----------------------JOINS ------------------------
LEFT, RIGHT och FULL är alla OUTER JOINS
Poängen med Normalisering är delvis att JOINS inte ska ge NULL

INNER JOIN 
WHERE sker efter din JOIN!
-----------------------------------------------------
Anpassa datatyp utefter faktiska storleken på värdena i kolumnen
				   tinyint
				   smallint
32 miljoner tecken int


fixerad teckensträng    -> char(50) innehåller alltid 50 tecken, kommer fylla ut till 50 om du inte angivit
variernade teckensträng -> varchar(50) kan innehålla färre eller lika med 50 tecken, däremot måste SQL kontrollera antal här

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
	('Örebro', 5)
	, ('Göteborg', 4)
	, ('Stockholm', 3)
	, ('Vänersborg', 2)
	, ('Varberg', 1)
	, ('Falkenberg', 6)
	, ('Kungsbacka', 7)

CREATE TABLE Employees 
(
	EmployeeID INT IDENTITY(1,1) PRIMARY KEY
	, Fname VARCHAR(50) NOT NULL
	, Mname VARCHAR(50) NULL
	, Lname VARCHAR(50) NOT NULL
	, CityID INT NOT NULL FOREIGN KEY REFERENCES City (CityID) -- Refererar tillbaka till CITY. Snubben satta CONSTRAINT framför sin skapelse, se mer varför...
	--ON DELETE CASCADE/SET NULL, finns alternativ på vad som kan hända om saker ändras med CityID. CASCADE hade tagit bort alla anställda givet att CityID i city-tabellen försvunnit. Därmed, om Göteborg försvinner så skulle Patrik försvinna.
	--ON UPDATE XXXX, samma sak här, vi kan ha automatiska reponser på utdates givet att CityID ändras.
)


INSERT INTO Employees(Fname, Lname, CityID)
VALUES
	('Patrik', 'Rhenberg', 1)
	, ('Tim', 'Sandström', 3)
	, ('Kevin', 'Dee', 3)
	, ('Kine', 'Boman', 5)
	-- För att testa att FK funkar -- ('FEL', 'FEL', 100)

-- FROM [UTB_ElevO03].[dbo].[MinTestInforKurs] -- FQN = Fully Qualified Name

/* När relationen City till Employees finns, kan vi inte längre lägga till rader i employees till städer som inte finns i City */


SELECT 
	EmployeeID
	, Fname
	, Lname
	, City
FROM Employees AS E
CROSS JOIN City 


--DROP TABLE Employees, City


-------- Återigen JOINS ---------

/* 
LEFT JOIN kommer alltid referera till tabellen som är i FROM
RIGHT JOIN kommer alltid referea till tabellen som är i JOIN:en

LEFT JOIN .WHERE IS NULL -> Tar fram de som är exklusiva för en tabell, t.ex. författare som inte har skrivit någon bok.

Användningsområde för FULL OUTER JOIN?
Frågan kan svara på både:
Vilka kunder har inte handlat?
Vilka produkter har inte köpts av en kund?


CROSS JOIN (NYHET) Samtliga värden i enda tabellen joinas mot varje rad i den andra tabellen
Givet två tabeller -> T1 3 rader och T2 4 rader kommer 12 kombinationer skapas
En "Kartesisk produk" se mer

Inget ON i CROSS JOIN eftersom alla joinas på allt

Användningsområden?
För att skapa en mega-tabell kan vi CROSS JOIN:a två stora tabeller t.ex. 1 000 * 100 000 = 1 000 000 000

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
ORDER BY Ranking -- Det funkar att använda denna synonym eftersom FROM är före i exikveringsordern, ORDER BY sker sist!

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

-- EXCEPT    --> Ge mig alla i den första som inte finns i den andra (LEFT JOIN WHERE, alla unika för första)
-- Vi kan lätt vända på EXCEPT för få unika för andra tabellen
-- INTERSECT --> Ge mig alla som finns i båda (INNER JOIN MATCH, alla som finns i båda)

-- VIEWS ------------------------------------------------------------------------------------------------------------------------------
-- Databaser har objekt. En vy är en definition, vyn i sig innehåller ingen information utan definitionen av informationen som ska visas
-- Se mer om Matrialiserade vyer --
USE UTB_ElevO03;
CREATE VIEW NuvarandeKrita_View -- CREATE måste köra försig
WITH ENCRYPTION -- Låser objektet 
AS
(
SELECT 
	* 
FROM dbo.DimTeamKrita
WHERE ValidTo IS NULL
)

SELECT * FROM NuvarandeKrita_View

SELECT * FROM sys.objects
WHERE type_desc = 'view' -- Här ser vi objekten i DB som är Vy

UPDATE NuvarandeKrita_View -- Vi kan modifiera tabellerna via en Vy! Det är mycket "billigare" att editera mot grundtabellerna, se exekveringsplan
SET ValidFrom = '2020-01-01', ValidTo = '2021-01-01'
WHERE UserId = 5

SELECT * FROM DimTeamKrita -- Mitt Start och Slutdatum har modifierats
--DROP VIEW NuvarandeKrita_View
------------------------------------------------------------------------------------------------------------------------------------------

-- STORED PROCEDURE --
-- Stödjer variabler som input, kan ta emot argument (UTVECKLARKURSEN)
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
-- Samma princip fast en procedur kan ta emot en variabel -- i.e. det är en funktion som DEF i Python --

-- CREATE - Skapa
-- ALTER  - Ändra
-- UPDATE - Uppdatera

------------------- Dag 2 ----------------------
--- Funktioner ---
/*
Strängfunktioner
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
-- SQL klarar av att konvertera variabler åt oss även om datatyp inte stämmer

SELECT CAST('test' AS INT)	   -- Går inte att konvertera text till heltal
SELECT TRY_CAST('test' AS INT) -- Försöker att konvertera, om det ej funkar så går den vidare och sätter NULL

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

-- PIVOT kan vara mer effektiv än CASE i vissa komplicerade fall, se exec plan 

SELECT * FROM SYS.objects

-- FQN & Linked Server
-- SQL

-- OPENROWSET (Se dokumentation)
-- OPENQUERY

-- Öva på beroende SubQueries
-- PIVOT

--Gör övningar 8-10


-- Efterlunch pass

SELECT CONCAT('HEJ', ' ',  'PÅ', ' ', 'DIG')

SELECT ISNULL(NULL, 'jaha..')

-- För att hantera stora datamängder kan vi använda partitionering, se mer vid behov

-- Konsistens i databasen
-- PK -> Unik identifierare
-- FK -> Nyckel till unikt värde i annan tabell
-- Unique Constraint -> Denna kol måste också innehålla unika värden
-- Check Constraint -> Kontroll av värden t.ex. löner får inte vara negativa
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
SELECT * FROM TESTY1 --logiska läsningar 189
--WHERE ID = 4

--- Clustrade och icke-clustrade index ---
-- Clustered = Physically sorted --> Som en telefonkatalog, vi sorterar t.ex. efter efernamn. 
-- Vi kan endast ha ett klustrat index, eftersom vi fysiskt endast kan sortera efter en variabel som t.ex. efternamn i en telefonkatalog

--CREATE CLUSTERED INDEX testy_id_clusteredIdx ON TESTY1(ID)
CREATE NONCLUSTERED INDEX testy_id_NonClusteredIdx ON TESTY1(ColA)
---- SE EXECUTION PLAN ----
SELECT ColA, ColB FROM TESTY1 --logiska läsningar 
WHERE ID BETWEEN 10 AND 300

SELECT ColA, ColB FROM TESTY1 --logiska läsningar 
WITH (INDEX(testy_id_NonClusteredIdx))
WHERE ID BETWEEN 10 AND 300

-- CREATE NONCLUSTERED INDEX -> Innehållsförteckning i boken, ej fysisk sortering utan en förteckning på sorteringar 
-- Att lägga på icke-klustrade index, att lägga på en innehållsförteckning i boken, kommer göra att boken växer med ett antal sidor i.e. 
-- Att uppdatera kolumner som har ett icke-klustrat index, så måste också indexet uppdateras 

DROP TABLE TESTY1



-- Data (Model, Analys, Report)
--