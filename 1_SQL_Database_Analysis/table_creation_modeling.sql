--
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
category_id INT,  --FK
CONSTRAINT product_fk_category 
FOREIGN KEY(category_id)
REFERENCES category(category_id)

);


--orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT,--FK
seller_id INT, --FK
order_status VARCHAR(50),
CONSTRAINT orders_customers_fk
FOREIGN KEY(customer_id)
REFERENCES customers(customer_id),
CONSTRAINT sellers_orders_fk
FOREIGN KEY(seller_id)
REFERENCES sellers(seller_id)
);



--order_items_table
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
order_item_id INT PRIMARY KEY,
order_id INT, --FK
product_id INT, --FK
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
order_id INT, --FK
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
order_id INT, --FK
shipping_provider VARCHAR(50),
ship_date DATE,
delivery_date DATE,
shipping_status VARCHAR(50),
CONSTRAINT shipping_order_fk
FOREIGN KEY(order_id)
REFERENCES orders(order_id)
);

---inventory table
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory(
inventory_id INT PRIMARY KEY,
product_id INT, --FK
stock_remaining INT,
warehouse_id INT,
re_stock_date DATE,
CONSTRAINT inventory_products_fk
FOREIGN KEY(product_id)
REFERENCES products(product_id)
);

SELECT * FROM category
SELECT * FROM customers
SELECT * FROM inventory
SELECT * FROM order_items
SELECT * FROM orders
SELECT * FROM payments
SELECT * FROM products
SELECT * FROM sellers
SELECT * FROM shipping



