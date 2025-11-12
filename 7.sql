--1.1
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);
--1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary) 
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id, 
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);
--2.1
CREATE VIEW employee_details AS
SELECT
e.emp_name,
e.salary,
d.dept_name,
d.location
FROM employees e
LEFT JOIN departments d
ON e.dept_id=d.dept_id;

SELECT * FROM employee_details;
--5 rows,because he has null values
--2.2
CREATE VIEW dept_statistics AS
SELECT
d.dept_name,
COUNT(e.emp_id) AS employee_count,
AVG(e.salary) AS avg_salary,
MAX(e.salary) AS max_salary,
MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e
ON d.dept_id=e.dept_id
GROUP BY d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;
--2.3
CREATE VIEW project_overview AS 
SELECT 
p.project_name,
p.budget,
d.dept_name,
d.location,
COUNT(e.emp_id) AS employees_count
FROM projects p
LEFT JOIN departments d
ON d.dept_id=p.dept_id
LEFT JOIN employees e
ON d.dept_id=p.dept_id
GROUP BY d.dept_name,
p.project_name,
p.budget,
d.location;
--2.4
CREATE VIEW high_earners AS
SELECT
e.emp_name,
e.salary,
d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id=d.dept_id

WHERE e.salary>55000;

--3.1
CREATE OR REPLACE VIEW  employees_details AS
SELECT 
e.emp_name,
e.salary,
CASE
WHEN e.salary>60000 THEN ' High'
WHEN e.salary>50000 THEN 'Medium'
ELSE 'Standard'
END AS salary_l
FROM employees e;
--3.2
ALTER VIEW high_earners
RENAME TO top_performers;
--3.3
CREATE VIEW temp_view AS
SELECT
e.emp_name,
e.salary
FROM employees e
WHERE e.salary<50000;

 DROP VIEW temp_view;

--4.1
CREATE OR REPLACE VIEW employees_salaries AS 
SELECT
emp_id,
emp_name,
dept_id,
salary
FROM employees 
;
--4.2
UPDATE  employees_salaries
SET salary=52000
WHERE emp_name='John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';
--4.3
INSERT INTO employees_salaries(emp_id,dept_id,salary)
VALUES(6,102,'58000');
--4.4
CREATE VIEW it_employees AS
SELECT
emp_id,emp_name,dept_id,salary
FROM employees
WHERE dept_id=101
WITH LOCAL CHECK OPTION;
-- This should fail
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
--ddept id isnt 103
--5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT 
d.dept_id,
d.dept_name,
COALESCE (COUNT(e.emp_id),0) AS total_employees,
COALESCE(COUNT(e.salary),0) AS total_salaries,
COALESCE(COUNT(p.project_id),0) AS total_projects,
COALESCE(COUNT(p.budget),0) AS total_projects
FROM departments d
LEFT JOIN employees e
ON d.dept_id=e.dept_id
LEFT JOIN projects p
ON d.dept_id=p.dept_id
GROUP BY d.dept_id, d.dept_name; 

SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;
--5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;
--5.3
CREATE UNIQUE INDEX dept_summary_mv_idx ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
p.project_name,
p.budget,
d.dept_name,
COUNT(e.emp_id) AS employee_count
FROM departments d 
LEFT JOIN projects p ON p.dept_id=d.dept_id
LEFT JOIN employees e ON e.dept_i=p.dept_id
GROUP BY p.project_name,p.budget,d.dept_name
WITH NO DATA;

SELECT * FROM project_stats_mv;
--6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user LOGIN PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';
--6.2
CREATE ROLE db_creator LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager LOGIN CREATEROLE  PASSWORD 'manager101';
CREATE ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';
--6.3
GRANT SELECT ON employees , departments, projects TO analyst; 
GRANT ALL PRIVILEGES ON employee_details to data_viewer;
GRANT SELECT, INSERT ON privileges TO report_user;
--6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;
--6.5
REVOKE UPDATE ON employees TO hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;
--6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;
--7.1
  CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;
--7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';
--7.3
CREATE ROLE temp_owner LOGIN;

CREATE TABLE temp_table (id INT);

ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;
--7.4
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;
--8.1
CREATE OR REPLACE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    COUNT(DISTINCT p.project_id) AS active_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget,
    ROUND(
        COALESCE(SUM(p.budget), 0) / 
        NULLIF(COUNT(e.emp_id), 0), 2
    ) AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_name, d.location;

--8.2
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

--8.3
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;






