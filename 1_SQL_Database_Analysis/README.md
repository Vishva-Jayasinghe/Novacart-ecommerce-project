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

![ER Diagram](er_diagram.png)

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

# Example Analysis Queries

## Top 10 Selling Products

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

## Revenue by Product Category

```sql
SELECT c.category_name,
       SUM(oi.total_sale) AS Total_per_cat,
       (SUM(oi.total_sale) / (SELECT SUM(total_sale) FROM order_items)) * 100 AS contribution
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category c
ON p.category_id = c.category_id
GROUP BY 1
ORDER BY 2 DESC;
```

---

## Customer Lifetime Value

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

## Product Cross-Selling Analysis

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

---

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
