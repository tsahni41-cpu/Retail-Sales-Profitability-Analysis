-- Retail Sales & Profitability Analysis
-- Step 1: Create the portfolio database and table.
-- Safe to run more than once: this script does not delete existing data.

CREATE DATABASE IF NOT EXISTS retail_sales_portfolio
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE retail_sales_portfolio;

CREATE TABLE IF NOT EXISTS retail_sales (
  transaction_id INT NOT NULL,
  order_id VARCHAR(20) NOT NULL,
  order_date DATE NOT NULL,
  customer_id VARCHAR(20) NOT NULL,
  customer_name VARCHAR(100) NOT NULL,
  city VARCHAR(60) NOT NULL,
  region VARCHAR(40) NOT NULL,
  product VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  revenue DECIMAL(12, 2) NOT NULL,
  cost DECIMAL(12, 2) NOT NULL,
  profit DECIMAL(12, 2) NOT NULL,
  payment_method VARCHAR(30) NOT NULL,
  sales_channel VARCHAR(30) NOT NULL,
  PRIMARY KEY (transaction_id),
  CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
  CONSTRAINT chk_unit_price_nonnegative CHECK (unit_price >= 0),
  CONSTRAINT chk_revenue_nonnegative CHECK (revenue >= 0),
  CONSTRAINT chk_cost_nonnegative CHECK (cost >= 0)
);

-- After importing retail_sales_mysql_ready.csv with the Table Data Import Wizard,
-- highlight and run the checks below. Expected results:
-- 900 rows, 650 orders, dates from 2024-01-01 to 2025-12-31.

SELECT
  COUNT(*) AS imported_rows,
  COUNT(DISTINCT order_id) AS distinct_orders,
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date
FROM retail_sales;

-- Expected duplicate transaction IDs: 0.
SELECT COUNT(*) AS duplicate_transaction_ids
FROM (
  SELECT transaction_id
  FROM retail_sales
  GROUP BY transaction_id
  HAVING COUNT(*) > 1
) AS duplicates;

-- Expected totals: 1,501 units, £67,938.50 revenue,
-- £47,871.97 cost and £20,066.53 profit.
SELECT
  SUM(quantity) AS total_units,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(profit), 2) AS total_profit
FROM retail_sales;
