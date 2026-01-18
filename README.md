# HR-Analytics-Project
HR Analytics: The 2025 "Burnout" Crisis & 2026 Strategic Recovery
📌 Project Overview
This project is a simulated business case based on a corporate crisis. 
In 2025, the company hit a record high attrition rate (83 separations). 
My mission was to act as a Data Detective: identify why people were leaving and track the success of the 2026 "Win-Back" mission to bring them back.

🏗️ The Data Architecture (Moving beyond Kaggle)
I didn't just use a standard flat file. I took the baseline Kaggle HR Dataset and re-engineered it to reflect a real-world relational database:

Relational Structure: Split the flat data into 4 tables: employees, departments, salaries, and pm_engagement.

Custom Logic: I manually injected Hire Dates, Termination Dates, and Manager IDs to allow for deep-dive trend analysis that isn't possible with the original dataset.

Data Cleaning: Handled erroneous data fields by standardizing status labels and calculating consistent tenure metrics.

🔍 Key Findings (The 2025 Diagnosis)
Using 15 targeted SQL queries, I identified the "Smoking Guns" behind the 2025 attrition trend:

The Overtime Tax: Data showed a massive "Satisfaction Gap." Employees working overtime had significantly lower Work-Life Balance and Job Involvement scores.

The Commute Burden: Attrition spiked for anyone living 50km+ from the office, regardless of their salary band.

The Leadership Leak: I mapped the gender ratio by job level, identifying exactly where the leadership pipeline was thinning out.

📈 The 2026 Recovery: "Boomerang" Success
Following the 2025 audit, stakeholders launched a mission to recover lost talent.

The 120-Day Rule: I built a custom "Boomerang Audit" to track employees who returned to the company after at least a 4-month gap.

The Result: This query validates the success of the 2026 recruitment strategy by identifying high-performers who were successfully lured back into the ecosystem.

🛠️ Technical Skills Demonstrated

Database Design: Table normalization and Foreign Key implementation.

Advanced SQL: Common Table Expressions (CTEs), Self-Joins for rehire logic, and Window Functions.

Business Intelligence: Translating raw HRIS data into an Executive Summary for stakeholders.

📂 How to use this repository
Run 1_Schema_Setup.sql to build the infrastructure.

Run 2_Workforce_Audit_Queries.sql to walk through the 18-step business diagnosis and recovery tracking.
