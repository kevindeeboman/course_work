/*	JOINS EXAMPLES */

CREATE TABLE #Logins
(
	log_id INT IDENTITY(1,1)
	, Name VARCHAR(50) NOT NULL
)

INSERT INTO #Logins (Name)
VALUES
	('Carl')
	, ('Tim')
	, ('Bob')
	, ('Andrew')

CREATE TABLE #Registrations
(
	reg_id INT IDENTITY(1, 1)
	, Name VARCHAR(50) NOT NULL
)

INSERT INTO #Registrations
VALUES
	('Andrew')
	, ('Bob')
	, ('Greta')
	, ('Peter')

SELECT * FROM #Registrations
SELECT * FROM #Logins

SELECT 
	*
	, JOIN_TYPE = 'INNER JOIN'
FROM #Registrations
JOIN #Logins ON #Logins.Name = #Registrations.Name

SELECT 
	*
	, JOIN_TYPE = 'FULL OUTER JOIN'
FROM #Registrations
FULL OUTER JOIN #Logins ON #Logins.Name = #Registrations.Name

SELECT 
	*
	, JOIN_TYPE = 'FULL OUTER JOIN WHERE'
FROM #Registrations
FULL OUTER JOIN #Logins ON #Logins.Name = #Registrations.Name
WHERE #Registrations.Name IS NULL OR #Logins.Name IS NULL

SELECT 
	*
	, JOIN_TYPE = 'LEFT JOIN'
FROM #Registrations
LEFT JOIN #Logins ON #Logins.Name = #Registrations.Name

SELECT 
	*
	, JOIN_TYPE = 'LEFT JOIN WHERE- IS NULL'
FROM #Registrations
LEFT JOIN #Logins ON #Logins.Name = #Registrations.Name
WHERE #Logins.Name IS NULL

SELECT 
	*
	, JOIN_TYPE = 'LEFT JOIN WHERE- IS NOT OR IS NULL'
FROM #Registrations
LEFT JOIN #Logins ON #Logins.Name = #Registrations.Name
WHERE #Logins.Name <> 'Bob' OR #Logins.Name IS NULL

SELECT 
	*
	, JOIN_TYPE = 'LEFT JOIN WHERE- IS NOT'
FROM #Registrations
LEFT JOIN #Logins ON #Logins.Name = #Registrations.Name
WHERE #Logins.Name <> 'Bob'

--- OBS! If exclusion is based on specific value, other NULL values will be excluded, as seen in the last output. 
--- We have to add #Logins.Name <> 'Bob' OR #Logins.Name IS NULL if we want to show NULL values in the right tabe

DROP TABLE #Logins, #Registrations