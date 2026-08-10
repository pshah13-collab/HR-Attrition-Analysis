-- ============================================================
-- Employee Attrition Risk Analysis
-- 02_analysis.sql
-- The five core business-question queries, run against the
-- hr_clean view defined in 01_cleaning.sql
-- ============================================================

-- ---------------------------------------------------------
-- Q1: What's the overall attrition rate, and how does it
-- break down by department?
-- ---------------------------------------------------------

-- Overall rate
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS attrition_rate_pct
FROM hr_clean;

-- By department
SELECT
    Department,
    COUNT(*) AS total_employees,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS attrition_rate_pct
FROM hr_clean
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- ---------------------------------------------------------
-- Q2: For employees who left, how do their tenure, job
-- satisfaction, and income compare to those who stayed?
-- ---------------------------------------------------------

SELECT
    Attrition,
    ROUND(AVG(YearsAtCompany), 1) AS avg_tenure,
    ROUND(AVG(JobSatisfaction), 1) AS avg_satisfaction,
    ROUND(AVG(MonthlyIncome), 0) AS avg_monthly_income
FROM hr_clean
GROUP BY Attrition;

-- ---------------------------------------------------------
-- Q3: Is there a tenure "danger zone"? Attrition rate by
-- tenure band.
-- ---------------------------------------------------------

WITH banded AS (
    SELECT
        EmployeeID,
        Attrition,
        CASE
            WHEN YearsAtCompany <= 2 THEN '0-2 years'
            WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 years'
            WHEN YearsAtCompany >= 6 THEN '6+ years'
            ELSE 'Unknown'
        END AS tenure_band
    FROM hr_clean
)
SELECT
    tenure_band,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS attrition_rate_pct
FROM banded
GROUP BY tenure_band
ORDER BY
    CASE tenure_band
        WHEN '0-2 years' THEN 1
        WHEN '3-5 years' THEN 2
        WHEN '6+ years' THEN 3
        ELSE 4
    END;

-- ---------------------------------------------------------
-- Q4: Which job roles have the highest attrition rate, and
-- how does that compare to the company-wide average?
-- (Job roles with only 1 employee are excluded to avoid
-- drawing conclusions from a statistically meaningless
-- sample size.)
-- ---------------------------------------------------------

WITH job_role_attrition AS (
    SELECT
        JobRole,
        COUNT(*) AS total,
        ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS attrition_rate_pct
    FROM hr_clean
    WHERE JobRole != 'Other/Unknown'
    GROUP BY JobRole
    HAVING COUNT(*) > 1
),
company_wide AS (
    SELECT ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS company_avg_rate
    FROM hr_clean
)
SELECT
    jra.JobRole,
    jra.total,
    jra.attrition_rate_pct,
    cw.company_avg_rate,
    CASE WHEN jra.attrition_rate_pct > cw.company_avg_rate THEN 'Above Average' ELSE 'At/Below Average' END AS risk_flag
FROM job_role_attrition jra
JOIN company_wide cw ON 1 = 1
ORDER BY jra.attrition_rate_pct DESC;

-- ---------------------------------------------------------
-- Q5: Compare attrition rates between employees who work
-- overtime vs. those who don't.
-- ---------------------------------------------------------

SELECT
    OverTime,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS attrition_rate_pct
FROM hr_clean
GROUP BY OverTime
ORDER BY attrition_rate_pct DESC;
