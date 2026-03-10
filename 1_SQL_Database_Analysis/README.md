E-Commerce Database Project – SQL
Project Overview

This project demonstrates the design, data cleaning, and validation of an E-Commerce relational database using PostgreSQL.

The system models the core operations of an online store including:

Customers

Sellers

Products

Orders

Payments

Shipping

Inventory

Categories

The project includes:

Database schema design

Table creation with primary and foreign keys

Data cleaning and validation queries

Data integrity checks

ER Diagram

<img width="1040" height="598" alt="erd" src="https://github.com/user-attachments/assets/90d258c4-0756-4217-904e-71db4b0fc90c" />



Database Schema Creation
Category Table
DROP TABLE IF EXISTS category CASCADE;

CREATE TABLE category (
category_id INT PRIMARY KEY,
category_name VARCHAR(50)
);
Customers Table
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
customer_id INT PRIMARY KEY,
first_name VARCHAR(20),
last_name VARCHAR(20),
state VARCHAR(20)
);
Sellers Table
DROP TABLE IF EXISTS sellers;

CREATE TABLE sellers (
seller_id INT PRIMARY KEY,
name VARCHAR(25),
origin VARCHAR(30)
);
Products Table
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
Orders Table
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
Order Items Table
DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items(
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
Payments Table
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
Shipping Table
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
Inventory Table
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
Data Validation Queries
SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM shipping;
Data Cleaning Process
Standardizing Payment Status
UPDATE payments
SET payment_status = 'refunded'
WHERE payment_status = 'pending';

UPDATE payments
SET payment_status = 'failed'
WHERE payment_status = 'payment_failed';

UPDATE payments
SET payment_status = 'success'
WHERE payment_status = 'payment_success';

Check values

SELECT DISTINCT payment_status
FROM payments;
Removing Duplicate Records
Shipping Table
SELECT shipping_id, COUNT(*)
FROM shipping
GROUP BY shipping_id
HAVING COUNT(*) > 1;

Delete duplicates

DELETE FROM shipping
WHERE ctid NOT IN (
SELECT MIN(ctid)
FROM shipping
GROUP BY shipping_id
);
Shipping Table Enhancements

Add return date column

ALTER TABLE shipping
ADD COLUMN return_date DATE;

Standardize shipping status

UPDATE shipping
SET shipping_status = 'delivered'
WHERE shipping_status IN ('in_transit','shipped');

Randomly mark returned orders

UPDATE shipping
SET shipping_status = 'returned'
WHERE random() < 0.07;

Generate return dates

UPDATE shipping
SET return_date = delivery_date + (floor(random()*10)+1)::int
WHERE shipping_status = 'returned';

Ensure delivered orders have no return date

UPDATE shipping
SET return_date = NULL
WHERE shipping_status = 'delivered';
Data Quality Checks

Delivery cannot happen before shipping.

SELECT *
FROM shipping
WHERE delivery_date < ship_date;
Orders and Payments Integrity

Find orders without payments

SELECT o.order_id
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id
WHERE p.order_id IS NULL;
Foreign Key Improvements
ALTER TABLE shipping
DROP CONSTRAINT shipping_order_fk;

ALTER TABLE shipping
ADD CONSTRAINT shipping_order_fk
FOREIGN KEY(order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;

Test

DELETE FROM orders WHERE order_id = 7;

Add cascade to payments

ALTER TABLE payments
ADD CONSTRAINT payments_order_fk
FOREIGN KEY(order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;
Integrity Testing

Check payments without orders

SELECT *
FROM payments
WHERE order_id NOT IN (
SELECT order_id FROM orders
);
Payment Date Validation

Payments should not occur before order date.

SELECT p.*
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
WHERE p.payment_date < o.order_date;

Fix invalid dates

UPDATE payments p
SET payment_date = o.order_date
FROM orders o
WHERE p.order_id = o.order_id
AND p.payment_date < o.order_date;
Orders Table Cleaning

Remove duplicates

DELETE FROM orders
WHERE ctid NOT IN (
SELECT MIN(ctid)
FROM orders
GROUP BY order_id
);

Validate order dates

SELECT *
FROM orders
WHERE order_date > CURRENT_DATE;
SQL Skills Demonstrated

Database schema design

Primary and foreign key relationships

Data cleaning

Duplicate removal

Data validation

Data integrity checks

SQL updates and transformations

Constraint management

Tools Used

PostgreSQL
SQL
pgAdmin

Author

Vishva Suraj
Aspiring Data Analyst | SQL | Data Analysis | Database Design
