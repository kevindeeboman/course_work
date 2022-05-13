DROP TABLE IF EXISTS TeamKrita

CREATE TABLE DimTeamKrita 
(
	UserId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, Name VARCHAR(30)
	, Age SMALLINT
	, Kvinna BIT
	, DaysEmpolyed INT
	, ValidFrom DATE NOT NULL
	, ValidTo DATE
)

INSERT INTO DimTeamKrita(Name, Age, Kvinna, ValidFrom, ValidTo)
VALUES
(	
	'Johannes'
	,'37'
	, 0
	, '2016-06-01'	
	, NULL
),
(
	'Anders'
	, '45'
	, 0
	, '2015-01-01'
	, NULL
),
(
	'Viktor'
	, '33'
	, 0
	, '2021-09-01'
	, '2022-03-02'
),
(
	'Jenny'
	, '31'
	, 1
	, '2019-02-01'
	, NULL
),
(
	'Kevin'
	, '28'
	, 0
	, '2021-09-01'
	, NULL
),
(
	'Daniel'
	, '29'
	, 0
	, '2022-03-21'
	, NULL
)

UPDATE DimTeamKrita
	SET DaysEmpolyed = DATEDIFF(DAY, ValidFrom, COALESCE(ValidTo, GETDATE()))


SELECT * FROM DimTeamKrita
ORDER BY DaysEmpolyed DESC

--DROP TABLE TeamKrita