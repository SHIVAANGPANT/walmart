USE walmart_db;

SHOW TABLES;
SELECT COUNT(*) FROM walmart;
SELECT * FROM walmart LIMIT 10;


select COUNT(DISTINCT branch)
FROM walmart;

SELECT min(quantity) FROM walmart;

-- Business Problem 
-- Q1 Find different payment mehtod and number of transactions , number of qty sold
SELECT DISTINCT
   payment_method,
   COUNT(*) as no_payments,
   SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--  Identify the Highest-Rated Category in Each Branch
-- Q2: Which category received the highest average rating in each branch?
SELECT *
FROM
( SELECT
	branch,
    category,
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as R
FROM walmart
GROUP BY 1, 2
)AS ranked_data
WHERE R =1;


-- Determine the Busiest Day for Each Branch
-- Q3: What is the busiest day of the week for each branch based on transaction volume?
SELECT 
    formatted_date,
    day_name,
    COUNT(*) AS no_transactions
FROM (
    SELECT 
        STR_TO_DATE(date, '%d/%m/%y') AS formatted_date,
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name
    FROM walmart
) AS sub
GROUP BY 1,2
ORDER BY 1,2 DESC;


-- Q4: Total quantity sold per payment method

SELECT 
    payment_method,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;


-- Q5: Average, min, and max rating of each category per city

SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Total profit per category using profit_margin

SELECT 
    category,
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q8: Categorize time into Morning, Afternoon, Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) < 12 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS invoice_count
FROM walmart
GROUP BY branch, shift
ORDER BY branch, invoice_count DESC;

-- Q9: Top 5 branches with highest revenue decrease from 2022 to 2023

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)
SELECT 
    r22.branch,
    r22.revenue AS last_year_revenue,
    r23.revenue AS current_year_revenue,
    ROUND(((r22.revenue - r23.revenue) / r22.revenue) * 100, 2) AS rev_dec_ratio
FROM revenue_2022 r22
JOIN revenue_2023 r23 ON r22.branch = r23.branch
WHERE r22.revenue > r23.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;


