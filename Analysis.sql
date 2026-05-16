-- KPI --
SELECT 
    s.sales_year AS year,
    COUNT(*) AS total_customers,
    SUM(s.OrderQuantity) AS total_orders,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_revenue,
    ROUND(SUM(s.OrderQuantity * p.ProductCost),0) AS total_cost,
    ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),0) AS total_profit
FROM (
		SELECT '2015' AS sales_year, OrderQuantity, ProductKey FROM sales_2015
		UNION ALL
		SELECT '2016', OrderQuantity, ProductKey FROM sales_2016
		UNION ALL
		SELECT '2017', OrderQuantity, ProductKey FROM sales_2017
) s
JOIN products p
	USING (ProductKey)
GROUP BY sales_year;
    
-- CUSTOMER ANALYSIS --
-- Gender Analysis --
SELECT
	Gender,
	COUNT(*) AS total_customers,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, STR_TO_DATE(BirthDate, '%m/%d/%Y'), NOW())), 1) AS average_age,
    ROUND(AVG(AnnualIncome),0) AS average_income
FROM customers
GROUP BY Gender;

-- Age Demographics --
SELECT
	CASE
		WHEN age < 25 THEN '<25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
		ELSE '65+'
	END AS age_group,
    COUNT(*) AS total_customers,
    ROUND(AVG(AnnualIncome),0) AS avg_income
FROM
(SELECT
	AnnualIncome,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(BirthDate, '%m/%d/%Y'), NOW()) AS age
FROM customers) c
GROUP BY age_group
ORDER BY age_group;

-- Marital Status Analysis --
SELECT
	MaritalStatus,
	COUNT(*) AS total_customers,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, STR_TO_DATE(BirthDate, '%m/%d/%Y'), NOW())), 1) AS average_age,
    ROUND(AVG(AnnualIncome),0) AS average_income
FROM customers
GROUP BY MaritalStatus;

-- Education Level Analysis --
SELECT
	EducationLevel,
	COUNT(*) AS total_customers,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, STR_TO_DATE(BirthDate, '%m/%d/%Y'), NOW())), 1) AS average_age,
    ROUND(AVG(AnnualIncome),0) AS average_income
FROM customers
GROUP BY EducationLevel;

-- Occupation Analysis --
SELECT
	Occupation,
	COUNT(*) AS total_customers,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, STR_TO_DATE(BirthDate, '%m/%d/%Y'), NOW())), 1) AS average_age,
    ROUND(AVG(AnnualIncome),0) AS average_income
FROM customers
GROUP BY Occupation;

-- Top 10 Customers --
SELECT
	CONCAT(c.Prefix, '', c.FirstName, ' ', c.LastName) AS customer_name,
    COUNT(DISTINCT s.OrderNumber) AS total_order,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_spent
FROM (
    SELECT CustomerKey, ProductKey, OrderQuantity, OrderNumber FROM sales_2015
    UNION ALL
    SELECT CustomerKey, ProductKey, OrderQuantity, OrderNumber FROM sales_2016
    UNION ALL
    SELECT CustomerKey, ProductKey, OrderQuantity, OrderNumber FROM sales_2017
) s
JOIN customers c 
	USING (CustomerKey)
JOIN products p
	USING (ProductKey)
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- MONTHLY SALES --
SELECT
	MONTH(STR_TO_DATE(s.OrderDate, '%m/%d/%Y')) AS month_num,
    SUM(s.OrderQuantity) AS total_products_sold,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_sales
FROM (
    SELECT OrderDate, ProductKey, OrderQuantity FROM sales_2015
    UNION ALL
    SELECT OrderDate, ProductKey, OrderQuantity FROM sales_2016
    UNION ALL
    SELECT OrderDate, ProductKey, OrderQuantity FROM sales_2017
) s
JOIN products p
USING (ProductKey)
GROUP BY month_num
ORDER BY month_num;

-- COUNTRY SALES --
SELECT 
    t.Country AS country,
    COUNT(*) AS total_customers,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_revenue
FROM (
		SELECT CustomerKey, TerritoryKey, OrderQuantity, ProductKey FROM sales_2015
		UNION ALL
		SELECT CustomerKey, TerritoryKey, OrderQuantity, ProductKey FROM sales_2016
		UNION ALL
		SELECT CustomerKey, TerritoryKey, OrderQuantity, ProductKey FROM sales_2017
) s
JOIN products p
	USING (ProductKey)
JOIN customers c
	USING (CustomerKey)
JOIN territories t
	ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY country
ORDER BY total_revenue DESC;

-- PRODUCT SALES --
SELECT 
    p.ProductName AS name,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_revenue,
    ROUND(SUM(s.OrderQuantity * p.ProductCost),0) AS total_cost,
    ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),0) AS total_profit
FROM (
		SELECT ProductKey, OrderQuantity FROM sales_2015
		UNION ALL
		SELECT ProductKey, OrderQuantity FROM sales_2016
		UNION ALL
		SELECT ProductKey, OrderQuantity FROM sales_2017
) s
JOIN products p
	USING (ProductKey)
GROUP BY p.ProductName
ORDER BY total_profit DESC
LIMIT 10;

-- PRODUCT SUB CATEGORIES SALES --
SELECT 
    ps.SubCategoryName AS sub_categories,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_revenue,
    ROUND(SUM(s.OrderQuantity * p.ProductCost),0) AS total_cost,
    ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),0) AS total_profit
FROM (
		SELECT ProductKey, OrderQuantity FROM sales_2015
		UNION ALL
		SELECT ProductKey, OrderQuantity FROM sales_2016
		UNION ALL
		SELECT ProductKey, OrderQuantity FROM sales_2017
) s
JOIN products p
	USING (ProductKey)
JOIN product_sub ps
	USING (ProductSubCategoryKey)
GROUP BY sub_categories
ORDER BY total_profit DESC
LIMIT 10;

-- PRODUCT CATEGORIES SALES --
SELECT
	pc.CategoryName AS categories,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice),0) AS total_revenue,
    ROUND(SUM(s.OrderQuantity * p.ProductCost),0) AS total_cost,
    ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),0) AS total_profit
FROM (
		SELECT ProductKey, OrderQuantity FROM sales_2015
		UNION ALL
		SELECT ProductKey, OrderQuantity FROM sales_2016
		UNION ALL
		SELECT ProductKey, OrderQuantity FROM sales_2017
) s
JOIN products p USING (ProductKey)
JOIN product_sub ps USING (ProductSubcategoryKey)
JOIN product_categories pc USING (ProductCategoryKey)
GROUP BY pc.CategoryName
ORDER BY total_profit DESC;

-- TOTAL RETURNS PRODUCT --
-- Total Return by Year, Month --
SELECT
	YEAR(STR_TO_DATE(ReturnDate, '%m/%d/%Y')) AS year,
    MONTH(STR_TO_DATE(ReturnDate, '%m/%d/%Y')) AS month,
    SUM(ReturnQuantity) AS return_qty
FROM returns
GROUP BY year, month;

-- Total Return by Country --
SELECT
	t.Country AS country,
    SUM(r.ReturnQuantity) AS return_qty
FROM returns r
JOIN territories t
	ON r.TerritoryKey = t.SalesTerritoryKey
GROUP BY country
ORDER BY return_qty DESC;

-- Total Return by Product --
SELECT
	p.ProductName AS name,
    SUM(r.ReturnQuantity) AS return_qty
FROM returns r
JOIN products p
	USING (ProductKey)
GROUP BY name
ORDER BY return_qty DESC;