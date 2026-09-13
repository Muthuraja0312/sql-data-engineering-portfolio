# SQL Portfolio Project

A small SQL project I put together to practice and show off querying skills,
from plain `SELECT` statements all the way up to window functions. Built on
MySQL (8.0+), but there's nothing exotic in here so it should port to most
other databases without much trouble.

## The database

I made up a simple company that sells office and electronics gear, and
modeled it with 6 tables:

- **departments** – Sales, Engineering, Marketing, HR, Finance
- **employees** – has a `manager_id` that points back to another employee,
  so there's an org chart hiding in there for self-joins / recursive CTEs
- **customers** – people who buy stuff
- **products** – what's for sale
- **orders** – one row per order
- **order_items** – the line items in each order (product, quantity, price)

Roughly:

```
departments -- employees -- orders -- order_items -- products -- customers
```

Nothing fancy, just enough tables and relationships to write realistic
queries against.

## Files

- `schema_and_data.sql` – creates all six tables and loads them with
  around 80 rows of sample data.
- `queries.sql` – the actual query practice, split into sections that go
  roughly from easy to hard:
  1. Basic SELECT / filtering
  2. Sorting and limiting
  3. Aggregation (GROUP BY, HAVING)
  4. Joins – inner, left, self join, and one that pulls from four tables
     at once
  5. Subqueries – scalar, correlated, EXISTS, NOT IN
  6. CTEs, including a recursive one that walks up the reporting chain
  7. Window functions – ROW_NUMBER, RANK/DENSE_RANK, LAG/LEAD, running
     totals, NTILE, a rolling average, PERCENT_RANK, FIRST_VALUE
  8. Views and a few odds and ends (CASE, COALESCE, UNION)

I kept the queries commented so it's clear what each one is actually for,
not just what it does.

## Running it

```bash
mysql -u username -p password < schema_and_data.sql
mysql -u username -p password < queries.sql
```

Or just paste the files into MySQL Workbench / TablePlus / whatever you use
and run them section by section.

Note: the window functions and the recursive CTE need MySQL 8.0 or newer —
they won't work on 5.7.

## Why I built this

I wanted something I could point to that shows I can actually write SQL
beyond textbook examples — real joins across several tables, subqueries
that answer a specific question, and window functions, which come up a lot
in data engineering interviews but rarely get covered properly in tutorials.
Everything here was tested by actually running it against MySQL, not just
written and hoped for the best.
