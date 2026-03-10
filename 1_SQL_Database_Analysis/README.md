# E-Commerce Data Analytics Project (PostgreSQL)

## Project Overview

This project simulates a **real-world e-commerce analytics system** built using **PostgreSQL**.

The project demonstrates the full workflow of a **Data Analyst / BI Developer**:

- Database schema design
- Data modeling
- Data cleaning
- SQL business analysis
- Preparing data for BI tools (Power BI)

---

# Entity Relationship Diagram

Add the ER Diagram screenshot in the project folder and reference it below.

<img width="1040" height="598" alt="erd" src="https://github.com/user-attachments/assets/f495b1b4-1d4f-4975-8565-94a9fc417bf5" />


---

# Database Schema Design

The database consists of the following tables:

| Table | Description |
|------|-------------|
| category | Product categories |
| customers | Customer information |
| sellers | Seller information |
| products | Product catalog |
| orders | Customer orders |
| order_items | Items in each order |
| payments | Payment transactions |
| shipping | Shipping information |
| inventory | Product stock tracking |

---

# SQL: Table Creation & Data Modeling

```sql
--CREATE category table
DROP TABLE IF EXISTS category CASCADE;

CREATE TABLE category (
category_id INT PRIMARY KEY,
category_name VARCHAR (50)
);

--customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
first_name VARCHAR(20),
last_name VARCHAR(20),
state VARCHAR(20)
);

--sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
seller_id INT PRIMARY KEY,
name VARCHAR(25),
origin VARCHAR(30)
);

--products table
DROP TABLE IF EXISTS products;
CREATE TABLE products(
product_id INT PRIMARY KEY,
product_name VARCHAR(75),
price FLOAT,
cogs FLOAT,
category_id INT,
CONSTRAINT product_fk_category
FOREIGN KEY(category_id)
REFERENCES category(category_id)
);

--orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT,
seller_id INT,
order_status VARCHAR(50),
CONSTRAINT orders_customers_fk
FOREIGN KEY(customer_id)
REFERENCES customers(customer_id),
CONSTRAINT sellers_orders_fk
FOREIGN KEY(seller_id)
REFERENCES sellers(seller_id)
);

--order_items table
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
price_per_unit FLOAT,
CONSTRAINT order_items_orders_fk
FOREIGN KEY(order_id)
REFERENCES orders(order_id),
CONSTRAINT order_items_products_fk
FOREIGN KEY(product_id)
REFERENCES products(product_id)
);

--payments table
DROP TABLE IF EXISTS payments;
CREATE TABLE payments(
payment_id INT PRIMARY KEY,
order_id INT,
payment_date DATE,
payment_status VARCHAR(50),
CONSTRAINT payment_orders_fk
FOREIGN KEY(order_id)
REFERENCES orders(order_id)
);

--shipping table
DROP TABLE IF EXISTS shipping;
CREATE TABLE shipping(
shipping_id INT PRIMARY KEY,
order_id INT,
shipping_provider VARCHAR(50),
ship_date DATE,
delivery_date DATE,
shipping_status VARCHAR(50),
CONSTRAINT shipping_order_fk
FOREIGN KEY(order_id)
REFERENCES orders(order_id)
);

--inventory table
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory(
inventory_id INT PRIMARY KEY,
product_id INT,
stock_remaining INT,
warehouse_id INT,
re_stock_date DATE,
CONSTRAINT inventory_products_fk
FOREIGN KEY(product_id)
REFERENCES products(product_id)
);
```

---

# Data Cleaning Process

The following SQL scripts were used to standardize and validate the dataset.

## Payment Status Standardization

```sql
UPDATE payments
SET payment_status = 'refunded'
WHERE payment_status = 'pending';

UPDATE payments
SET payment_status = 'failed'
WHERE payment_status = 'payment_failed';

UPDATE payments
SET payment_status = 'success'
WHERE payment_status = 'payment_success';
```

---

## Remove Duplicate Shipping Records

```sql
SELECT shipping_id, COUNT(*)
FROM shipping
GROUP BY shipping_id
HAVING COUNT(*) > 1;

DELETE FROM shipping
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM shipping
    GROUP BY shipping_id
);
```

---

## Add Return Date Column

```sql
ALTER TABLE shipping
ADD COLUMN return_date DATE;
```

---

## Standardize Shipping Status

```sql
UPDATE shipping
SET shipping_status = 'delivered'
WHERE shipping_status IN ('in_transit','shipped');

UPDATE shipping
SET shipping_status = 'returned'
WHERE random() < 0.07;
```

---

## Generate Return Dates

```sql
UPDATE shipping
SET return_date = delivery_date + (floor(random()*10)+1)::int
WHERE shipping_status = 'returned';

UPDATE shipping
SET return_date = NULL
WHERE shipping_status = 'delivered';
```

---

# Business Problems Solved Using SQL

The project answers **20 real-world business analytics questions**.

---

# Business Problems Solved Using SQL

The following section contains **20 real-world business analytics questions** solved using SQL.

---

# Q1 — Top 10 Selling Products by Total Sales Value

```sql
SELECT oi.product_id,
       p.product_name,
       SUM(oi.total_sale) AS total_sales_per_product,
       COUNT(o.order_id) AS total_orders
FROM orders o
JOIN order_items oi
ON oi.order_id = o.order_id
JOIN products p
ON p.product_id = oi.product_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;
```

---

# Q2 — Revenue Generated by Each Product Category

```sql
SELECT c.category_name,
       SUM(oi.total_sale) AS Total_per_cat,
       (SUM(oi.total_sale) / (SELECT SUM(total_sale) FROM order_items) ) * 100 AS contribution
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category c
ON p.category_id = c.category_id
GROUP BY 1
ORDER BY 2 DESC;
```

---

# Q3 — Average Order Value per Customer (More Than 5 Orders)

```sql
SELECT c.customer_id,
       CONCAT(c.first_name ,' ', c.last_name) AS name,
       SUM(total_sale) / COUNT(o.order_id) AS AOV
FROM orders o
JOIN customers c
ON c.customer_id = o.customer_id
JOIN order_items oi
ON oi.order_id = o.order_id
GROUP BY 1 , 2
HAVING COUNT(o.order_id) > 5
ORDER BY 3 DESC
LIMIT 3;
```

---

# Q4 — Monthly Sales Trend Over the Past Year

```sql
SELECT 
	Month,
	Year,
	COALESCE(total_sale,0) AS current_month_sale,
	COALESCE(LAG(total_sale,1) OVER (ORDER BY Year,Month),0) AS last_month_sale
FROM 
(
	SELECT
		EXTRACT(YEAR FROM o.order_date) AS Year,
		EXTRACT(MONTH FROM o.order_date) AS Month,
		ROUND(SUM(oi.total_sale ::numeric),3) AS total_sale
		
	FROM orders o 
	JOIN order_items oi 
	ON o.order_id = oi.order_id
	WHERE order_date >= CURRENT_DATE - INTERVAL '1 year'
	GROUP BY 1,2
) AS t1;
```

---

# Q5 — Customers With No Purchases

```sql
SELECT customer_id,
       CONCAT(first_name ,' ', last_name) AS name
FROM customers 
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
);
```

---

# Q6 — Best-Selling Categories by State

```sql
WITH ranking_by_state AS
(
SELECT 
       cat.category_name,
       c.state,
       ROUND(SUM(oi.total_sale ::numeric),3) AS total_sales,
       RANK() OVER(PARTITION BY c.state ORDER BY SUM(oi.total_sale) DESC) AS Rank
FROM orders o 
JOIN customers c
ON o.customer_id = c.customer_id
JOIN order_items oi
ON o.order_id =oi.order_id
JOIN products p
ON oi.product_id = p.product_id
JOIN category cat
ON cat.category_id = p.category_id
GROUP BY 1,2
)

SELECT *
FROM ranking_by_state
WHERE rank = 1;
```

---

# Q7 — Customer Lifetime Value Ranking

```sql
SELECT o.customer_id,
       CONCAT(c.first_name ,' ', c.last_name) AS name,
       ROUND(SUM(oi.total_sale ::numeric),3) AS CLTV,
       DENSE_RANK() OVER(ORDER BY SUM(oi.total_sale) DESC) AS rank
FROM order_items oi
JOIN orders o
ON o.order_id = oi.order_id
LEFT JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY 1,2
LIMIT 5;
```

---

# Q8 — Products With Low Inventory

```sql
SELECT p.product_name,
       i.warehouse_id,
       i.re_stock_date,
       i.stock_remaining
FROM inventory i
LEFT JOIN products p
ON i.product_id = p.product_id
WHERE i.stock_remaining <10;
```

---

# Q9 — Orders Shipped More Than 7 Days After Order Date

```sql
SELECT p.product_name,
       s.shipping_provider,
       c.customer_id,
       CONCAT(c.first_name ,' ', c.last_name) AS name
FROM shipping s
JOIN order_items oi 
ON s.order_id = oi.order_id
JOIN orders o
ON o.order_id = oi.order_id
JOIN customers c
ON c.customer_id = o.customer_id
JOIN products p
ON oi.product_id = p.product_id
WHERE s.ship_date - o.order_date >7;
```

---

# Q10 — Payment Success Rate

```sql
SELECT p.payment_status,
       COUNT(*) AS total_cnt,
       ROUND(COUNT(*)/ (SELECT COUNT(*) FROM payments)::numeric*100,3) AS ratio
FROM orders o
JOIN payments p
ON o.order_id =p.order_id
GROUP BY 1;
```

---

# Q11 — Top Performing Sellers

```sql
WITH top_sellers AS (
    SELECT 
        s.name,
        s.seller_id,
        ROUND(SUM(oi.total_sale::numeric),3) AS total
    FROM order_items oi 
    JOIN orders o
        ON o.order_id = oi.order_id
    LEFT JOIN sellers s
        ON s.seller_id = o.seller_id
    GROUP BY s.name, s.seller_id
    ORDER BY total DESC
    LIMIT 5
),

order_status AS (
    SELECT  
        o.seller_id,
        ts.name,
        o.order_status,
        COUNT(*) AS total_orders
    FROM orders o
    JOIN top_sellers ts
        ON ts.seller_id = o.seller_id
    WHERE o.order_status NOT IN ('in_progress','refunded')
    GROUP BY o.seller_id, ts.name, o.order_status
)

SELECT 
    seller_id,
    name,
    SUM(CASE WHEN order_status = 'completed' THEN total_orders ELSE 0 END) AS completed,
    SUM(CASE WHEN order_status = 'cancelled' THEN total_orders ELSE 0 END) AS cancelled,
    SUM(total_orders) AS total_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'completed' THEN total_orders ELSE 0 END)::numeric
        / SUM(total_orders)::numeric * 100, 2
    ) AS successful_ratio
FROM order_status
GROUP BY seller_id, name
ORDER BY successful_ratio DESC;
```

---

# Q12 — Product Profit Margin Ranking

```sql
SELECT oi.product_id,
       p.product_name,
       ROUND(SUM(total_sale::numeric - (p.cogs::numeric * oi.quantity::numeric)),3) AS profit,
       DENSE_RANK() OVER(ORDER BY SUM(total_sale - (p.cogs * oi.quantity)) DESC) AS rank
FROM order_items oi
LEFT JOIN products p
ON p.product_id = oi.product_id
GROUP BY 1,2;
```

---

# Q13 — Top Products by Return Rate

```sql
SELECT 
    p.product_id,
    p.product_name,
    COUNT(*) AS total_sold,
    SUM(CASE WHEN s.shipping_status = 'returned' THEN 1 ELSE 0 END) AS total_return,
    ROUND(
        SUM(CASE WHEN s.shipping_status = 'returned' THEN 1 ELSE 0 END)::numeric 
        / COUNT(*)::numeric * 100,
        2
    ) AS percentage_of_return
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
JOIN orders o
ON o.order_id = oi.order_id
JOIN shipping s
ON s.order_id = oi.order_id
GROUP BY p.product_id, p.product_name
ORDER BY total_return DESC
LIMIT 10;
```

---

# Q14 — Sellers With No Sales in the Last 4 Months

```sql
WITH inactive_sellers AS(
	SELECT * FROM sellers
	WHERE seller_id NOT IN (
	    SELECT seller_id
	    FROM orders
	    WHERE order_date >= CURRENT_DATE - INTERVAL '4 month'
	)
)

SELECT o.seller_id,
       MAX(o.order_date) AS last_sale_date,
       MAX(oi.total_sale) AS last_sale_amount
FROM orders o
JOIN inactive_sellers ins
ON ins.seller_id = o.seller_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY 1;
```

---

# Q15 — Customer Return Behavior Classification

```sql
SELECT 
     c.customer_id,
     CONCAT(c.first_name ,' ', c.last_name) AS customer_name,
     COUNT(o.order_id) AS Total_orders,
     SUM(CASE 
         WHEN s.shipping_status ='returned' THEN 1
         ELSE 0
     END) AS total_returns,
     CASE 
        WHEN SUM(CASE WHEN s.shipping_status = 'returned' THEN 1 ELSE 0 END) > 5 
        THEN 'returning'
        ELSE 'new'
     END AS customer_category
FROM shipping s
LEFT JOIN orders o
ON s.order_id = o.order_id
LEFT JOIN customers c
ON c.customer_id = o.customer_id
GROUP BY 1,2;
```

---

# Q16 — Top 5 Customers by Orders in Each State

```sql
WITH top_in_state AS
(
SELECT c.state,
       CONCAT(c.first_name ,' ', c.last_name) AS customer_name,
       COUNT(o.order_id) AS total_orders,
       ROUND(SUM(oi.total_sale)::numeric,3) AS total_sale,
       DENSE_RANK() OVER(PARTITION BY c.state ORDER BY COUNT(o.order_id) DESC) AS rank
FROM orders o
JOIN order_items oi 
ON oi.order_id = o.order_id
JOIN customers c
ON c.customer_id = o.customer_id
GROUP BY 1,2
)

SELECT *
FROM top_in_state
WHERE rank <= 5;
```

---

# Q17 — Revenue by Shipping Provider

```sql
SELECT s.shipping_provider,
       COUNT(o.order_id) AS total_orders,
       SUM(oi.total_sale) AS total_revenue,
       ROUND(AVG(s.delivery_date - s.ship_date)::numeric,0) AS average_delivery_time
FROM shipping s
LEFT JOIN order_items oi
ON oi.order_id = s.order_id
LEFT JOIN orders o
ON o.order_id = oi.order_id
GROUP BY 1;
```

---

# Q18 — Products With Highest Revenue Decrease

```sql
WITH last_year_sale AS
(
	SELECT p.product_id,
	       p.product_name,
	       SUM(oi.total_sale) AS revenue
	FROM orders o
	JOIN order_items oi
	ON oi.order_id = o.order_id
	JOIN products p
	ON p.product_id = oi.product_id
	WHERE EXTRACT(YEAR FROM o.order_date) = 2024
	GROUP BY 1,2
),

current_year_sale AS
(
	SELECT p.product_id,
	       p.product_name,
	       SUM(oi.total_sale) AS revenue
	FROM orders o
	JOIN order_items oi
	ON oi.order_id = o.order_id
	JOIN products p
	ON p.product_id = oi.product_id
	WHERE EXTRACT(YEAR FROM o.order_date) = 2025
	GROUP BY 1,2
)

SELECT cs.product_id,
       ls.revenue AS last_year_revenue,
       cs.revenue AS current_year_revenue,
       ls.revenue - cs.revenue AS rev_diff,
       (ls.revenue - cs.revenue) / ls.revenue * 100 AS rev_dec_ratio
FROM last_year_sale ls
JOIN current_year_sale cs
ON ls.product_id = cs.product_id
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 10;
```

---

# Q19 — Customer Retention Within 30 Days

```sql
WITH customer_orders AS (
SELECT 
    o.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    o.order_date AS first_order_date,
    LEAD(o.order_date) OVER(
        PARTITION BY o.customer_id 
        ORDER BY o.order_date
    ) AS next_order_date
FROM orders o
JOIN customers c
ON c.customer_id = o.customer_id
)

SELECT *,
       next_order_date - first_order_date AS days_between_orders
FROM customer_orders
WHERE next_order_date - first_order_date <= 30;
```

---

# Q20 — Product Cross-Selling Analysis

```sql
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2
ON oi1.order_id = oi2.order_id
AND oi1.product_id < oi2.product_id
JOIN products p1
ON oi1.product_id = p1.product_id
JOIN products p2
ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY times_bought_together DESC
LIMIT 5;
```

# Advanced SQL Concepts Used

This project demonstrates several professional SQL techniques:

- Window Functions (`RANK`, `DENSE_RANK`, `LAG`, `LEAD`)
- Common Table Expressions (CTEs)
- Data Cleaning Queries
- Aggregate Functions
- Complex Joins
- Business KPI Calculations

---

# Skills Demonstrated

- Data Modeling
- PostgreSQL
- SQL Analytics
- Data Cleaning
- Business Intelligence Thinking
- Analytical Problem Solving

---

# Tools Used

- PostgreSQL
- pgAdmin
- SQL
- Power BI (for dashboard visualization)

---

# Future Improvements

Possible enhancements:

- Power BI dashboard
- Customer segmentation
- Demand forecasting
- Automated ETL pipelines

---

# Author

**Vishva Suraj**

Aspiring **Data Analyst / BI Developer**
