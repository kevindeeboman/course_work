
/* SE MER! */

DECLARE @EMPLOYEES TABLE (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL
)

INSERT INTO @EMPLOYEES (Name)
VALUES
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

select Name from @EMPLOYEES
except
select Name from @EXAMPLE


select Name from @EXAMPLE
except
select Name from @EMPLOYEES

