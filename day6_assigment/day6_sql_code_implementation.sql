
-- ==========================================
-- HEXAWARE DAY 6 - SET 1
-- RETAIL SALES REPORTING
-- MYSQL 8.4
-- ==========================================

-- COMMAND: CREATE DATABASE
CREATE DATABASE IF NOT EXISTS RetailDB;

-- COMMAND: USE DATABASE
USE RetailDB;


-- ==========================================
-- TASK 0: CREATE TABLES
-- COMMAND: CREATE TABLE
-- ==========================================

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;


-- 1. CUSTOMERS TABLE

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30),
    email VARCHAR(100)
);


-- 2. PRODUCTS TABLE

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(10,2)
);


-- 3. ORDERS TABLE

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);


-- 4. ORDER_ITEMS TABLE

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);


-- 5. PAYMENTS TABLE

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
);


-- ==========================================
-- TASK 0.1: INSERT SAMPLE DATA
-- COMMAND: INSERT INTO
-- ==========================================


-- INSERT CUSTOMERS

INSERT INTO customers VALUES
(1, 'Alice', 'Chennai', 'alice@gmail.com'),
(2, 'Bob', 'Mumbai', 'bob@gmail.com'),
(3, 'Carol', 'Chennai', 'carol@gmail.com'),
(4, 'David', 'Delhi', 'david@gmail.com'),
(5, 'Eva', 'Mumbai', 'eva@gmail.com');


-- INSERT PRODUCTS

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 50000),
(102, 'Mouse', 'Electronics', 1000),
(103, 'Chair', 'Furniture', 5000),
(104, 'Desk', 'Furniture', 10000);


-- INSERT ORDERS

INSERT INTO orders VALUES
(201, 1, '2026-01-05'),
(202, 1, '2026-01-10'),
(203, 1, '2026-02-02'),
(204, 1, '2026-02-15'),
(205, 2, '2026-01-12'),
(206, 2, '2026-02-20'),
(207, 3, '2026-02-20');


-- INSERT ORDER ITEMS

INSERT INTO order_items VALUES
(1, 201, 101, 1),
(2, 201, 102, 2),
(3, 202, 103, 1),
(4, 202, 104, 1),
(5, 203, 102, 3),
(6, 204, 101, 1),
(7, 205, 104, 2),
(8, 206, 103, 2),
(9, 207, 102, 1),
(10, 207, 103, 1);


-- INSERT PAYMENTS

INSERT INTO payments VALUES
(1, 201, 52000, '2026-01-05'),
(2, 202, 15000, '2026-01-10'),
(3, 204, 50000, '2026-02-15'),
(4, 205, 20000, '2026-01-12'),
(5, 207, 6000, '2026-02-20');


-- ==========================================
-- DISPLAY ALL TABLES
-- COMMAND: SELECT *
-- ==========================================

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;


-- ==========================================
-- TASK 1: TOP 5 PRODUCTS BY REVENUE
-- COMMANDS: INNER JOIN, SUM, GROUP BY,
-- ORDER BY, LIMIT
-- ==========================================

SELECT
    p.product_name,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


-- ==========================================
-- TASK 2: MONTH-WISE SALES
-- COMMANDS: INNER JOIN, DATE_FORMAT,
-- SUM, ROUND, GROUP BY, ORDER BY
-- ==========================================

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(oi.quantity * p.price), 2) AS monthly_sales
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;


-- ==========================================
-- TASK 3: CUSTOMERS WITH MORE THAN
-- THREE ORDERS
-- COMMANDS: INNER JOIN, COUNT,
-- GROUP BY, HAVING, UPPER
-- ==========================================

SELECT
    UPPER(c.customer_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 3;


-- ==========================================
-- TASK 4: AVERAGE BASKET VALUE PER CITY
-- COMMANDS: INNER JOIN, SUM, AVG,
-- ROUND, GROUP BY
-- ==========================================

SELECT
    c.city,
    ROUND(AVG(ot.order_value), 2) AS average_basket_value
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN (
    SELECT
        oi.order_id,
        SUM(oi.quantity * p.price) AS order_value
    FROM order_items oi
    INNER JOIN products p
    ON oi.product_id = p.product_id
    GROUP BY oi.order_id
) ot
ON o.order_id = ot.order_id
GROUP BY c.city;


-- ==========================================
-- TASK 5: ORDERS WITHOUT PAYMENT
-- COMMANDS: LEFT JOIN, INNER JOIN,
-- WHERE, IS NULL
-- ==========================================

SELECT
    o.order_id,
    o.order_date,
    c.customer_name
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id
INNER JOIN customers c
ON o.customer_id = c.customer_id
WHERE p.payment_id IS NULL;


-- ==========================================
-- TASK 6: CUSTOMERS WITH NO ORDERS
-- COMMANDS: LEFT JOIN, WHERE, IS NULL
-- ==========================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ==========================================
-- TASK 7: PRODUCT CATEGORY REVENUE SHARE
-- COMMANDS: INNER JOIN, SUM, ROUND,
-- GROUP BY, SUBQUERY
-- ==========================================

SELECT
    p.category,
    SUM(oi.quantity * p.price) AS category_revenue,
    ROUND(
        SUM(oi.quantity * p.price) * 100 /
        (
            SELECT SUM(oi2.quantity * p2.price)
            FROM order_items oi2
            INNER JOIN products p2
            ON oi2.product_id = p2.product_id
        ), 2
    ) AS revenue_percentage
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category;


-- ==========================================
-- TASK 8: DAY WITH HIGHEST SALES
-- COMMANDS: INNER JOIN, SUM, GROUP BY,
-- ORDER BY, LIMIT
-- ==========================================

SELECT
    o.order_date,
    SUM(oi.quantity * p.price) AS daily_sales
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY daily_sales DESC
LIMIT 1;


-- ==========================================
-- TASK 9: STRING, DATE AND MATHEMATICAL
-- FUNCTIONS
-- COMMANDS: UPPER, CONCAT, DATEDIFF,
-- DATE_FORMAT, ROUND
-- ==========================================

SELECT
    UPPER(c.customer_name) AS customer_name,
    CONCAT(c.customer_name, ' - ', c.city)
        AS customer_details,
    DATEDIFF('2026-03-01', o.order_date)
        AS days_difference,
    DATE_FORMAT(o.order_date, '%d-%m-%Y')
        AS formatted_date,
    ROUND(p.price, 0)
        AS rounded_price
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id;


-- ==========================================
-- TASK 10: DEMONSTRATE NULL BEHAVIOUR
-- COMMANDS: COUNT(*), COUNT(COLUMN),
-- SUM, AVG, LEFT JOIN, GROUP BY
-- ==========================================

SELECT
    c.customer_name,
    COUNT(*) AS total_rows,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_quantity,
    AVG(oi.quantity) AS average_quantity
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
LEFT JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;


-- ==========================================
-- TASK 10.1: REPLACE NULL WITH ZERO
-- COMMAND: COALESCE
-- ==========================================

SELECT
    c.customer_name,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity,
    COALESCE(AVG(oi.quantity), 0) AS average_quantity
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
LEFT JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;


-- ==========================================
-- TASK 11: WHERE VS HAVING
-- ==========================================


-- WHERE COMMAND:
-- Filters rows BEFORE GROUP BY

SELECT
    customer_id,
    COUNT(*) AS february_orders
FROM orders
WHERE MONTH(order_date) = 2
GROUP BY customer_id;


-- HAVING COMMAND:
-- Filters groups AFTER GROUP BY

SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 3;


-- ==========================================
-- END OF HEXAWARE DAY 6 SET 1
-- ==========================================
