USE HR_analytics;

SELECT * from HR_RAW;
DESCRIBE HR_RAW;

# Q1. Find the distinct list of every raw value currently in the Department column, so you can see exactly how many variants exist.
SELECT DISTINCT (Department)
FROM HR_RAW;

# Q2. Write a query that standardizes Department into clean values ('Sales', 'R&D', 'HR') regardless of casing or stray whitespace, and flags anything that doesn't match any known department as 'Other/Unknown'.
SELECT Department,
       CASE
           WHEN Department IS NULL THEN 'Other/Unknown'
           WHEN TRIM(UPPER(Department)) = 'SALES' THEN 'Sales'
           WHEN TRIM(UPPER(Department)) IN ('R&D', 'RND') THEN 'R&D'
           WHEN TRIM(UPPER(Department)) = 'HR' THEN 'HR'
           ELSE 'Other/Unknown'
       END AS department_clean
FROM HR_RAW;

# Q3. Do the same standardization for OverTime — collapse all variants down to a clean 'Yes'/'No', 
#and decide what to do with NULLs (show them as a separate 'Unknown' category rather than guessing).
SELECT Overtime,
	CASE	
		WHEN Overtime IS NULL THEN 'Other/Unknown'
        WHEN TRIM(UPPER(Overtime)) = 'YES' THEN 'Yes'
        WHEN TRIM(UPPER(Overtime)) IN ('NO', 'N') THEN 'No'
        ELSE 'Other/Unknown'
	END AS Overtime_clean
FROM HR_RAW;

# Q4. Find any rows where Age looks like a data entry error (e.g., implausibly high or low for a working adult) —
# don't hardcode the exact bad row, write a condition that would catch this class of error generally.

SELECT *
from HR_RAW
where age < 18 OR AGE > 75;

# Q5. Find the percentage of rows with at least one NULL across 
#MonthlyIncome, JobSatisfaction, DistanceFromHome, or HireDate — 
#this tells you how much of your dataset would be affected if you dropped incomplete rows entirely (a decision point for later).
SELECT * FROM hr_raw;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE 
        WHEN MonthlyIncome IS NULL OR MonthlyIncome = ''
          OR JobSatisfaction IS NULL OR JobSatisfaction = ''
          OR DistanceFromHome IS NULL OR DistanceFromHome = ''
          OR HireDate IS NULL OR HireDate = ''
        THEN 1 ELSE 0 
    END) AS rows_with_missing_data,
    ROUND(
        SUM(CASE 
            WHEN MonthlyIncome IS NULL OR MonthlyIncome = ''
              OR JobSatisfaction IS NULL OR JobSatisfaction = ''
              OR DistanceFromHome IS NULL OR DistanceFromHome = ''
              OR HireDate IS NULL OR HireDate = ''
            THEN 1 ELSE 0 
        END) / COUNT(*) * 100, 1
    ) AS pct_with_missing_data
FROM HR_RAW;
   

# Q6. Using CASE and TRIM/UPPER, create ONE clean derived column that maps all 
#JobRole variants (different casing/whitespace) to a single canonical version.
SELECT * FROM hr_raw;

SELECT JobRole,
       CASE
           WHEN TRIM(UPPER(JobRole)) = 'SALES EXECUTIVE' THEN 'Sales Executive'
           WHEN TRIM(UPPER(JobRole)) = 'SALES REPRESENTATIVE' THEN 'Sales Representative'
           WHEN TRIM(UPPER(JobRole)) = 'MANAGER' THEN 'Manager'
           WHEN TRIM(UPPER(JobRole)) = 'RESEARCH SCIENTIST' THEN 'Research Scientist'
           WHEN TRIM(UPPER(JobRole)) = 'LAB TECHNICIAN' THEN 'Lab Technician'
           WHEN TRIM(UPPER(JobRole)) = 'HR SPECIALIST' THEN 'HR Specialist'
           WHEN TRIM(UPPER(JobRole)) = 'HR MANAGER' THEN 'HR Manager'
           ELSE 'Other/Unknown'
       END AS job_role_clean
FROM HR_RAW;
    
CREATE VIEW hr_clean AS
SELECT
    EmployeeID,
    CASE WHEN Age < 18 OR Age > 75 THEN NULL ELSE Age END AS Age,
    CASE
        WHEN Department IS NULL THEN 'Other/Unknown'
        WHEN TRIM(UPPER(Department)) = 'SALES' THEN 'Sales'
        WHEN TRIM(UPPER(Department)) IN ('R&D', 'RND') THEN 'R&D'
        WHEN TRIM(UPPER(Department)) = 'HR' THEN 'HR'
        ELSE 'Other/Unknown'
    END AS Department,
    CASE
        WHEN TRIM(UPPER(JobRole)) = 'SALES EXECUTIVE' THEN 'Sales Executive'
        WHEN TRIM(UPPER(JobRole)) = 'SALES REPRESENTATIVE' THEN 'Sales Representative'
        WHEN TRIM(UPPER(JobRole)) = 'MANAGER' THEN 'Manager'
        WHEN TRIM(UPPER(JobRole)) = 'RESEARCH SCIENTIST' THEN 'Research Scientist'
        WHEN TRIM(UPPER(JobRole)) = 'LAB TECHNICIAN' THEN 'Lab Technician'
        WHEN TRIM(UPPER(JobRole)) = 'HR SPECIALIST' THEN 'HR Specialist'
        WHEN TRIM(UPPER(JobRole)) = 'HR MANAGER' THEN 'HR Manager'
        ELSE 'Other/Unknown'
    END AS JobRole,
    MonthlyIncome,
    YearsAtCompany,
    JobSatisfaction,
    CASE
        WHEN OverTime IS NULL OR OverTime = '' THEN 'Unknown'
        WHEN UPPER(LEFT(TRIM(OverTime),1)) = 'Y' THEN 'Yes'
        WHEN UPPER(LEFT(TRIM(OverTime),1)) = 'N' THEN 'No'
        ELSE 'Unknown'
    END AS OverTime,
    DistanceFromHome,
    HireDate,
    Attrition
FROM HR_RAW;



# Q1. What's the overall attrition rate (%), and how does it break down by department?
SELECT * FROM hr_clean LIMIT 10;
# attrition rate = ( no of employees left/total no of employees ) * 100

SELECT
    COUNT(*) AS total, 
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS attrition_rate
FROM hr_clean;

# Q2. For employees who left (Attrition = 'Yes'), find their average tenure, job satisfaction, and monthly income — compared to those who stayed.
SELECT
    ROUND(AVG(YearsAtCompany),1) AS avg_tenure,
    ROUND(AVG(JobSatisfaction),1) AS avg_satisfaction,
    ROUND(AVG(MonthlyIncome),1) AS avg_income
FROM hr_clean
GROUP BY Attrition;


# Q3. Is there a tenure "danger zone"? Group employees into tenure bands (0-2, 3-5, 6+ years) and show the attrition rate within each band.
WITH banded AS (
    SELECT EmployeeID, YearsAtCompany, Attrition,
        CASE 
            WHEN YearsAtCompany <= 2 THEN 'Low'
            WHEN YearsAtCompany >= 3 AND YearsAtCompany < 6 THEN 'Medium'
            WHEN YearsAtCompany >= 6 THEN 'High'
            ELSE 'NA'
        END AS tenure_bands
    FROM hr_clean
)
SELECT tenure_bands,
       COUNT(*) AS total,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS attrition_rate
FROM banded
GROUP BY tenure_bands;

# Q4. Which job roles have the highest attrition rate, and how does that compare to the company-wide average?

WITH job_role_attrition AS (
    SELECT JobRole,
        COUNT(*) AS total,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS attrition_rate
    FROM hr_clean
    GROUP BY JobRole
),
company_wide AS (
    SELECT SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS company_avg_rate
    FROM hr_clean
)
SELECT jra.JobRole, jra.attrition_rate, cw.company_avg_rate
FROM job_role_attrition jra
JOIN company_wide cw 
ON 1=1
WHERE jra.attrition_rate = (SELECT MAX(attrition_rate) FROM job_role_attrition);

# Q5. Compare attrition rates between employees who work overtime vs. those who don't.

SELECT * FROM HR_CLEAN;

 SELECT Overtime,
        COUNT(*) AS total,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS attrition_rate
    FROM hr_clean
    GROUP BY Overtime;
    
    
# Q1. Find the company-wide average DistanceFromHome (excluding NULLs) — this will be your comparison point for "above average commute."

SELECT * FROM HR_CLEAN;

SELECT ROUND(avg(DistanceFromHome),1) as company_average
FROM  hr_clean;

# Q2. Using CASE, create a single column that scores each employee +1 point if YearsAtCompany <= 2, otherwise 0. Just this one factor for now.

SELECT YearsAtCompany,
CASE 
WHEN YearsAtCompany <= 2 THEN 1
ELSE 0 
END AS SCORE
FROM HR_CLEAN
;

# Q3. add three more +1/0 CASE conditions in the SAME row-level query — 
#one for OverTime = 'Yes', 
#one for JobSatisfaction being 1 or 2, 
#and one for DistanceFromHome above the company average (from Q1). 
# Add all four together into one total risk_score column, ranging 0-4.
SELECT * FROM HR_CLEAN;

WITH avg_distance AS (
    SELECT AVG(DistanceFromHome) AS company_average
    FROM hr_clean)


SELECT 
    e.YearsAtCompany, e.OverTime, e.JobSatisfaction, e.DistanceFromHome,
    (CASE WHEN e.YearsAtCompany <= 2 THEN 1 ELSE 0 END
   + CASE WHEN e.OverTime = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN e.JobSatisfaction <= 2 THEN 1 ELSE 0 END
   + CASE WHEN e.DistanceFromHome >= ad.company_average THEN 1 ELSE 0 END
    ) AS risk_score
FROM hr_clean e
JOIN avg_distance ad 
ON 1=1;


# Q4. Using your Q3 result, find the top 20 currently active employees (Attrition = 'No') with the highest risk_score, ordered highest risk first.
WITH avg_distance AS (
    SELECT AVG(DistanceFromHome) AS company_average
    FROM hr_clean)


SELECT 
    e.YearsAtCompany, e.OverTime, e.JobSatisfaction, e.DistanceFromHome, e.Attrition,
    (CASE WHEN e.YearsAtCompany <= 2 THEN 1 ELSE 0 END
   + CASE WHEN e.OverTime = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN e.JobSatisfaction <= 2 THEN 1 ELSE 0 END
   + CASE WHEN e.DistanceFromHome >= ad.company_average THEN 1 ELSE 0 END
    ) AS risk_score
FROM hr_clean e
JOIN avg_distance ad 
ON 1=1
WHERE Attrition = 'No'
ORDER BY risk_score DESC
LIMIT 20;

# Q5. Validate the score: group by Attrition (Yes/No) and show the average risk_score for each

WITH avg_distance AS (
    SELECT AVG(DistanceFromHome) AS company_average
    FROM hr_clean),


total_risk_score as (SELECT 
    e.YearsAtCompany, e.OverTime, e.JobSatisfaction, e.DistanceFromHome, e.Attrition,
    (CASE WHEN e.YearsAtCompany <= 2 THEN 1 ELSE 0 END
   + CASE WHEN e.OverTime = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN e.JobSatisfaction <= 2 THEN 1 ELSE 0 END
   + CASE WHEN e.DistanceFromHome >= ad.company_average THEN 1 ELSE 0 END
    ) AS risk_score
FROM hr_clean e
JOIN avg_distance ad 
ON 1=1)

select Attrition, avg(risk_score) as average_risk, count(*) as employee_count
FROM total_risk_score
GROUP BY Attrition;




