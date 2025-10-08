-- Create tables
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department, 
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL, 
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1, 
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL, 
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL, 
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3, 
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date, 
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30', 
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31', 
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31', 
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id, 
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

-- 1.1
SELECT first_name || ' ' || last_name AS full_name, department, salary
FROM employees;

-- 1.2
SELECT DISTINCT department
FROM employees;

-- 1.3
SELECT project_name, budget,
CASE
  WHEN budget > 150000 THEN 'Large'
  WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
  ELSE 'Small'
END AS budget_category
FROM projects;

-- 1.4
SELECT first_name || ' ' || last_name AS full_name,
COALESCE(email, 'No email provided') AS email
FROM employees;

-- 2.1
SELECT * FROM employees
WHERE hire_date > '2020-01-01';

-- 2.2
SELECT * FROM employees
WHERE salary BETWEEN 60000 AND 70000;

-- 2.3
SELECT * FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

-- 2.4
SELECT * FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT';

-- 3.1
SELECT UPPER(first_name || ' ' || last_name) AS name,
LENGTH(last_name) AS len,
SUBSTRING(COALESCE(email, '') FROM 1 FOR 3) AS first3
FROM employees;

-- 3.2
SELECT first_name || ' ' || last_name AS name,
salary AS annual,
ROUND(salary/12, 2) AS monthly,
ROUND(salary*0.1, 2) AS raise
FROM employees;

-- 3.3
SELECT 'Project: ' || project_name || ' - Budget: $' || budget || ' - Status: ' || status AS info
FROM projects;

-- 3.4
SELECT first_name || ' ' || last_name AS name,
DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS years_worked
FROM employees;

-- 4.1
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department;

-- 4.2
SELECT p.project_name, SUM(a.hours_worked) AS total_hours
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name;

-- 4.3
SELECT department, COUNT(*) AS num
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- 4.4
SELECT MAX(salary) AS max_salary, MIN(salary) AS min_salary, SUM(salary) AS total_payroll
FROM employees;

-- 5.1
SELECT employee_id, first_name || ' ' || last_name AS name, salary
FROM employees
WHERE salary > 65000
UNION
SELECT employee_id, first_name || ' ' || last_name AS name, salary
FROM employees
WHERE hire_date > '2020-01-01';

-- 5.2
SELECT employee_id, first_name || ' ' || last_name AS name, salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name || ' ' || last_name AS name, salary
FROM employees
WHERE salary > 65000;

-- 5.3
SELECT employee_id, first_name || ' ' || last_name AS name
FROM employees
EXCEPT
SELECT e.employee_id, e.first_name || ' ' || e.last_name
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;

-- 6.1
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS name
FROM employees e
WHERE EXISTS (SELECT 1 FROM assignments a WHERE a.employee_id = e.employee_id);

-- 6.2
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS name
FROM employees e
WHERE e.employee_id IN (
  SELECT a.employee_id
  FROM assignments a
  JOIN projects p ON a.project_id = p.project_id
  WHERE p.status = 'Active'
);

-- 6.3
SELECT employee_id, first_name || ' ' || last_name AS name, salary
FROM employees
WHERE salary > ANY (
  SELECT salary FROM employees WHERE department = 'Sales'
);

-- 7.1
SELECT e.first_name || ' ' || e.last_name AS name,
e.department,
(SELECT AVG(hours_worked) FROM assignments a WHERE a.employee_id = e.employee_id) AS avg_hours,
(SELECT COUNT(*)+1 FROM employees e2 WHERE e2.department=e.department AND e2.salary>e.salary) AS rank_in_dept
FROM employees e;

-- 7.2
SELECT p.project_name,
SUM(a.hours_worked) AS total_hours,
COUNT(DISTINCT a.employee_id) AS num_emp
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 150;

-- 7.3
SELECT e.department,
COUNT(*) AS num_employees,
ROUND(AVG(salary),2) AS avg_salary,
(SELECT first_name || ' ' || last_name FROM employees e2 WHERE e2.department=e.department ORDER BY salary DESC LIMIT 1) AS top_employee,
GREATEST(MAX(salary), MIN(salary)) AS greatest_salary,
LEAST(MAX(salary), MIN(salary)) AS least_salary
FROM employees e
GROUP BY e.department;
