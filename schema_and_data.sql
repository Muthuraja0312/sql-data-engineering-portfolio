-- ============================================================
-- SQL Portfolio Project
-- In this file i put all the queries to create table and insert data to practice queries.
-- Engine: MySQL 8.0+
-- Theme: a small company that sells office/electronics gear.
-- Six tables: departments, employees, customers, products,
-- orders, order_items.
-- ============================================================

-- start clean, drop child tables first so FKs don't complain
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;


-- departments
CREATE TABLE departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location        VARCHAR(50)
);


-- employees
-- manager_id points back at employees.employee_id, so we can
-- do self-joins / org-chart type queries later 

CREATE TABLE employees (
    employee_id     INT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    department_id   INT,
    manager_id      INT,
    job_title       VARCHAR(50),
    salary          DECIMAL(10,2) NOT NULL,
    hire_date       DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- customers
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    country         VARCHAR(50),
    signup_date     DATE NOT NULL
);

-- products
CREATE TABLE products (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50),
    unit_price      DECIMAL(10,2) NOT NULL
);

-- orders
CREATE TABLE orders (
    order_id        INT PRIMARY KEY,
    customer_id     INT,
    employee_id     INT,
    order_date      DATE NOT NULL,
    status          VARCHAR(20) DEFAULT 'COMPLETED',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- order_items
-- line items for an order - what was bought, how many, at
-- what price (kept separate from products.unit_price in case
-- prices change later - this is the price at time of sale)
CREATE TABLE order_items (
    order_item_id   INT PRIMARY KEY,
    order_id        INT,
    product_id      INT,
    quantity        INT NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- sample data

INSERT INTO departments (department_id, department_name, location) VALUES
(1, 'Sales',        'London'),
(2, 'Engineering',  'Manchester'),
(3, 'Marketing',    'London'),
(4, 'HR',           'Birmingham'),
(5, 'Finance',      'London');

-- manager_id is NULL for people at the top of the chain
INSERT INTO employees (employee_id, first_name, last_name, department_id, manager_id, job_title, salary, hire_date) VALUES
(1,  'Alice',   'Turner',   5, NULL, 'CFO',                95000, '2015-01-10'),
(2,  'Brian',   'Ogundele', 1, NULL, 'Head of Sales',       88000, '2016-03-14'),
(3,  'Carla',   'Nguyen',   2, NULL, 'Engineering Manager', 92000, '2015-07-01'),
(4,  'Daniel',  'Kowalski', 1, 2,    'Sales Executive',     45000, '2019-05-19'),
(5,  'Ella',    'Fischer',  1, 2,    'Sales Executive',     47000, '2020-02-11'),
(6,  'Farid',   'Hassan',   2, 3,    'Software Engineer',   62000, '2018-09-23'),
(7,  'Grace',   'Lindqvist',2, 3,    'Software Engineer',   64000, '2019-11-05'),
(8,  'Harry',   'Okafor',   2, 3,    'Junior Developer',    38000, '2022-01-17'),
(9,  'Isla',    'Bianchi',  3, NULL, 'Marketing Manager',   58000, '2017-04-09'),
(10, 'Jacek',   'Nowak',    3, 9,    'Marketing Executive',  36000, '2021-06-21'),
(11, 'Katia',   'Petrova',  4, NULL, 'HR Manager',          54000, '2016-08-30'),
(12, 'Liam',    'Byrne',    1, 2,    'Sales Executive',     46000, '2021-10-04'),
(13, 'Maya',    'Sundaram', 5, 1,    'Financial Analyst',   50000, '2020-07-13'),
(14, 'Noah',    'Kessler',  2, 3,    'Software Engineer',   63000, '2020-01-27'),
(15, 'Olga',    'Ivanova',  4, 11,   'HR Executive',        34000, '2022-03-02');

INSERT INTO customers (customer_id, first_name, last_name, email, country, signup_date) VALUES
(1,  'Sophie',  'Marsh',    'sophie.marsh@example.com',    'UK',      '2021-01-15'),
(2,  'Tom',     'Reilly',   'tom.reilly@example.com',      'UK',      '2021-02-20'),
(3,  'Uma',     'Shankar',  'uma.shankar@example.com',     'India',   '2021-03-05'),
(4,  'Victor',  'Alonso',   'victor.alonso@example.com',   'Spain',   '2021-04-18'),
(5,  'Wanjiru', 'Kamau',    'wanjiru.kamau@example.com',   'Kenya',   '2021-05-30'),
(6,  'Xin',     'Zhao',     'xin.zhao@example.com',        'China',   '2021-06-12'),
(7,  'Yusuf',   'Demir',    'yusuf.demir@example.com',     'Turkey',  '2021-07-25'),
(8,  'Zara',    'Ahmed',    'zara.ahmed@example.com',      'UK',      '2021-08-09'),
(9,  'Aiden',   'Murphy',   'aiden.murphy@example.com',    'Ireland', '2021-09-14'),
(10, 'Bianca',  'Rossi',    'bianca.rossi@example.com',    'Italy',   '2021-10-22');

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
(1,  'Wireless Mouse',        'Electronics', 19.99),
(2,  'Mechanical Keyboard',   'Electronics', 79.99),
(3,  'USB-C Hub',             'Electronics', 34.99),
(4,  '27" Monitor',           'Electronics', 189.99),
(5,  'Standing Desk',         'Furniture',   349.00),
(6,  'Office Chair',          'Furniture',   210.00),
(7,  'Notebook (A5)',         'Stationery',  4.50),
(8,  'Fountain Pen',          'Stationery',  22.00),
(9,  'Desk Lamp',             'Furniture',   28.50),
(10, 'Noise-Cancelling Headphones', 'Electronics', 149.99);

INSERT INTO orders (order_id, customer_id, employee_id, order_date, status) VALUES
(1,  1,  4,  '2023-01-05', 'COMPLETED'),
(2,  2,  5,  '2023-01-11', 'COMPLETED'),
(3,  3,  4,  '2023-01-19', 'COMPLETED'),
(4,  4,  12, '2023-02-02', 'COMPLETED'),
(5,  1,  5,  '2023-02-14', 'COMPLETED'),
(6,  5,  4,  '2023-02-27', 'CANCELLED'),
(7,  6,  12, '2023-03-03', 'COMPLETED'),
(8,  7,  5,  '2023-03-15', 'COMPLETED'),
(9,  2,  4,  '2023-03-28', 'COMPLETED'),
(10, 8,  12, '2023-04-06', 'COMPLETED'),
(11, 9,  5,  '2023-04-19', 'COMPLETED'),
(12, 10, 4,  '2023-05-01', 'COMPLETED'),
(13, 3,  12, '2023-05-14', 'COMPLETED'),
(14, 1,  5,  '2023-05-30', 'COMPLETED'),
(15, 6,  4,  '2023-06-10', 'COMPLETED');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1,  1,  1,  2, 19.99),
(2,  1,  3,  1, 34.99),
(3,  2,  2,  1, 79.99),
(4,  3,  5,  1, 349.00),
(5,  3,  9,  1, 28.50),
(6,  4,  10, 1, 149.99),
(7,  5,  7,  5, 4.50),
(8,  5,  8,  2, 22.00),
(9,  6,  4,  1, 189.99),
(10, 7,  6,  2, 210.00),
(11, 8,  1,  3, 19.99),
(12, 8,  2,  1, 79.99),
(13, 9,  4,  1, 189.99),
(14, 9,  3,  2, 34.99),
(15, 10, 10, 1, 149.99),
(16, 11, 5,  1, 349.00),
(17, 11, 6,  1, 210.00),
(18, 12, 7,  10,4.50),
(19, 13, 2,  2, 79.99),
(20, 13, 1,  1, 19.99),
(21, 14, 9,  2, 28.50),
(22, 15, 10, 2, 149.99),
(23, 15, 3,  1, 34.99);
