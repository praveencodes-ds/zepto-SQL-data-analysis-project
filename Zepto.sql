-- ============================================================================ 
-- ZEPTO_SQL_PROJECT (PostgreSQL) — End-to-End Project
-- Compatible with PostgreSQL4 (InnoDB, utf8mb4). Run section-by-section or all.
-- ============================================================================

/* ---------------------------------------------------------------------------
   0) SAFETY SETUP
--------------------------------------------------------------------------- */
SET NAMES utf8mb4;

DROP TABLE IF EXISTS Zepto;

/* ---------------------------------------------------------------------------
   1) ZEPTO TABLES
------------------------------------------------------------------------------ 
*/ 

CREATE TABLE zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

SELECT * FROM zepto;

-- ======================== 
-- 1 - DATA EXPLORATION 
-- ========================

-- Count of Rows. 
SELECT COUNT(*) FROM Zepto;

-- Sample Data 
SELECT * FROM Zepto 
LIMIT 10;

-- Null Values 
SELECT * FROM Zepto 
WHERE Name IS NULL 
OR 
Category IS NULL 
OR 
mrp IS NULL 
OR 
discountPercent IS NULL 
OR 
availableQuantity IS NULL 
OR 
discountedSellingPrice IS NULL 
OR 
weightInGms IS NULL 
OR 
outOfStock IS NULL 
OR 
Quantity IS NULL ; 

-- Different Product Category 
SELECT DISTINCT Category 
FROM Zepto 
ORDER BY Category; 

-- Products InStock vs OutOfStock. 
SELECT outOfStock, COUNT(sku_id)  
FROM Zepto 
GROUP BY outOfStock;

-- Product Name Present Multiple Times. 
SELECT Name, COUNT(sku_id) AS Number_of_SKUs 
FROM Zepto 
GROUP BY Name 
HAVING COUNT(sku_id) > 1 
ORDER BY COUNT(sku_id); 

-- ======================== 
-- 2 - DATA CLEANING 
-- ========================

SELECT * FROM Zepto;

-- Products with Price = 0 
SELECT * 
FROM Zepto 
WHERE mrp = 0 OR discountedSellingPrice = 0; 
    
DELETE FROM Zepto 
WHERE ctid IN (
	SELECT ctid 
	FROM Zepto
	WHERE mrp = 0 OR 
discountedSellingPrice = 0 
	LIMIT 5
);


-- Convert Price to Rupees 
UPDATE Zepto 
SET mrp = mrp/100.00, 
discountedSellingPrice = discountedSellingPrice/100.00 ;

SELECT mrp, discountedSellingPrice FROM zepto;

SELECT * FROM Zepto; 

-- ======================== 
-- 3 - DATA ANALYSIS 
-- ========================

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT Name, mrp, discountPercent 
FROM Zepto 
ORDER BY discountPercent DESC 
LIMIT 10; 

-- Q2. What are the Products with High MRP but Out of Stock
SELECT DISTINCT Name, mrp, outOfStock 
FROM Zepto 
WHERE outOfStock = 'TRUE' AND mrp > 300 
ORDER BY mrp DESC; 

-- Q3. Calculate Estimated Revenue for each category
SELECT category, 
	SUM(discountedSellingPrice * availableQuantity) AS Total_Revenue 
 FROM zepto 
 GROUP BY category 
 ORDER BY Total_Revenue DESC; 

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent 
FROM zepto 
WHERE mrp > 500 AND discountPercent < 10 
ORDER BY mrp DESC, discountPercent DESC ; 

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT DISTINCT category, 
	ROUND(AVG(discountPercent), 2) AS Avg_Discount 
FROM zepto 
GROUP BY category 
ORDER BY Avg_Discount DESC 
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

-- Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

