
-- =========================================================================
-- STEP 1: DATABASE INITIALIZATION
-- =========================================================================
CREATE DATABASE IF NOT EXISTS hr_analytics_scenario;
USE hr_analytics_scenario;

-- =========================================================================
-- STEP 2: TABLE CREATION (Relational Architecture)
-- =========================================================================

-- Table 1: Departments (The lookup table for budgeting and structure)
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    min_salary INT,
    max_salary INT
);

-- Table 2: Employees (The core table with your custom Hire/End dates)
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    SSN VARCHAR(11) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    birthdate DATE,
    hiredate DATE NOT NULL,
    termination_date DATE, -- NULL for active employees
    status VARCHAR(20),    -- Handles the "rubbish" data cleaning (Active/Inactive)
    dept_id INT,
    jobrole VARCHAR(50),
    joblevel INT,
    manager_id INT,        -- Self-referencing FK for Span of Control analysis
    distancefromhome INT,  -- Commute analysis
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Table 3: Salaries (Time-stamped for historical and current audit)
CREATE TABLE salaries (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    salary INT NOT NULL,
    overtime CHAR(1),      -- 'Y' or 'N' for Burnout analysis
    from_date DATE,
    to_date DATE,          -- Uses '9999-01-01' for current active salary
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Table 4: PM_Engagement (The Performance & Satisfaction metrics)
CREATE TABLE pm_engagement (
    engagement_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    performancerating INT,
    jobsatisfaction INT,
    worklifebalance INT,
    jobinvolvement INT,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);