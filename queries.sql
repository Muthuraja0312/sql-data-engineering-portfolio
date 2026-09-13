-- ============================================================
-- SQL Portfolio Project
--In this file I put all the queries from basic to advanced
-- Run schema_and_data.sql first to create tabes and feed data.
-- Sections:
--   1. Basic SELECT / filtering
--   2. Sorting & limiting
--   3. Aggregation (GROUP BY / HAVING)
--   4. Joins
--   5. Subqueries
--   6. CTEs
--   7. Window functions
--   8. Views & misc
-- ============================================================


-- 1. BASIC SELECT / FILTERING

-- 1.1 everything from a table
SELECT * FROM employees;

-- 1.2 just the columns we care about
SELECT first_name, last_name, job_title
FROM employees;

-- 1.3 filter with WHERE
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 60000;

-- 1.4 more than one condition
SELECT first_name, last_name, department_id, salary
FROM employees
WHERE department_id = 2 AND salary >= 60000;

-- 1.5 pattern matching with LIKE
SELECT first_name, last_name
FROM employees
WHERE last_name LIKE 'K%';

-- 1.6 filtering with IN
SELECT product_name, category, unit_price
FROM products
WHERE category IN ('Electronics', 'Furniture');

-- 1.7 filtering with BETWEEN
SELECT order_id, order_date
FROM orders
WHERE order_date BETWEEN '2023-02-01' AND '2023-03-31';

-- 1.8 handling NULLs - staff with no manager
SELECT first_name, last_name, manager_id
FROM employees
WHERE manager_id IS NULL;


-- 2. SORTING & LIMITING

-- 2.1 sort by one column
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC;

-- 2.2 sort by more than one column
SELECT department_id, last_name, salary
FROM employees
ORDER BY department_id ASC, salary DESC;

-- 2.3 top 3 highest paid employees
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- 2.4 unique category names
SELECT DISTINCT category
FROM products;


-- 3. AGGREGATION (GROUP BY / HAVING)

-- 3.1 headcount per department
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;

-- 3.2 average salary per department
SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department_id
ORDER BY avg_salary DESC;

-- 3.3 revenue per order
SELECT order_id, SUM(quantity * unit_price) AS order_total
FROM order_items
GROUP BY order_id
ORDER BY order_id;

-- 3.4 HAVING filters on the aggregated value, not the raw rows
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 3;

-- 3.5 a few aggregates together
SELECT
    department_id,
    COUNT(*) AS headcount,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    ROUND(AVG(salary),2) AS avg_salary
FROM employees
GROUP BY department_id;


-- 4. JOINS

-- 4.1 employees with their department name
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- 4.2 every department, even ones with no employees yet
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;

-- 4.3 full order detail across four tables
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name) AS sold_by,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN employees e    ON o.employee_id = e.employee_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
ORDER BY o.order_id;

-- 4.4 self join - who reports to who
SELECT
    CONCAT(emp.first_name, ' ', emp.last_name) AS employee,
    CONCAT(mgr.first_name, ' ', mgr.last_name) AS manager
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY manager;

-- 4.5 customers who've never actually ordered anything
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 5. SUBQUERIES

-- 5.1 employees earning above the company average
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 5.2 subquery used as a derived table
SELECT *
FROM (
    SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY department_id
) dept_avg
WHERE avg_salary > 50000;

-- 5.3 correlated subquery - top earner in each department
SELECT e1.first_name, e1.last_name, e1.department_id, e1.salary
FROM employees e1
WHERE e1.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
);

-- 5.4 EXISTS - customers who placed at least one order
SELECT c.first_name, c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

-- 5.5 products that have never sold
SELECT product_name
FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);


-- 6. CTEs

-- 6.1 basic CTE - orders worth more than £100
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
)
SELECT *
FROM order_totals
WHERE order_total > 100
ORDER BY order_total DESC;

-- 6.2 CTE joined back to another table - lifetime value per customer
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS order_total
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT c.first_name, c.last_name, SUM(ot.order_total) AS lifetime_value
FROM order_totals ot
JOIN customers c ON ot.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY lifetime_value DESC;

-- 6.3 two CTEs chained together - who's paid above their dept average
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
),
above_avg_employees AS (
    SELECT e.employee_id, e.first_name, e.last_name, e.department_id, e.salary
    FROM employees e
    JOIN dept_avg d ON e.department_id = d.department_id
    WHERE e.salary > d.avg_salary
)
SELECT * FROM above_avg_employees;

-- 6.4 recursive CTE - walk up Harry Okafor's management chain
WITH RECURSIVE reporting_chain AS (
    SELECT employee_id, first_name, last_name, manager_id, 1 AS level
    FROM employees
    WHERE employee_id = 8   -- Harry Okafor

    UNION ALL

    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, rc.level + 1
    FROM employees e
    JOIN reporting_chain rc ON e.employee_id = rc.manager_id
)
SELECT * FROM reporting_chain;


-- 7. WINDOW FUNCTIONS

-- 7.1 rank salary within each department
SELECT
    department_id,
    first_name,
    last_name,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num
FROM employees;

-- 7.2 RANK vs DENSE_RANK when there are ties
SELECT
    department_id,
    first_name,
    last_name,
    salary,
    RANK()       OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_dense_rank
FROM employees;

-- 7.3 top 2 earners per department (window function inside a CTE)
WITH ranked AS (
    SELECT
        department_id, first_name, last_name, salary,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT * FROM ranked WHERE rn <= 2;

-- 7.4 running total of revenue by order date
SELECT
    o.order_date,
    o.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_total,
    SUM(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY o.order_date, o.order_id) AS running_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_date, o.order_id
ORDER BY o.order_date, o.order_id;

-- 7.5 LAG / LEAD - compare each employee's salary to the next hire's
SELECT
    first_name,
    last_name,
    hire_date,
    salary,
    LAG(salary)  OVER (ORDER BY hire_date) AS prev_hire_salary,
    LEAD(salary) OVER (ORDER BY hire_date) AS next_hire_salary
FROM employees
ORDER BY hire_date;

-- 7.6 NTILE - split employees into 4 salary quartiles
SELECT
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile
FROM employees;

-- 7.7 3-order rolling average of order value per customer
SELECT
    customer_id,
    order_id,
    order_total,
    ROUND(AVG(order_total) OVER (
        PARTITION BY customer_id
        ORDER BY order_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_avg_3
FROM (
    SELECT o.customer_id, o.order_id, SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
) order_totals
ORDER BY customer_id, order_id;

-- 7.8 PERCENT_RANK / CUME_DIST - where each product sits price-wise
SELECT
    product_name,
    unit_price,
    ROUND(PERCENT_RANK() OVER (ORDER BY unit_price), 2) AS percent_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY unit_price), 2) AS cume_dist
FROM products;

-- 7.9 FIRST_VALUE - cheapest and priciest product per category
SELECT DISTINCT
    category,
    FIRST_VALUE(product_name) OVER (
        PARTITION BY category ORDER BY unit_price ASC
    ) AS cheapest_in_category,
    FIRST_VALUE(product_name) OVER (
        PARTITION BY category ORDER BY unit_price DESC
    ) AS priciest_in_category
FROM products;


-- 8. VIEWS

-- 8.1 a reusable view for order revenue
CREATE OR REPLACE VIEW vw_order_revenue AS
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(oi.quantity * oi.unit_price)       AS order_total
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
GROUP BY o.order_id, o.order_date, customer_name;

-- query the view like a normal table
SELECT * FROM vw_order_revenue ORDER BY order_total DESC;

-- 8.2 CASE - bucket employees into salary bands
SELECT
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 80000 THEN 'Senior'
        WHEN salary >= 50000 THEN 'Mid'
        ELSE 'Junior'
    END AS salary_band
FROM employees;

-- 8.3 COALESCE - default label for staff with no manager
SELECT
    first_name,
    last_name,
    COALESCE(
        (SELECT mgr.first_name FROM employees mgr WHERE mgr.employee_id = e.manager_id),
        'No Manager'
    ) AS manager_name
FROM employees e;

-- 8.4 UNION - combine customers and employees into one contact list
SELECT first_name, last_name, 'CUSTOMER' AS person_type FROM customers
UNION
SELECT first_name, last_name, 'EMPLOYEE' AS person_type FROM employees
ORDER BY last_name;
