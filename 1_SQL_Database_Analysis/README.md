# NovaCart E-Commerce SQL Analytics Project

## Project Overview

NovaCart is a simulated **E-commerce analytics system** built to demonstrate real-world SQL skills used by **Data Analysts, BI Developers, and Data Engineers**.

This project focuses on:

* Relational **database design**
* **Data cleaning and validation**
* Solving **real business problems using SQL**
* **Sales, customer, product, and operational analytics**

The database represents an online marketplace where:

* Customers purchase products
* Sellers provide products
* Orders are processed
* Payments are made
* Shipping providers deliver products
* Inventory is managed

This project demonstrates the type of SQL analysis expected in **professional data analytics roles**.

---

# Entity Relationship Diagram

Add your ER diagram image in the repository and reference it here:

```
![ER Diagram](ERD.png)
```

---

# Database Schema

The database contains **9 relational tables**:

| Table       | Description            |
| ----------- | ---------------------- |
| category    | Product categories     |
| customers   | Customer information   |
| sellers     | Seller details         |
| products    | Product catalog        |
| orders      | Customer orders        |
| order_items | Products inside orders |
| payments    | Payment transactions   |
| shipping    | Shipping details       |
| inventory   | Warehouse inventory    |

---

# Table Creation & Data Modeling

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
payment_date DATE ,
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

# Data Cleaning & Data Validation

Before performing analytics, several **data cleaning steps** were performed to ensure data accuracy and integrity.

---

## Standardizing Payment Status

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

## Removing Duplicate Shipping Records

```sql
DELETE FROM shipping
WHERE ctid NOT IN (
SELECT MIN(ctid)
FROM shipping
GROUP BY shipping_id
);
```

---

## Adding Return Tracking

```sql
ALTER TABLE shipping
ADD COLUMN return_date DATE;
```

---

## Simulating Product Returns

```sql
UPDATE shipping
SET shipping_status = 'returned'
WHERE random() < 0.07;

UPDATE shipping
SET return_date = delivery_date + (floor(random()*10)+1)::int
WHERE shipping_status = 'returned';

UPDATE shipping
SET return_date = NULL
WHERE shipping_status = 'delivered';
```

---

## Data Validation Checks

### Delivery cannot happen before shipping

```sql
SELECT *
FROM shipping
WHERE delivery_date < ship_date;
```

### Payment cannot occur before order date

```sql
SELECT p.*
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
WHERE p.payment_date < o.order_date;
```

---

# Business Problems Solved

This project answers **20 real-world business analytics questions** commonly asked in data analyst roles.

---

# Sales Analysis

### 1. Top 10 selling products by revenue

Identify the products generating the highest sales.

### 2. Revenue contribution by product category

Determine which categories generate the largest share of revenue.

### 3. Average order value by customer

Calculate AOV for customers with more than 5 orders.

### 4. Monthly sales trend

Analyze revenue trends month over month.

---

# Customer Analytics

### 5. Customers with no purchases

Identify registered customers who never made an order.

### 6. Customer Lifetime Value (CLTV)

Rank customers based on their total lifetime purchase value.

### 7. Customer retention analysis

Find customers who made repeat purchases within **30 days**.

### 8. Customer classification

Categorize customers as **new or returning** based on return behavior.

---

# Product & Inventory Insights

### 9. Low inventory products

Identify products with **stock below threshold**.

### 10. Profit margin analysis

Calculate profit margin per product.

### 11. Product return analysis

Identify products with the **highest return rates**.

### 12. Cross-selling analysis

Find products frequently purchased together.

---

# Operational Insights

### 13. Shipping delays

Find orders where shipping occurred **more than 7 days after order date**.

### 14. Revenue by shipping provider

Analyze shipping provider performance.

### 15. Seller performance

Identify top sellers and their success rate.

### 16. Inactive sellers

Find sellers without sales in the last **4 months**.

---

# Market Insights

### 17. Best selling category by state

Understand regional product demand.

### 18. Top customers by state

Identify most active customers regionally.

### 19. Revenue decline analysis

Find products with **decreasing revenue compared to last year**.

### 20. Product bundle analysis

Identify product combinations frequently purchased together.

---

# Example Analytical Query

Top selling products by revenue.

```sql
SELECT oi.product_id,
p.product_name,
SUM(oi.total_sale) AS total_sales_per_product
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;
```

---

# Skills Demonstrated

### SQL Skills

* Complex Joins
* Window Functions
* CTEs
* Aggregations
* Data Cleaning
* Data Validation

### Analytics Skills

* Customer Lifetime Value Analysis
* Sales Trend Analysis
* Product Performance Analysis
* Inventory Monitoring
* Customer Retention Analysis
* Operational Metrics

---

# Tools Used

* PostgreSQL
* SQL
* Data Modeling
* Data Cleaning
* Analytical Querying

---

# Project Structure

```
NovaCart-SQL-Analytics
│
├── table_creation_modeling.sql
├── data_cleaning.sql
├── business_question_solutions.sql
├── ERD.png
└── README.md
```

---

# Author

SQL Data Analytics Portfolio Project

Created to demonstrate **real-world SQL analytics capabilities for hiring managers and recruiters**.
