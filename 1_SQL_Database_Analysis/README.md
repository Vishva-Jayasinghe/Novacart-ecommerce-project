[sql_project_readme.md](https://github.com/user-attachments/files/25873747/sql_project_readme.md)
# Novacart E-commerce Data Analytics Project -- SQL Database & Analysis

## Project Overview

This project represents the **first phase of an end‑to‑end data
analytics project** built using a simulated **e‑commerce business
dataset**.\
The focus of this phase is designing a relational database, cleaning the
data, and preparing it for further analytics and business intelligence.

The project models a fictional online store **Novacart**, covering the
full lifecycle of customer orders including:

-   Customers
-   Sellers
-   Products
-   Orders
-   Payments
-   Shipping
-   Inventory

This database serves as the **foundation for later stages**, where the
cleaned data will be used in:

-   Power BI dashboards
-   Machine Learning models

------------------------------------------------------------------------

# Database Schema

The database follows a **normalized relational schema** connecting
customers, products, and orders.

### Main Entities

-   **Customers** -- Stores customer personal information.
-   **Sellers** -- Represents sellers or suppliers.
-   **Products** -- Catalog of products with price and category.
-   **Category** -- Product categories.
-   **Orders** -- Records customer purchases.
-   **Order Items** -- Individual products inside each order.
-   **Payments** -- Payment status of orders.
-   **Shipping** -- Shipping and delivery details.
-   **Inventory** -- Product stock levels in warehouses.

### Entity Relationship Diagram

Add the ER diagram image in this folder and reference it here:

    /1_SQL_Database_Analysis/erd.png

------------------------------------------------------------------------

# Database Tables

## Category Table

Stores product categories.

  Column          Description
  --------------- -------------------
  category_id     Unique identifier
  category_name   Category name

## Customers Table

  Column        Description
  ------------- ---------------------
  customer_id   Unique customer ID
  first_name    Customer first name
  last_name     Customer last name
  state         Customer state

## Sellers Table

  Column      Description
  ----------- ------------------------
  seller_id   Unique seller ID
  name        Seller name
  origin      Seller origin location

## Products Table

  Column         Description
  -------------- -------------------------
  product_id     Unique product ID
  product_name   Name of product
  price          Product selling price
  cogs           Cost of goods sold
  category_id    Foreign key to category

## Orders Table

  Column         Description
  -------------- -------------------------
  order_id       Unique order ID
  order_date     Date order placed
  customer_id    Customer placing order
  seller_id      Seller fulfilling order
  order_status   Status of order

## Order Items Table

  Column           Description
  ---------------- --------------------
  order_item_id    Unique order item
  order_id         Associated order
  product_id       Purchased product
  quantity         Quantity purchased
  price_per_unit   Price per unit

## Payments Table

  Column           Description
  ---------------- --------------------
  payment_id       Payment identifier
  order_id         Related order
  payment_date     Date payment made
  payment_status   Payment result

## Shipping Table

  Column              Description
  ------------------- ---------------------------
  shipping_id         Shipping ID
  order_id            Order being shipped
  shipping_provider   Delivery provider
  ship_date           Shipping date
  delivery_date       Delivery date
  shipping_status     Delivered / Returned
  return_date         Return date if applicable

## Inventory Table

  Column            Description
  ----------------- ----------------------
  inventory_id      Inventory record
  product_id        Product reference
  stock_remaining   Current stock
  warehouse_id      Warehouse identifier
  re_stock_date     Last restock date

------------------------------------------------------------------------

# Data Cleaning Process

The dataset required several preprocessing steps to ensure **data
consistency and reliability**.

### Payment Status Standardization

Different values were unified into consistent categories:

Original values: - pending - payment_failed - payment_success

Standardized values: - refunded - failed - success

------------------------------------------------------------------------

### Duplicate Removal

Duplicate shipping and order records were removed using PostgreSQL
system column **ctid**.

------------------------------------------------------------------------

### Shipping Status Normalization

Shipping status values were standardized into two categories:

-   delivered
-   returned

Returned orders were simulated using a random distribution to represent
approximately **7% return rate**.

------------------------------------------------------------------------

### Return Date Generation

A **return_date column** was added and populated only for returned
orders.

    ALTER TABLE shipping
    ADD COLUMN return_date DATE;

Returned orders received a randomly generated return date based on
delivery date.

------------------------------------------------------------------------

### Data Validation Checks

Several checks were performed to ensure data integrity.

#### Delivery cannot occur before shipping

    SELECT *
    FROM shipping
    WHERE delivery_date < ship_date;

#### Payments cannot occur before order date

    SELECT *
    FROM payments p
    JOIN orders o
    ON p.order_id = o.order_id
    WHERE p.payment_date < o.order_date;

Any invalid values were corrected accordingly.

------------------------------------------------------------------------

# Data Integrity Improvements

To maintain relational integrity:

-   Foreign key constraints were enforced.
-   Cascading deletes were implemented.

Example:

    ALTER TABLE shipping
    ADD CONSTRAINT shipping_order_fk
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE;

This ensures that when an order is deleted, its associated shipping
records are also removed.

------------------------------------------------------------------------

# Technologies Used

-   SQL
-   PostgreSQL
-   Relational Database Design
-   Data Cleaning Techniques

------------------------------------------------------------------------

# Project Structure

    Novacart-ecommerce-project
    │
    ├── 1_SQL_Database_Analysis
    │   ├── database_schema.sql
    │   ├── data_cleaning.sql
    │   ├── business_queries.sql
    │   ├── erd.png
    │   └── README.md
    │
    ├── 2_PowerBI_Dashboard
    │
    └── 3_Machine_Learning

------------------------------------------------------------------------

# Next Steps

This SQL database will be used for the next stages of the project:

### Phase 2 -- Business Intelligence

Building **interactive dashboards in Power BI** to analyze:

-   Sales performance
-   Customer behavior
-   Product performance
-   Return trends

### Phase 3 -- Machine Learning

Applying predictive models for:

-   Customer segmentation
-   Sales forecasting
-   Product demand prediction

------------------------------------------------------------------------

# Author

**Vishva Jayasinghe**\
Data Analytics Enthusiast
