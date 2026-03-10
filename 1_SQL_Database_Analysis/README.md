# E-Commerce Data Analytics Project (PostgreSQL + BI Ready)

## Project Overview

This project simulates a **real-world e-commerce analytics workflow** using PostgreSQL.

It covers the full analytics lifecycle:

- Database schema design
- Data modeling
- Data cleaning
- Business analysis using SQL
- Preparing the data for BI tools such as Power BI

The goal of this project is to demonstrate **professional SQL and analytical skills required for Data Analyst / BI Developer roles.**

---

# Database Architecture

The database is designed using a **relational data model** for an e-commerce system.

Main entities include:

- Customers
- Sellers
- Products
- Categories
- Orders
- Order Items
- Payments
- Shipping
- Inventory

Each table is connected using **Primary Keys and Foreign Keys** to maintain referential integrity.

---

# Entity Relationship Diagram

Add your ER diagram screenshot inside the project folder and reference it like this:

```markdown
![ER Diagram](er_diagram.png)
```

Example:

![ER Diagram](er_diagram.png)

---

# Database Schema

## Core Tables

| Table | Description |
|------|-------------|
| category | Stores product categories |
| customers | Stores customer information |
| sellers | Stores seller information |
| products | Product catalog |
| orders | Customer orders |
| order_items | Products included in each order |
| payments | Payment transactions |
| shipping | Shipping and delivery details |
| inventory | Product stock tracking |

---

# Data Cleaning Process

Several data quality improvements were implemented.

## 1. Standardizing Payment Status

The payment status column contained inconsistent values.

Standardization rules applied:

- `pending` → `refunded`
- `payment_failed` → `failed`
- `payment_success` → `success`

---

## 2. Removing Duplicate Records

Duplicate shipping records were identified using:

```sql
SELECT shipping_id, COUNT(*)
FROM shipping
GROUP BY shipping_id
HAVING COUNT(*) > 1;
```

Duplicates were removed using PostgreSQL's **ctid system column**.

---

## 3. Shipping Table Improvements

A new column was added to track returned orders.

```sql
ALTER TABLE shipping
ADD COLUMN return_date DATE;
```

Shipping statuses were standardized:

- delivered
- returned

Returned orders were assigned **random return dates**.

---

## 4. Data Validation Rules

Several checks were performed to maintain data integrity.

Examples:

### Delivery date must be after shipping date

```sql
SELECT *
FROM shipping
WHERE delivery_date < ship_date;
```

### Payment date must not be before order date

```sql
SELECT p.*
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
WHERE p.payment_date < o.order_date;
```

---

# Business Analytics Problems Solved

This project solves **20 real-world business problems using SQL.**

---

# Sales & Revenue Analysis

1. Top 10 selling products by revenue  
2. Revenue contribution by product category  
3. Customer average order value  
4. Monthly sales trend analysis  

---

# Customer Analytics

5. Customers with no purchases  
6. Customer lifetime value ranking  
7. Customer retention within 30 days  
8. Customer purchase behavior  

---

# Seller Performance

9. Top performing sellers  
10. Seller successful order ratio  
11. Sellers inactive for the last 4 months  

---

# Product & Inventory Insights

12. Products with low stock levels  
13. Profit margin by product  
14. Products with highest return rate  

---

# Logistics & Operations

15. Orders shipped later than 7 days  
16. Revenue handled by each shipping provider  
17. Average delivery time per provider  

---

# Advanced Analytics

18. Year-over-year revenue decrease analysis  
19. Customer repeat purchases within 30 days  
20. Product cross-selling analysis  

---

# Advanced SQL Concepts Used

This project demonstrates several **professional SQL techniques**:

### Window Functions

- `RANK()`
- `DENSE_RANK()`
- `LAG()`
- `LEAD()`

### Common Table Expressions (CTEs)

Used to break complex problems into readable steps.

### Aggregations

- SUM
- COUNT
- AVG
- Conditional Aggregations

### Complex Joins

- Inner joins
- Left joins
- Self joins

### Business KPI Calculations

- Revenue
- Customer Lifetime Value
- Return Rate
- Profit Margin
- Sales Growth

---

# Skills Demonstrated

This project highlights the following data analytics skills:

- Data Modeling
- PostgreSQL Database Design
- SQL Data Analysis
- Data Cleaning
- Business Intelligence Thinking
- Analytical Problem Solving
- Query Optimization

---

# Tools Used

- PostgreSQL
- SQL
- pgAdmin
- Power BI (for dashboard development)

---

# Future Improvements

Potential improvements for this project:

- Build a **Power BI dashboard**
- Add **customer segmentation analysis**
- Implement **demand forecasting using machine learning**
- Create an **automated ETL pipeline**

---

# Author

**Vishva Suraj**

Aspiring **Data Analyst / BI Developer**
