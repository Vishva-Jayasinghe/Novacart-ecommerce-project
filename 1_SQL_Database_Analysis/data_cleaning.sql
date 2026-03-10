--Data cleaning
--update the payments methods
UPDATE payments
SET payment_status = 'refunded'
WHERE payment_status = 'pending';

UPDATE payments
SET payment_status = 'failed'
WHERE payment_status = 'payment_failed';

UPDATE payments
SET payment_status = 'success'
WHERE payment_status = 'payment_success';

SELECT DISTINCT payment_status
FROM payments
--products table

SELECT DISTINCT product_name
FROM products

--shipping table

--Remove duplicates
SELECT shipping_id, COUNT(*)
FROM shipping
GROUP BY shipping_id
HAVING COUNT(*) > 1;

--If duplicates exist:

DELETE FROM shipping
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM shipping
    GROUP BY shipping_id
);


--we need to add a return date with some random return dates
ALTER TABLE shipping
ADD COLUMN return_date DATE;


UPDATE shipping
SET shipping_status = 'delivered'
WHERE shipping_status IN ('in_transit','shipped');


UPDATE shipping
SET shipping_status = 'returned'
WHERE random() < 0.07;

UPDATE shipping
SET return_date = delivery_date + (floor(random()*10)+1)::int
WHERE shipping_status = 'returned';


UPDATE shipping
SET return_date = NULL
WHERE shipping_status = 'delivered';

--validate date logic
--Delivery cannot happen before shipping.

SELECT *
FROM shipping
WHERE delivery_date < ship_date;

--no issues found

--Payments table


--Find orders without payments

SELECT o.order_id
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

--fix
ALTER TABLE shipping
DROP CONSTRAINT shipping_order_fk;

ALTER TABLE shipping
ADD CONSTRAINT shipping_order_fk
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;


DELETE FROM orders WHERE order_id = 7;

--foriegn keys
ALTER TABLE payments
ADD CONSTRAINT payments_order_fk
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;
--Check Payments Without Orders (Integrity Test)
SELECT *
FROM payments
WHERE order_id NOT IN (
    SELECT order_id FROM orders
);

--no issues
--Payment should not be before order date.

SELECT p.*
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
WHERE p.payment_date < o.order_date;

--fix
UPDATE payments p
SET payment_date = o.order_date
FROM orders o
WHERE p.order_id = o.order_id
AND p.payment_date < o.order_date;

--Orders Table
--Remove duplicates
DELETE FROM orders
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM orders
    GROUP BY order_id
);
--Validate order date
SELECT *
FROM orders
WHERE order_date > CURRENT_DATE;
--no issues found


