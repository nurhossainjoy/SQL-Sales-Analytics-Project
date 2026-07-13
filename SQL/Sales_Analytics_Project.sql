/*
===============================================================================
Project      : Sales Analytics Using PostgreSQL
Author       : MD Nur Hossain Joy
Database     : PostgreSQL
Tools        : PostgreSQL 18, pgAdmin 4

Description:
This project demonstrates SQL-based sales analytics using PostgreSQL.
The project includes:

• Data Exploration
• Master Sales Table Creation
• Sales Performance Analysis
• Regional Analysis
• Product Analysis
• Top Salesperson Ranking
• Product Profitability Analysis
• Window Functions
• Common Table Expressions (CTEs)

===============================================================================
*/

/*=============================================================================
SECTION 1 : DATA EXPLORATION
=============================================================================*/

-- View Geo table

SELECT *
FROM "Practice"."Geo";

-- View People table

SELECT *
FROM "Practice"."People";

-- View Products table

SELECT *
FROM "Practice"."Products";

-- View Sales table

SELECT *
FROM "Practice"."Sales";

/*=============================================================================
SECTION 2 : MASTER SALES TABLE
Purpose:
Combine all four tables into a single analytical dataset.
=============================================================================*/
SELECT 
s.spid,
s.geoid,
s.pid,
s.saledate,
s.amount,
s.customers,
s.boxes,
p.product,
p.category,
p.size,
p.cost_per_box,
pr. salesperson,
pr. team,
pr. location,
g. geo,
g. region
FROM "Practice"."Sales" AS s
	LEFT JOIN "Practice"."Geo" AS g 
		ON g."geoid"= s."geoid"  
	LEFT JOIN "Practice"."People" AS p
		ON s."pid"= s."pid"
	LEFT JOIN "Practice"."Products" AS pr
		ON pr. "spid"= s. "spid"

--Putting it into the Schema
CREATE TABLE "Practice"."Master_Sales_Table" AS
SELECT
s.spid,
s.geoid,
s.pid,
s.saledate,
s.amount,
s.customers,
s.boxes,
p.product,
p.category,
p.size,
p.cost_per_box,
pr. salesperson,
pr. team,
pr. location,
g. geo,
g. region
FROM "Practice"."Sales" AS s
	LEFT JOIN "Practice"."Geo" AS g 
		ON g."geoid"= s."geoid"  
	LEFT JOIN "Practice"."People" AS p
		ON s."pid"= s."pid"
	LEFT JOIN "Practice"."Products" AS pr
		ON pr. "spid"= s. "spid"

/*=============================================================================
SECTION 3 : SALES PERFORMANCE ANALYSIS
Purpose:
Analyze overall sales performance by year and month.
=============================================================================*/

SELECT
	EXTRACT (year FROM "saledate") AS Year,
	EXTRACT (month FROM "saledate") AS Months,
	SUM ("amount") AS Total_Sales,
	round (AVG ("amount")) AS Average_Sales,
	SUM ("customers") AS Customers,
	round (AVG("boxes")) AS Average_Boxes_Sold
FROM "Practice"."Sales"
	GROUP BY 1,2
	ORDER BY 1 DESC,2 ASC;


/*=============================================================================
SECTION 4 : REGIONAL SALES ANALYSIS
Purpose:
Compare sales performance across different countries and regions.
=============================================================================*/

SELECT
	EXTRACT (year from s."saledate") AS Year,
	TO_CHAR(s."saledate",'Mon') AS month,
	g."geo",
	SUM(s."amount") AS Total_Sales,
	round(AVG(s."amount")) AS Average_Sales
FROM "Practice"."Sales" AS s
LEFT JOIN  "Practice"."Geo" AS g 
ON s."geoid"=g."geoid"
	GROUP BY 1,2,EXTRACT(MONTH FROM s."saledate"),3
	ORDER BY 1, EXTRACT(MONTH FROM s."saledate") ASC;

--Region wise total sales
--Creating CTE
WITH cte1 AS
(
SELECT
	TO_CHAR(s."saledate",'Mon') AS month,
	g."geo",
	g."region",
	SUM(s. "amount") AS total_Amount,
	round(avg (s."amount")) AS Agerage_of_Sales
FROM "Practice"."Sales" AS s
	LEFT JOIN "Practice"."Geo" AS g 
	ON g."geoid"=s."geoid"
WHERE extract (year FROM s."saledate")=2022
	GROUP BY 1,extract (month FROM s."saledate"),2,3
	ORDER BY 
	extract (month FROM s."saledate"),3 DESC
)
SELECT
	"month",	
	"geo",
	SUM( DISTINCT CASE 
	WHEN "region"= 'APAC'THEN "total_amount" ELSE NULL END) AS APAC,
	SUM( DISTINCT CASE 
	WHEN "region"= 'Europe'THEN "total_amount" ELSE NULL END) AS Europe,
	SUM( DISTINCT CASE 
	WHEN "region"= 'Americas'THEN "total_amount" ELSE NULL END) AS Americas
FROM cte1
GROUP BY 1,2;

/*=============================================================================
SECTION 5 : TOP SALESPERSON ANALYSIS
Purpose:
Identify the top-performing salespersons in each location.
=============================================================================*/
WITH cte2 AS
(
	SELECT
	DENSE_RANK () over(PARTITION BY p."location" ORDER BY SUM(s."amount") DESC) AS Rank,
		p."salesperson",
		p."location",
		SUM(s."amount") sum_of_Sales
	FROM "Practice"."Sales" AS s
	LEFT JOIN "Practice"."Products" p 
	ON p."spid"=s."spid"
		GROUP BY 2,3
		ORDER BY 4 DESC
)
SELECT * FROM cte2
WHERE "rank"<11;

/*=============================================================================
SECTION 6 : PRODUCT PROFITABILITY ANALYSIS
Purpose:
Calculate revenue, cost, profit, and profit margin for each product.
=============================================================================*/ 
WITH cte3 AS (
SELECT
	DENSE_RANK() OVER (ORDER BY s."amount"- round(SUM (p."cost_per_box"*s."boxes")) DESC) AS RANK,
	p."product",
	p."category",
	s."amount" AS Sales_revenue,
	round(SUM (p."cost_per_box"*s."boxes")) AS total_cost,
	s."amount"-round(SUM (p."cost_per_box"*s."boxes")) AS Product_wise_Profit
FROM "Practice"."People" AS p
LEFT JOIN "Practice"."Sales" AS s
	ON s."pid"=p."pid"
	GROUP BY 2,3,4)
SELECT
RANK,
product,
category,
sales_revenue,
total_cost
Product_wise_profit,
round (((Product_wise_profit / NULLIF(sales_revenue, 0) * 100)::numeric),2) AS Profit_Margin
FROM cte3
/*=============================================================================
END OF PROJECT
=============================================================================*/



	