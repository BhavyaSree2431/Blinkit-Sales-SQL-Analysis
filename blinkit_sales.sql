-- =====================================================
-- Blinkit Sales Analysis using MySQL
-- Author: A Bhavya Sree
-- Database: retail_sales_db
-- =====================================================


-- 1. DATABASE SETUP
create database retail_sales_db;
use retail_sales_db;
rename table `blinkit grocery data` to blinkit_sales;
desc blinkit_sales;

-- 2. DATA EXPLORATION

-- Total records
select count(*) as total_rows from blinkit_sales;
-- Preview dataset
select * from blinkit_sales limit 10;
-- Unique Item Types
select distinct `Item type` from blinkit_sales;

-- 3. DATA CLEANING

-- Missing Values
SELECT
SUM(`Item Weight` IS NULL) AS missing_weight,
SUM(Rating IS NULL) AS missing_rating
FROM blinkit_sales;
-- Duplicate Item Identifier
select `Item Identifier`,count(*)
from blinkit_sales
group by `Item Identifier`
having count(*)>1;
-- Duplicate record/row
SELECT *,
       COUNT(*) AS duplicate_count
FROM blinkit_sales
GROUP BY
    `Item Identifier`,
    `Item Fat Content`,
    `Item Type`,
    `Outlet Establishment Year`,
    `Outlet Identifier`,
    `Outlet Location Type`,
    `Outlet Size`,
    `Outlet Type`,
    `Item Visibility`,
    `Item Weight`,
    Sales,
    Rating
HAVING COUNT(*) > 1;
-- Standardize Fat Content
UPDATE blinkit_sales
SET `Item Fat Content` = 'Low Fat'
WHERE `Item Fat Content` IN ('LF','low fat');
-- Trim Spaces
update blinkit_sales
SET `Item Type` = Trim(`Item Type`);
-- Invalid Ratings
select * from blinkit_sales
where Rating>5 or Rating<1;

-- 4. SALES ANALYSIS

select sum(sales) as total_sales from blinkit_sales;
select avg(sales) as avergae_sales from blinkit_sales;
SELECT
    MIN(Sales) AS Minimum_Sales,
    MAX(Sales) AS Maximum_Sales
FROM blinkit_sales;

-- 5. ITEM ANALYSIS

select `Item Type`, sum(Sales) as total_sales from blinkit_sales
group by `Item Type`;
select `Item Type`, sum(Sales) as total_sales from blinkit_sales
group by `Item Type`
order by sum(sales) desc;
select `Item Type`, sum(Sales) as total_sales from blinkit_sales
group by `Item Type`
order by sum(sales) desc
limit 5;
select `Item Type`, sum(Sales) as total_sales from blinkit_sales
group by `Item Type`
order by total_sales asc
limit 5;
select `Item Type`,sum(Sales) as total_sales
from blinkit_sales
group by `Item Type`
having sum(Sales) >(select avg(total_sales) from (select `Item Type`,sum(Sales) as total_sales from blinkit_sales group by `Item Type`)as temp);
with itemsales as (
	select `Item Type`,sum(Sales) as total_sales
	from blinkit_sales
	group by `Item Type`
)
select * from itemsales
order by total_sales desc
limit 3;
WITH ItemSales AS (
    SELECT
        `Item Type`,
        SUM(Sales) AS Total_Sales
    FROM blinkit_sales
    GROUP BY `Item Type`
),
RankedSales AS (
    SELECT
        `Item Type`,
        Total_Sales,
        DENSE_RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
    FROM ItemSales
)

SELECT *
FROM RankedSales
WHERE Sales_Rank = 2;
select `Item Identifier`,sum(Sales) as total_sales
from blinkit_sales group by `Item Identifier`
order by total_sales desc limit 5;
select `Item Type`,count(*) as total_products,avg(Rating) as avg_rating
from blinkit_sales
group by `Item Type`
having total_products>100
order by avg_rating desc limit 5;


-- 6. OUTLET ANALYSIS
select `Outlet Type`,sum(Sales) as total_sales
from blinkit_sales
group by `Outlet Type`
order by total_sales desc;
select `Outlet Location Type`,sum(Sales) as total_sales
from blinkit_sales
group by `Outlet Location Type`
order by total_sales desc;
select `Outlet Type`,avg(Sales) as avg_sales
from blinkit_sales
group by `Outlet Type`
order by avg_sales desc
limit 1;
select `Outlet Type`,sum(Sales) as total_sales,
round(sum(Sales)/(select sum(Sales) from blinkit_sales)*100,2) as sales_percentage
from blinkit_sales
group by `Outlet Type`
order by sales_percentage desc;
select `Outlet Size`,sum(Sales) as total_sales
from blinkit_sales
group by `Outlet Size` order by total_sales desc
limit 1;
select `Outlet Type`,sum(Sales) as total_sales,avg(Rating) as avg_rating from blinkit_sales
group by `Outlet Type`;
select `Outlet Type`,sum(Sales) as total_sales,count(*) as total_products,avg(Rating) as avg_rating
from blinkit_sales
group by `Outlet Type`;
select `Outlet Establishment Year`,sum(Sales) as total_Sales
from blinkit_sales
group by `Outlet Establishment Year`
order by total_sales desc limit 5;
select `Item Fat Content`,sum(Sales) as total_sales,round((sum(Sales)/(select sum(Sales) from blinkit_sales)*100),2) as percentage
from blinkit_sales
group by `Item Fat Content`;
select `Outlet Location Type`,avg(Sales) as avg_sales
from blinkit_sales
group by `Outlet Location Type`
having avg_sales>140;
select `Outlet Type`,avg(Sales) as avg_sales
from blinkit_sales
group by `Outlet Type`
order by avg_sales desc limit 1;

-- 7.Advanced SQL

WITH ProductSales AS (
    SELECT
        `Outlet Type`,
        `Item Identifier`,
        SUM(Sales) AS Total_Sales
    FROM blinkit_sales
    GROUP BY
        `Outlet Type`,
        `Item Identifier`
),
RankedProducts AS (
    SELECT
        `Outlet Type`,
        `Item Identifier`,
        Total_Sales,
        ROW_NUMBER() OVER (
            PARTITION BY `Outlet Type`
            ORDER BY Total_Sales DESC
        ) AS rn
    FROM ProductSales
)

SELECT
    `Outlet Type`,
    `Item Identifier`,
    Total_Sales
FROM RankedProducts
WHERE rn = 1;
select `Outlet Size`,sum(Sales) as total_sales,avg(Sales) as avg_sales,count(*) as total_products
from blinkit_sales
group by `Outlet Size`; 
select `Item Type`,sum(Sales) as total_sales,avg(Sales) as avg_sales
from blinkit_sales
group by `Item Type`
having total_sales>100000;
SELECT
    `Item Identifier`,
    Sales,
    CASE
        WHEN Sales >= 200 THEN 'High'
        WHEN Sales >= 100 THEN 'Medium'
        ELSE 'Low'
    END AS Sales_Category
FROM blinkit_sales;
SELECT
    `Item Identifier`,
    `Item Type`,
    Sales
FROM blinkit_sales b1
WHERE Sales >
(
    SELECT AVG(Sales)
    FROM blinkit_sales b2
    WHERE b1.`Item Type` = b2.`Item Type`
);
WITH ProductSales AS
(
    SELECT
        `Outlet Type`,
        `Item Identifier`,
        SUM(Sales) AS Total_Sales
    FROM blinkit_sales
    GROUP BY `Outlet Type`,`Item Identifier`
)
SELECT *,
       DENSE_RANK() OVER(PARTITION BY `Outlet Type`
       ORDER BY Total_Sales DESC) AS Sales_Rank
FROM ProductSales;
WITH Ranked AS
(
SELECT
    `Item Type`,
    `Item Identifier`,
    Rating,
    ROW_NUMBER() OVER(
    PARTITION BY `Item Type`
    ORDER BY Rating DESC) rn
FROM blinkit_sales
)
SELECT *
FROM Ranked
WHERE rn=1;
WITH Ranked AS
(
SELECT
    `Outlet Type`,
    `Item Identifier`,
    SUM(Sales) AS Total_Sales,
    ROW_NUMBER() OVER(
    PARTITION BY `Outlet Type`
    ORDER BY SUM(Sales)) rn
FROM blinkit_sales
GROUP BY `Outlet Type`,`Item Identifier`
)
SELECT *
FROM Ranked
WHERE rn=1;
