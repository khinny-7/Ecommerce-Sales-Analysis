
CREATE DATABASE ecommerce_uk;
USE ecommerce_uk;

# Table for cleaned sales data

DROP TABLE IF EXISTS clean_sales;

CREATE TABLE clean_sales (
    InvoiceNo VARCHAR(50),
    StockCode VARCHAR(50),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(12,2),
    CustomerID VARCHAR(50),
    Country VARCHAR(100),
    Sales DECIMAL(14,2)
);

SELECT * FROM clean_sales;

# Table for customer data
CREATE TABLE customer_sales (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100),
    Sales DECIMAL(12,2)
);

# Table for returns and cancellations
CREATE TABLE returns (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100),
    ReturnValue DECIMAL(12,2)
);


USE ecommerce_uk;

SELECT COUNT(*) AS total_rows
FROM clean_sales;
SELECT * FROM clean_sales;

SELECT COUNT(*) AS total_rows
FROM customer_sales;

SELECT COUNT(*) AS total_rows
FROM returns;
# ------------------------------------- #
# 1. Total Revenue
SELECT 
	ROUND(SUM(sales),2) AS total_revenue
FROM clean_sales;
# ------------------------------------- #
# 2. Monthly Revenue
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
    ROUND(SUM(Sales), 2) AS monthly_revenue
FROM clean_sales
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY month;
# ------------------------------------- #
# 3. Top 10 products by revenue
SELECT 
    StockCode,
    Description,
    ROUND(SUM(Sales), 2) AS total_revenue
FROM clean_sales
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 10;
# ------------------------------------- #
# 4. Top 10 products by quantity sold
SELECT 
    StockCode,
    Description,
    SUM(Quantity) AS total_quantity_sold
FROM clean_sales
GROUP BY StockCode, Description
ORDER BY total_quantity_sold DESC
LIMIT 10;

# ------------------------------------- #
# 5. Top 10 customers by revenue

SELECT 
    CustomerID,
    ROUND(SUM(Sales), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS number_of_orders
FROM customer_sales
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;

# ------------------------------------- #
# 6. Revenue by country
# Which countries generate the most revenue?

SELECT 
    Country,
    ROUND(SUM(Sales), 2) AS total_revenue
FROM clean_sales
GROUP BY Country
ORDER BY total_revenue DESC;
# ------------------------------------- #
# 7. Average order value by country
# Which countries have higher-value orders on average?

SELECT 
    Country,
    ROUND(SUM(Sales), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS number_of_orders,
    ROUND(SUM(Sales) / COUNT(DISTINCT InvoiceNo), 2) AS average_order_value
FROM clean_sales
GROUP BY Country
HAVING COUNT(DISTINCT InvoiceNo) >= 10
ORDER BY average_order_value DESC;
# ------------------------------------- #
# 8. Top 10 returned products by return value
# Which products cause the highest return value?

SELECT 
    StockCode,
    Description,
    ABS(SUM(Quantity)) AS returned_quantity,
    COUNT(DISTINCT InvoiceNo) AS number_of_return_transactions,
    ROUND(SUM(ReturnValue), 2) AS total_return_value
FROM returns
GROUP BY StockCode, Description
ORDER BY total_return_value DESC
LIMIT 10;
# ------------------------------------- #
# 9. Top 10 returned products by return frequency
# Which products are returned most often?

SELECT 
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS number_of_return_transactions,
    ABS(SUM(Quantity)) AS returned_quantity,
    ROUND(SUM(ReturnValue), 2) AS total_return_value
FROM returns
GROUP BY StockCode, Description
ORDER BY number_of_return_transactions DESC
LIMIT 10;
# ------------------------------------- #
# 10. Busiest sales hours
# What time of day receives the most orders?

SELECT 
    HOUR(InvoiceDate) AS hour_of_day,
    COUNT(DISTINCT InvoiceNo) AS number_of_orders,
    ROUND(SUM(Sales), 2) AS total_revenue
FROM clean_sales
GROUP BY HOUR(InvoiceDate)
ORDER BY hour_of_day;
# ------------------------------------- #
# 11. Customer value segmentation
# Which customers are high, medium, or low value?/ How can customers be grouped based on total spending?

WITH customer_revenue AS (
    SELECT 
        CustomerID,
        ROUND(SUM(Sales), 2) AS total_revenue,
        COUNT(DISTINCT InvoiceNo) AS number_of_orders
    FROM customer_sales
    GROUP BY CustomerID
)

SELECT 
    CustomerID,
    total_revenue,
    number_of_orders,
    CASE 
        WHEN total_revenue >= 5000 THEN 'High Value'
        WHEN total_revenue >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_revenue
ORDER BY total_revenue DESC;
# ------------------------------------- #
# 12. Number of customers by segment
# How many customers are high, medium, and low value?

WITH customer_revenue AS (
    SELECT 
        CustomerID,
        SUM(Sales) AS total_revenue
    FROM customer_sales
    GROUP BY CustomerID
),

customer_segments AS (
    SELECT 
        CustomerID,
        CASE 
            WHEN total_revenue >= 5000 THEN 'High Value'
            WHEN total_revenue >= 1000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_revenue
)

SELECT 
    customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY number_of_customers DESC;
# ------------------------------------- #
# 13. Product return rate
# Which products are returned most compared with how much they are sold?

WITH product_sales AS (
    SELECT 
        StockCode,
        Description,
        SUM(Quantity) AS total_quantity_sold,
        ROUND(SUM(Sales), 2) AS total_sales_value
    FROM clean_sales
    GROUP BY StockCode, Description
),

product_returns AS (
    SELECT 
        StockCode,
        ABS(SUM(Quantity)) AS total_quantity_returned,
        ROUND(SUM(ReturnValue), 2) AS total_return_value
    FROM returns
    GROUP BY StockCode
)

SELECT 
    ps.StockCode,
    ps.Description,
    ps.total_quantity_sold,
    COALESCE(pr.total_quantity_returned, 0) AS total_quantity_returned,
    ROUND(
        COALESCE(pr.total_quantity_returned, 0) / ps.total_quantity_sold * 100,
        2
    ) AS return_rate_percentage,
    ps.total_sales_value,
    COALESCE(pr.total_return_value, 0) AS total_return_value
FROM product_sales ps
LEFT JOIN product_returns pr
    ON ps.StockCode = pr.StockCode
WHERE ps.total_quantity_sold > 0
ORDER BY return_rate_percentage DESC
LIMIT 20;

# ------------------------------------- #
# 14. Monthly revenue growth rate
# How does revenue grow or decline compared with the previous month?

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
        ROUND(SUM(Sales), 2) AS monthly_revenue
    FROM clean_sales
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
),

monthly_growth AS (
    SELECT 
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT 
    month,
    monthly_revenue,
    previous_month_revenue,
    ROUND(
        (monthly_revenue - previous_month_revenue) / previous_month_revenue * 100,
        2
    ) AS monthly_growth_percentage
FROM monthly_growth
ORDER BY month;
# ------------------------------------- #
# 15. Top product in each country
# What is the best-selling product by revenue in each country?

WITH product_country_revenue AS (
    SELECT 
        Country,
        StockCode,
        Description,
        ROUND(SUM(Sales), 2) AS total_revenue
    FROM clean_sales
    GROUP BY Country, StockCode, Description
),

ranked_products AS (
    SELECT 
        Country,
        StockCode,
        Description,
        total_revenue,
        RANK() OVER (
            PARTITION BY Country 
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_country_revenue
)

SELECT 
    Country,
    StockCode,
    Description,
    total_revenue
FROM ranked_products
WHERE product_rank = 1
ORDER BY total_revenue DESC;

# ------------------END of Project------------------ #