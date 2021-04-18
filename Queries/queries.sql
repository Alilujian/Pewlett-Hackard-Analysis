-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (dept_no VARCHAR(4) NOT NULL,
						  dept_name VARCHAR(40) NOT Null,
						  PRIMARY KEY (dept_no),
						  UNIQUE (dept_name));
						 
CREATE TABLE employees (emp_no INT NOT NULL,
						birth_date DATE NOT NULL,
						first_name VARCHAR NOT NULL,
						last_name VARCHAR NOT NULL,
						gender VARCHAR NOT NULL,
						hire_date DATE NOT NULL,
						PRIMARY KEY (emp_no));
						
CREATE TABLE dept_manager (dept_no VARCHAR(4) NOT NULL,
						   emp_no INT NOT NULL,
						   from_date DATE NOT NULL,
						   to_date DATE NOT NULL,
						   FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
						   FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
						   PRIMARY KEY (emp_no, dept_no));
			
CREATE TABLE salaries (emp_no INT NOT NULL,
  					   salary INT NOT NULL,
					   from_date DATE NOT NULL,
					   to_date DATE NOT NULL,
					   FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
					   PRIMARY KEY (emp_no));

			   
CREATE TABLE dept_emp (emp_no INT NOT NULL,
					   dept_no VARCHAR(10) NOT NULL,
					   from_date DATE NOT NULL,
					   to_date DATE NOT NULL,
					   FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
					   FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
					   PRIMARY KEY (emp_no, dept_no));	
					   		
CREATE TABLE titles (emp_no INT NOT NULL,
					 title VARCHAR(40) NOT NULL,
					 from_date DATE NOT NULL,
					 to_date DATE NOT NULL,
					 FOREIGN KEY (emp_no) REFERENCES employees (emp_no));	
					 
					 
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM dept_manager;
SELECT * FROM salaries;
SELECT * FROM dept_emp;
SELECT * FROM titles;

-- DETERMINE RETIREMENT ELIGIBILITY
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND 
		(hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND 
		(hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Create new table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND 
		(hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info;

-- Create new table for retiring employees
DROP TABLE retirement_info;

SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND 
		(hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joinning departments and dept_manager tables
SELECT d.dept_name,
	   dm.emp_no,
	   dm.from_date,
	   dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Joinning retirement_info and dept_emp tables
SELECT ri.emp_no,
	   ri.first_name,
	   ri.last_name,
	   de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Check current_emp
SELECT * FROM current_emp;

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO employee_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT * FROM employee_count;

-- LIST 1: Employee Information
SELECT * FROM salaries
ORDER BY to_date DESC;

SELECT emp_no, first_name, last_name, gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND 
		(hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- joinning employees, salaries, and dept_emp
DROP TABLE emp_info;
SELECT e.emp_no,
	   e.first_name,
	   e.last_name,
	   e.gender,
	   s.salary,
	   de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND 
		(e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
		AND (de.to_date = '9999-01-01');

SELECT * FROM emp_info;

-- LIST 2: Management per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);


-- LIST 3: Department Retirees
SELECT ce.emp_no,
		ce.first_name,
		ce.last_name,
		d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no);

-- Tailored List

-- Sales team
SELECT ri.emp_no,
		ri.first_name,
		ri.last_name,
		d.dept_name
INTO sales_info
FROM retirement_info as ri
INNER JOIN dept_emp as de
ON (ri.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE dept_name = 'Sales';

-- Sales and developmnet teams
SELECT ri.emp_no,
		ri.first_name,
		ri.last_name,
		d.dept_name
INTO salesdevel_info
FROM retirement_info as ri
INNER JOIN dept_emp as de
ON (ri.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE dept_name IN ('Sales','Development');