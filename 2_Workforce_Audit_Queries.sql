USE hr;

-- Q1: 2025 Workforce Pulse (The High-Level Baseline)
SELECT 
    COUNT(CASE WHEN status = 'active' AND YEAR(hiredate) <= "2025" THEN 1 END) AS 2025_HC,
    ROUND(AVG(DATEDIFF("2025-12-31", birthdate)/365),0) AS AVG_Age,
    ROUND(AVG(DATEDIFF("2025-12-31", hiredate)/365),1) AS AVG_Tenure,
    ROUND(COUNT(CASE WHEN gender = 'F' AND status = "active" AND YEAR(hiredate) <= "2025" THEN 1 END)/count(gender)*100,2) AS Female_percent,
    COUNT(CASE WHEN status = 'inactive' AND YEAR(termination_date) = "2025" THEN 1 END) AS 2025_Separations,
    COUNT(CASE WHEN status = 'active' AND YEAR(hiredate) = "2025" THEN 1 END) AS 2025_new_hires
FROM employees;

-- Q2: Departmental Talent Distribution & Institutional Knowledge
SELECT 
    d.department_name AS Department,
    COUNT(e.emp_id) AS Headcount,
    ROUND(AVG(DATEDIFF("2025-12-31", e.hiredate)/365), 1) AS Avg_Tenure_Years
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.status = "active"
GROUP BY d.department_name
ORDER BY Headcount DESC;

-- Q3: Age Distribution (Snapshot as of Dec 31, 2025)
SELECT 
    CASE 
        WHEN age < 20 THEN '<20' WHEN age <= 25 THEN '20-25' WHEN age <= 30 THEN '26-30'
        WHEN age <= 35 THEN '31-35' WHEN age <= 40 THEN '36-40' WHEN age <= 45 THEN '41-45'
        WHEN age <= 50 THEN '46-50' WHEN age <= 55 THEN '51-55' WHEN age <= 60 THEN '56-60'
        ELSE '60+' 
    END AS age_range,
    COUNT(*) AS employee_count
FROM (
    SELECT TIMESTAMPDIFF(YEAR, birthdate, '2025-12-31') AS age
    FROM employees WHERE status = 'active'
) AS sub
GROUP BY age_range ORDER BY age_range;

-- Q4: Salary Band Penetration & Compensation Audit
SELECT 
    d.department_name, d.min_salary, d.max_salary,
    ROUND(AVG(s.salary), 0) AS avg_salary,
    ROUND((AVG(s.salary) - d.min_salary) / (d.max_salary - d.min_salary) * 100, 1) AS range_penetration_pct
FROM departments d 
JOIN employees e ON d.dept_id = e.dept_id
JOIN salaries s ON e.emp_id = s.emp_id
WHERE e.status = "active" AND s.to_date = "9999-01-01"
GROUP BY d.department_name, d.min_salary, d.max_salary;

-- Q5: Manager Workload & Team Sizes (Span of Control)
SELECT
    d.department_name,
    CONCAT(e2.first_name," ",e2.last_name) AS manager,
    COUNT(e1.emp_id) AS direct_reports
FROM employees e2
LEFT JOIN employees e1 ON e1.manager_id = e2.emp_id
LEFT JOIN departments d ON e2.dept_id = d.dept_id
WHERE e1.status = "active"
GROUP BY department_name, manager
ORDER BY department_name ASC, direct_reports DESC;

-- Q6: Early Leaver Rate (Quality of Hire Analysis)
SELECT 
    d.department_name,
    COUNT(*) AS total_hires_2025,
    SUM(CASE WHEN DATEDIFF(e.termination_date, e.hiredate) < 365 THEN 1 ELSE 0 END) AS early_leavers,
    ROUND(SUM(CASE WHEN DATEDIFF(e.termination_date, e.hiredate) < 365 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS early_leaver_pct
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.hiredate >= '2025-01-01'
GROUP BY d.department_name ORDER BY early_leaver_pct DESC;

-- Q7: 2025 Annual Attrition Rate (Standard HR Formula)
WITH period_data AS (
    SELECT COUNT(*) AS start_count FROM employees 
    WHERE hiredate <= "2025-01-01" AND (termination_date IS NULL OR termination_date >= "2025-01-01")
),
leavers AS (
    SELECT COUNT(*) AS left_count FROM employees 
    WHERE termination_date BETWEEN "2025-01-01" AND "2025-12-31"
),
end_data AS (
    SELECT COUNT(*) AS end_count FROM employees 
    WHERE hiredate <= "2025-12-31" AND (termination_date IS NULL OR termination_date >= "2025-12-31")
)
SELECT l.left_count AS separations, p.start_count, e.end_count,
    ROUND((l.left_count / ((p.start_count + e.end_count) / 2)) * 100, 2) AS attrition_rate_percent
FROM period_data p JOIN leavers l ON 1=1 JOIN end_data e ON 1=1;

-- Q8: Monthly Termination Seasonality (2025 Trend Analysis)
SELECT 
    MONTH(termination_date) AS month_num,
    MONTHNAME(termination_date) AS termination_month,
    COUNT(emp_id) AS total_terminations,
    SUM(COUNT(emp_id)) OVER (ORDER BY MONTH(termination_date)) AS cumulative_terminations
FROM employees
WHERE termination_date BETWEEN "2025-01-01" AND "2025-12-31"
AND status = "inactive"
GROUP BY month_num, termination_month
ORDER BY month_num ASC;

-- Q9: Yearly Turnover Trend (2024 vs. 2025)
SELECT 
    d.department_name,
    SUM(CASE WHEN YEAR(e.termination_date) = 2024 THEN 1 ELSE 0 END) AS leavers_2024,
    SUM(CASE WHEN YEAR(e.termination_date) = 2025 THEN 1 ELSE 0 END) AS leavers_2025,
    (SUM(CASE WHEN YEAR(e.termination_date) = 2025 THEN 1 ELSE 0 END) - 
     SUM(CASE WHEN YEAR(e.termination_date) = 2024 THEN 1 ELSE 0 END)) AS change_vs_last_year
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.department_name;

-- Q10: Burnout Risk: Overtime vs. Satisfaction Gaps
SELECT 
    e.jobrole, e.joblevel,
    ROUND(AVG(CASE WHEN s.overtime = 'N' THEN eg.worklifebalance END) - 
          AVG(CASE WHEN s.overtime = 'Y' THEN eg.worklifebalance END), 2) AS WLB_Gap,
    ROUND(AVG(CASE WHEN s.overtime = 'N' THEN eg.jobsatisfaction END) - 
          AVG(CASE WHEN s.overtime = 'Y' THEN eg.jobsatisfaction END), 2) AS JobSat_Gap
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
JOIN pm_engagement eg ON e.emp_id = eg.emp_id
WHERE e.status = 'active' AND s.to_date = '9999-01-01'
GROUP BY e.jobrole, e.joblevel ORDER BY WLB_Gap DESC;

-- Q11: Engagement Decay & Job Involvement Analysis
SELECT 
    e.jobrole,
    ROUND(AVG(CASE WHEN s.overtime = 'N' THEN eg.jobinvolvement END) - 
          AVG(CASE WHEN s.overtime = 'Y' THEN eg.jobinvolvement END), 2) AS JINV_Gap
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
JOIN pm_engagement eg ON e.emp_id = eg.emp_id
WHERE e.status = 'active' AND s.to_date = '9999-01-01'
GROUP BY e.jobrole ORDER BY JINV_Gap DESC;

-- Q12: Gender Distribution by Leadership Level (Pipeline Audit)
SELECT 
    joblevel, COUNT(*) as HCPerLevel,
    ROUND(COUNT(CASE WHEN gender = 'M' THEN 1 END) * 100.0 / COUNT(*), 2) AS Male_Pct,
    ROUND(COUNT(CASE WHEN gender = 'F' THEN 1 END) * 100.0 / COUNT(*), 2) AS Female_Pct
FROM employees WHERE status = "active"
GROUP BY joblevel ORDER BY joblevel;

-- Q13: Executive Summary Master View
SELECT 
    d.department_name,
    COUNT(CASE WHEN LOWER(TRIM(e.status)) = 'active' THEN 1 END) AS current_headcount,
    ROUND(AVG(CASE WHEN s.to_date = '9999-01-01' THEN s.salary END), 0) AS avg_salary,
    ROUND(COUNT(CASE WHEN LOWER(TRIM(e.status)) = 'inactive' THEN 1 END) * 100.0 / COUNT(e.emp_id), 2) AS turnover_rate_pct
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN salaries s ON e.emp_id = s.emp_id
GROUP BY d.department_name;

-- Q14: Performance-Salary Audit (Meritocracy Check)
CREATE OR REPLACE VIEW Performance_Salary_Audit AS
SELECT 
    d.department_name,
    ROUND(AVG(eg.performancerating), 2) AS avg_dept_rating,
    ROUND(AVG(CASE WHEN eg.performancerating = 4 THEN s.salary END), 0) AS avg_salary_top_perf,
    ROUND(AVG(CASE WHEN eg.performancerating = 3 THEN s.salary END), 0) AS avg_salary_std_perf,
    ROUND((AVG(CASE WHEN eg.performancerating = 4 THEN s.salary END) - 
           AVG(CASE WHEN eg.performancerating = 3 THEN s.salary END)), 0) AS perf_pay_gap
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
JOIN pm_engagement eg ON e.emp_id = eg.emp_id
JOIN salaries s ON e.emp_id = s.emp_id
WHERE e.status = 'active' AND s.to_date = '9999-01-01'
GROUP BY d.department_name;

-- Q15: Commute Burden & Retention Impact (Geography Analysis)
SELECT 
    CASE 
        WHEN distancefromhome <= 20 THEN 'Short (10-20 KM)'
        WHEN distancefromhome <= 50 THEN 'Medium (21-50 KM)'
        WHEN distancefromhome <= 90 THEN 'Long (51-90 KM)'
        ELSE 'Extreme (91-120 KM)'
    END AS distance_bracket,
    COUNT(e.emp_id) AS total_employees,
    ROUND(COUNT(CASE WHEN LOWER(TRIM(e.status)) = 'inactive' THEN 1 END) * 100.0 / COUNT(e.emp_id), 2) AS attrition_pct,
    ROUND(AVG(eg.jobsatisfaction), 2) as avg_satisfaction 
FROM employees e
LEFT JOIN pm_engagement eg ON e.emp_id = eg.emp_id
GROUP BY distance_bracket ORDER BY attrition_pct DESC;

-- Q16: The Boomerang Recovery Audit (Strategic Rehires)
SELECT 
    e1.SSN, e1.first_name, e1.last_name, 
    e1.termination_date AS exit_date, 
    e2.hiredate AS rehire_2026,
    DATEDIFF(e2.hiredate, e1.termination_date) AS days_away
FROM employees e1
JOIN employees e2 ON e1.SSN = e2.SSN
WHERE e1.termination_date IS NOT NULL 
  AND e2.termination_date IS NULL
  AND DATEDIFF(e2.hiredate, e1.termination_date) >= 120;




