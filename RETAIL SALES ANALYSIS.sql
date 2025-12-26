RETAIL SALES ANALYSIS....>

1. Top 10 Highest Revenue-Generating Products
This query identifies the best-performing products by calculating the total sum of the sale price for each unique product ID.
SELECT TOP 10 product_id, SUM(sale_price) AS sales 
FROM df_orders 
GROUP BY product_id 
ORDER BY sales DESC;
2. Top 5 Highest-Selling Products in Each Region
Using a Common Table Expression (CTE) and the ROW_NUMBER() window function, this query ranks products within their respective regions and filters for the top five.
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales 
    FROM df_orders 
    GROUP BY region, product_id
) 
SELECT * FROM (
    SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn 
    FROM cte
) A 
WHERE rn <= 5;
3. Month-over-Month Growth Comparison (2022 vs 2023)
This query pivots the data using CASE statements to display sales for 2022 and 2023 side-by-side for every month of the year.
WITH cte AS (
    SELECT YEAR(order_date) AS order_year, 
           MONTH(order_date) AS order_month, 
           SUM(sale_price) AS sales 
    FROM df_orders 
    GROUP BY YEAR(order_date), MONTH(order_date)
) 
SELECT order_month, 
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022, 
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023 
FROM cte 
GROUP BY order_month 
ORDER BY order_month;
4. Peak Sales Month for Each Category
By applying the FORMAT function, this query isolates the specific year-month combination that produced the highest revenue for every product category.
WITH cte AS (
    SELECT category, 
           FORMAT(order_date, 'yyyyMM') AS order_year_month, 
           SUM(sale_price) AS sales 
    FROM df_orders 
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
) 
SELECT * FROM (
    SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn 
    FROM cte
) a 
WHERE rn = 1;
5. Subcategory with the Highest Growth (Profit/Sales) in 2023
This query calculates the percentage growth between 2022 and 2023 to find the single subcategory with the most significant year-over-year improvement.
WITH cte AS (
    SELECT sub_category, 
           YEAR(order_date) AS order_year, 
           SUM(sale_price) AS sales 
    FROM df_orders 
    GROUP BY sub_category, YEAR(order_date)
), 
cte2 AS (
    SELECT sub_category, 
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022, 
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023 
    FROM cte 
    GROUP BY sub_category
) 
SELECT TOP 1 *, 
       (sales_2023 - sales_2022) * 100 / sales_2022 AS growth_percent 
FROM cte2 
ORDER BY growth_percent DESC;