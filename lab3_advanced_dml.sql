--A
--1
CREATE DATABASE advanced_lab;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    department VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER
);


CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(150),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);
--B
--2
INSERT INTO employees (first_name, last_name, department)
VALUES ('Alice', 'Johnson', 'HR');
--3
ALTER TABLE employees ALTER COLUMN salary SET DEFAULT 10; 
--4
INSERT INTO departments (dept_name, budget, manager_id)
VALUES 
    ('HR', 50000, 1),
    ('IT', 120000, 2),
    ('Finance', 80000, 3);
--5
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Charlie', 'Brown', 'Finance', 50000 * 1.1, CURRENT_DATE);
--6

CREATE TEMP TABLE temp_employees (LIKE employees);

INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

--C
--7
UPDATE employees
SET salary = salary * 1.10;
--8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';
--9
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;
--10

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';
--11
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.2
    FROM employees e
    WHERE e.department = d.dept_name
);
--12

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'IT';
--D
--13
SELECT * FROM employees;
DELETE FROM employees
WHERE status = 'Terminated';
--14
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;
--15
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);
--16
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;
--E
--17
INSERT INTO employees (name, salary, department)
VALUES ('New Employee', NULL, NULL);
--18
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

--19
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;
--F
--20
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Aigerim', 'Smailova', 'HR', 40000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

--21
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

--22
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--G
--23
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Aigerim', 'Smailova', 'HR', 40000
WHERE NOT EXISTS (
    SELECT 1 
    FROM employees 
    WHERE first_name = 'Aigerim' AND last_name = 'Smailova'
);

--24
UPDATE employees e
SET salary = salary * (
    CASE 
        WHEN (SELECT budget FROM departments d WHERE d.dept_id = e.department) > 100000
            THEN 1.10
        ELSE 1.05
    END
);

--25
INSERT INTO employees (first_name, last_name, department, salary)
VALUES
('Ainur', 'Tlegenova', 'Finance', 45000),
('Dias', 'Mukanov', 'IT', 60000),
('Dana', 'Nurpeisova', 'HR', 40000),
('Alibek', 'Karimov', 'Marketing', 42000),
('Mira', 'Tasmagambetova', 'Sales', 38000);
--26
-- archive table creation
CREATE TABLE employee_archive AS 
TABLE employees WITH NO DATA;

-- data transfer
INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

-- delete archived records 
DELETE FROM employees
WHERE status = 'Inactive';
--27
UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000;



