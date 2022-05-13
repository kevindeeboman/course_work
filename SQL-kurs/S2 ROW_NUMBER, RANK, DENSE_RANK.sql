/* So far we have used window functions to aggregate without losing row level detail
But this is only one of the applications of window functions. Using ROW_NUMBER we can also RANK records within our data
Theses rankings can be applied across all rows, or to PARTITION:ed BY groups within the rows
ROW_NUMBER is really useful for finding the MAX/MIN ranked value by group, for example a sales persons best and worst sales 
*/

DECLARE @EXAMPLE TABLE(	
	SalesId INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50),
	Sales FLOAT)

INSERT INTO @EXAMPLE (Name, Sales)
VALUES
	('ERIK', 100),
	('PETRA', 200),
	('ERIK', 300),
	('ERIK', 300),
	('PELLE', 100),
	('PELLE', 400),
	('PETRA', 100),
	('ERIK', 50),
	('PELLE', 600),
	('PETRA', 300),
	('ERIK', 500),
	('PETRA', 100),
	('PETRA', 200),
	('PELLE', 150)

SELECT 
	Name
	, Sales
	, SubTotalsBySalesPerson = SUM(Sales) OVER (PARTITION BY Name)
	, TotalSales = SUM(Sales) OVER ()
	, RankingByTotalSales = ROW_NUMBER() OVER (ORDER BY SALES DESC)
	, RankingWithRank = RANK() OVER (ORDER BY SALES DESC)
	, RankingWithDenseRank = DENSE_RANK() OVER (ORDER BY SALES DESC)
	, RankingByPersonSales = ROW_NUMBER() OVER (PARTITION BY Name ORDER BY SALES DESC)
	, BestSales = CASE WHEN (ROW_NUMBER() OVER (PARTITION BY Name ORDER BY SALES DESC)) = 1 THEN 'YES' ELSE 'NO' END
FROM @EXAMPLE
ORDER BY RankingByTotalSales ASC
/* When we dont specify PARTITION BY in our ROW_NUMBER clause, rows will be ranked based on all rows in our query
By default, ORDER BY orders in ascending order i.e. lowest sales values will be ranked highest, using DESC we can find the highest sales values.
When we add in the PARTITION BY, we get the rankings withing each group

ROW_NUMBER: Sequential order regardless of ties
RANK: Visibility into ties but skips gaps in sequence of ranks when there are ties
DESNSE_RANK: Maintains sequence but still shows ties
*/

SELECT 
	Name
	, Sales
	, SalesSubTotals = SUM(Sales) OVER (PARTITION BY NAME)
	, Ranks = DENSE_RANK() OVER (ORDER BY SALES DESC)
	, RankSubTotals = RANK() OVER (PARTITION BY NAME ORDER BY SALES DESC)
	, RankTop3SalesBySalesPerson = CASE WHEN RANK() OVER (PARTITION BY NAME ORDER BY SALES DESC) <= 3 THEN 'YES' ELSE 'NO' END
	, DenseRankSubTotals = DENSE_RANK() OVER (PARTITION BY NAME ORDER BY SALES DESC)
	, DenseRankTop3SalesBySalesPerson = CASE WHEN DENSE_RANK() OVER (PARTITION BY NAME ORDER BY SALES DESC) <= 3 THEN 'YES' ELSE 'NO' END
FROM @EXAMPLE
/* Using CASE and DENSE_RANK we can show the top 2 sales by sales person where ties are shown */
