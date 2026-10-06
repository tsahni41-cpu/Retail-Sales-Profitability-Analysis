-- Retail Sales & Profitability Analysis
-- Portfolio queries for MySQL 8.0+

USE retail_sales_portfolio;


-- 1. Dataset overview
SELECT
  COUNT(*) AS transaction_lines,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(DISTINCT customer_id) AS customers,
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date
FROM retail_sales;

-- 2. Overall sales and profitability KPIs
SELECT
  SUM(quantity) AS units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 1) AS profit_margin_pct
FROM retail_sales;

-- 3. Average order value (calculated at order level)
WITH order_totals AS (
  SELECT order_id, SUM(revenue) AS order_revenue
  FROM retail_sales
  GROUP BY order_id
)
SELECT ROUND(AVG(order_revenue), 2) AS average_order_value
FROM order_totals;

-- 4. Monthly revenue trend
SELECT
  DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit,
  ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 1) AS profit_margin_pct
FROM retail_sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

-- 5. Performance by region
SELECT
  region,
  COUNT(DISTINCT order_id) AS orders,
  SUM(quantity) AS units_sold,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit,
  ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 1) AS profit_margin_pct
FROM retail_sales
GROUP BY region
ORDER BY revenue DESC;

-- 6. Profitability by category
SELECT
  category,
  SUM(quantity) AS units_sold,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit,
  ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 1) AS profit_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY profit DESC;

-- 7. Top 10 products by revenue
SELECT
  product,
  category,
  SUM(quantity) AS units_sold,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit
FROM retail_sales
GROUP BY product, category
ORDER BY revenue DESC
LIMIT 10;

-- 8. Top 10 customers by revenue
SELECT
  customer_id,
  customer_name,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit
FROM retail_sales
GROUP BY customer_id, customer_name
ORDER BY revenue DESC
LIMIT 10;

-- 9. Compare sales channels
SELECT
  sales_channel,
  COUNT(*) AS transaction_lines,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit,
  ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 1) AS profit_margin_pct
FROM retail_sales
GROUP BY sales_channel
ORDER BY revenue DESC;

-- 10. Payment-method mix
SELECT
  payment_method,
  COUNT(*) AS transaction_lines,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_of_lines_pct,
  ROUND(SUM(revenue), 2) AS revenue
FROM retail_sales
GROUP BY payment_method
ORDER BY transaction_lines DESC;

-- 11. Loss-making transaction lines to investigate
SELECT
  transaction_id,
  order_id,
  order_date,
  customer_name,
  product,
  category,
  sales_channel,
  ROUND(revenue, 2) AS revenue,
  ROUND(cost, 2) AS cost,
  ROUND(profit, 2) AS profit
FROM retail_sales
WHERE profit < 0
ORDER BY profit ASC;

-- 12. Product margin comparison
SELECT
  product,
  category,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit,
  ROUND(100 * SUM(profit) / NULLIF(SUM(revenue), 0), 1) AS profit_margin_pct
FROM retail_sales
GROUP BY product, category
ORDER BY profit_margin_pct DESC, revenue DESC;

-- 13. Year-over-year revenue and growth
WITH annual_sales AS (
  SELECT YEAR(order_date) AS sales_year, SUM(revenue) AS revenue
  FROM retail_sales
  GROUP BY YEAR(order_date)
),
annual_comparison AS (
  SELECT
    sales_year,
    revenue,
    LAG(revenue) OVER (ORDER BY sales_year) AS previous_year_revenue
  FROM annual_sales
)
SELECT
  sales_year,
  ROUND(revenue, 2) AS revenue,
  ROUND(previous_year_revenue, 2) AS previous_year_revenue,
  ROUND(100 * (revenue - previous_year_revenue) /
    NULLIF(previous_year_revenue, 0), 1) AS year_over_year_growth_pct
FROM annual_comparison
ORDER BY sales_year;

-- 14. Monthly revenue with a running total
WITH monthly_sales AS (
  SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(revenue) AS monthly_revenue
  FROM retail_sales
  GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
  sales_month,
  ROUND(monthly_revenue, 2) AS monthly_revenue,
  ROUND(SUM(monthly_revenue) OVER (ORDER BY sales_month), 2) AS running_revenue
FROM monthly_sales
ORDER BY sales_month;

-- 15. Rank products by revenue within each category
WITH product_sales AS (
  SELECT
    category,
    product,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit
  FROM retail_sales
  GROUP BY category, product
)
SELECT
  category,
  product,
  ROUND(revenue, 2) AS revenue,
  ROUND(profit, 2) AS profit,
  DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS revenue_rank
FROM product_sales
ORDER BY category, revenue_rank, product;
