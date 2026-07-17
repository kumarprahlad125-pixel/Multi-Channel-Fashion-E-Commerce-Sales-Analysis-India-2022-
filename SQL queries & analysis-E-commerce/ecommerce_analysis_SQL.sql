use ecommerce_analysis;
/*==========================================================
        E-COMMERCE SQL ANALYSIS 
        Database : ecommerce_analysis
        Table    : ecommerce_data
==========================================================*/


-- ========================================================
-- Q1. Top 10 Highest Revenue Generating Products
-- ========================================================

SELECT
    SKU,
    Category,
    SUM(Amount) AS Total_Revenue
FROM ecommerce_data
GROUP BY SKU, Category
ORDER BY Total_Revenue DESC
LIMIT 10;


-- ========================================================
-- Q2. Which States Have the Highest Average Order Value?
-- ========================================================

SELECT
    `Ship-State`,
    COUNT(`Order ID`) AS Total_Orders,
    SUM(Amount) AS Total_Revenue,
    ROUND(AVG(Amount),2) AS Average_Order_Value
FROM ecommerce_data
GROUP BY `Ship-State`
ORDER BY Average_Order_Value DESC;


-- ========================================================
-- Q3. Customer Segmentation
-- VIP | Regular | New Customers
-- ========================================================

WITH customer_spending AS
(
    SELECT
        `Cust ID`,
        SUM(Amount) AS Total_Spending
    FROM ecommerce_data
    GROUP BY `Cust ID`
)

SELECT
    `Cust ID`,
    Total_Spending,

    CASE
WHEN Total_Spending >= 50000 THEN 'VIP Customer'
WHEN Total_Spending >= 20000 THEN 'Regular Customer'
ELSE 'New Customer'
END AS Customer_Segment
FROM customer_spending
ORDER BY Total_Spending DESC;


-- ========================================================
-- Q4. Channel Performance by Category
-- ========================================================

SELECT Channel,Category,
COUNT(*) AS Total_Orders,
SUM(Amount) AS Revenue,
ROUND(AVG(Amount),2) AS Average_Order_Value
FROM ecommerce_data
GROUP BY Channel, Category
ORDER BY Revenue DESC;


-- ========================================================
-- Q5. Top 3 Revenue Generating Products in Every Category
-- ========================================================

WITH product_sales AS
(SELECT Category, SKU, SUM(Amount) AS Revenue
FROM ecommerce_data
GROUP BY Category, SKU
),

ranked_products AS
(SELECT *,
ROW_NUMBER() OVER (
        PARTITION BY Category
        ORDER BY Revenue DESC
    ) AS Product_Rank

FROM product_sales

)

SELECT Category,SKU,Revenue,Product_Rank
FROM ranked_products
WHERE Product_Rank <=3
ORDER BY Category, Product_Rank;


-- ========================================================
-- Q6. Month over Month Revenue Growth
-- ========================================================

WITH monthly_sales AS

(SELECT Month, SUM(Amount) AS Revenue
FROM ecommerce_data
GROUP BY Month
),

growth AS
(SELECT Month, Revenue, LAG(Revenue) OVER
    (
        ORDER BY STR_TO_DATE(Month,'%M')
    ) AS Previous_Month_Revenue
FROM monthly_sales

)

SELECT
Month, Revenue, Previous_Month_Revenue,
ROUND(((Revenue-Previous_Month_Revenue)/
        Previous_Month_Revenue)*100,2) AS Growth_Percentage
FROM growth;
