-- unique values from columns 
SELECT DISTINCT column_name FROM table_name;

-- find 2nd highest salary from salary column
SELECT MAX(salary)
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- fetching duplicate rows
SELECT column_name, COUNT(*)
FROM table_name
GROUP BY column_name
HAVING COUNT(*) > 1;

-- calculate total salary of employees
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id;

-- use like function to find a column value starting with particular alphabet or word
SELECT *
FROM employees
WHERE name LIKE 'A%'

-- fetch records with null values
SELECT *
FROM table_name
WHERE column_name IS NULL;

SELECT name,
       CASE
            WHEN salary > 5000 THEN 'High'
            ELSE 'Low'
       END AS salary_category
FROM employees;


-- calc avg salary
SELECT AVG(salary)
FROM employees;

-- using window function to calc running total of salaries
SELECT name, salary,
        SUM(salary) OVER (ORDER BY salary) AS running_total
FROM employees;

-- common  table expression
WITH EmployeeCTE AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT * FROM EmployeeCTE;

-- handle duplicate rows
SELECT DISTINCT * 
FROM table_name;

-- identify nth row
 SELECT *
 FROM employees
 ORDER BY salary DESC
 OFFSET n-1 ROWS FETCH NEXT 1 ROW ONLY;

-- join three tables
SELECT e.employee_id, e.name AS employee_name, d.department_name, s.salary
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN salaries s ON e.employee_id = s.employee_id;

-- left join example
SELECT e.employee_id, e.name AS employee_name, d.department_name, s.salary
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN salaries s ON e.employee_id = s.employee_id;


-- creating index for faster data retrieval

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    hire_date DATE
);
-- creating index on single column
CREATE INDEX idx_last_name ON employees(last_name);

-- query using index
SELECT * FROM employees WHERE last_name = 'Smith';

-- creating composite index
CREATE INDEX idx_name ON employees(last_name, first_name);


SELECT * FROM employees WHERE last_name = 'Smith' AND first_name = 'John'

-- unique index
CREATE INDEX idx_email ON employees(email);
-- This index will enforce the rule that no two employees can have the same email address.

-- subquery in WHERE Clause
SELECT employee_id , first_name, last_name
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM departments
    ORDER BY average_salary DESC
    LIMIT 1
);

-- subquery in SELECT Clause
SELECT first_name, last_name, salary,
    (SELECT MAX(salary) FROM employees e2 WHERE e2.department_id = e1.department_id) AS highest_salary_in_department
FROM employees e1;

-- Correlated Subquery
-- A correlated subquery is a subquery that references a column from the outer query.
-- It’s evaluated for each row returned by the outer query.

SELECT first_name, last_name, salary
FROM employees e1
WHERE salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e1.department_id = e2.department_id
);

-- subquery in the FROM Clause
-- Sometimes you need to treat the result of a subquery as a derived table.
SELECT department_id, AVG(salary) AS avg_salary
FROM (
    SELECT department_id, salary
    FROM employees
) AS dept_salaries
GROUP BY department_id;

-- SQL query to find employe salary which is greater than avg salary
SELECT employee_id,
       employee_name,
       salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- application of COALESCE function to handle nulls

SELECT employee_name, COALESCE(bonus, 0)  AS bonus
FROM employees;

-- handling multiple potential nulls:
SELECT order_id, COALESCE(delivery_date, shipment_date, order_date) AS actual_delivery_date
FROM orders;

-- string concatenation
SELECT first_name || ' '|| COALESCE(middle_name, '') || ' ' || last_name AS full_name
FROM employees;

-- Query with COALESCE
SELECT employee_id,
       COALESCE(phone_number, 'Not Available') AS contact_number
FROM employees;

-- PERFORMANCE OPTIMIZATION (to reducte execution time)
CREATE INDEX idx_salary ON employees(salary);

SELECT employee_id, employee_name, salary 
FROM employees
WHERE salary > 50000;

-- SELF JOIN
SELECT e1.employee_id, e1.employee_name, e2.employee_name AS manager
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.employee_id;

-- CROSS JOIN:
-- Returns the Cartesian product of two tables. 
-- Each row from the first table is combined with each row from the second table.
SELECT a.product_id, b.customer_id
FROM products a
CROSS JOIN customers b;

-- Naturan Join
-- A natural join automatically joins tables based on columns with the same name and data type.
SELECT employee_id, employee_name, department_name
FROM employees
NATURAL JOIN departments;


-- ( DATA TRANSFORMATION)

-- USING CASE for Conditional Aggregations:
SELECT department_id,
       COUNT(CASE WHEN salary > 50000 THEN 1 END) AS high_earners,
       COUNT(CASE WHEN salary < 50000 THEn 1 END) AS low_earners
FROM employees
GROUP BY department_id;

-- String Manipulation ( CONCAT, SUBSTRING):
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;

SELECT SUBSTRING(email, 1, 10) AS email_prefix
FROM employees;

-- ( DATA MANIPULATION )

SELECT EXTRACT(YEAR FROM hire_date) AS hire_year
FROM employees;

SELECT TO_CHAR(hire_date, 'YYYY-MM-DD') AS formatted_hire_date
FROM employees;

-- WORKING WITH NULL Values
SELECT employee_id, COALESCE(phone_number, 'Not Provided') AS contact_info
FROM employees;

-- Replace null value in SQL Server
SELECT employee_id, ISNULL(phone_number, 'No Phone') AS contact_number
FROM employees;

-- ( Aggregate Functions & Grouping )
-- use HAVING after GROUPING
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 60000;

-- Multiple Aggregations:
SELECT department_id,
       COUNT(employee_id) AS num_employees,
       SUM(salary) AS total_salary,
       AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;

-- Window Functions
-- Generate sequential numbers or ranks for rows within a partition of a result set.
SELECT employee_id, department_id, salary,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS ranks
FROM employees;

-- RANK and DENSE_RANK
SELECT employee_id, salary, RANK() OVER (ORDER BY salary DESC) AS rank
FROM employees;

-- Transactions and Locks

BEGIN;

INSERT INTO employees (employee_id, employee_name, salary)
VALUES (1001, 'John Doe', 75000);

COMMIT;

-- LOCK TABLE:
-- Lock a table to prevent it from being modified by other transactions until your transaction completes.
LOCK TABLE employees IN EXCLUSIVE MODE;


-- Data Modeling Relationships
-- Establish relationships between tables using foreign keys.

-- One-to-Many Relationship

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Many-to-Many Relationship
CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id)  REFERENCES projects(project_id)
);

-- Temporary Table
CREATE TEMPORARY TABLE temp_employees AS 
SELECT * FROM employees WHERE department_id = 1;

-- Common Table Expressions (CTEs)
-- A CTE simplifies complex queries by defining intermediate result sets.

WITH avg_salary AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.employee_id, e.employee_name, a.avg_salary
FROM employees e
JOIN avg_salary a ON e.department_id = a.department_id;



-- FULL OUTER JOIN

SELECT e.employee_id, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id;

-- Nested Subquery for Data Aggregation:
SELECT employee_id, employee_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
