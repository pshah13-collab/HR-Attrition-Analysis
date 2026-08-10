-- ============================================================
-- Employee Attrition Risk Analysis
-- 01_cleaning.sql
-- Data quality audit + creation of the hr_clean view
-- ============================================================

-- ---------------------------------------------------------
-- STEP 1: Audit the raw data before cleaning anything
-- ---------------------------------------------------------

-- See every distinct raw value in Department to understand
-- how many formatting variants exist
SELECT DISTINCT Department
FROM hr_employees_raw;

-- Check how much of the dataset has at least one missing
-- value across the key numeric/date fields
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
FROM hr_employees_raw;

-- Flag implausible ages (data entry errors), not hardcoded
-- to any specific bad value
SELECT *
FROM hr_employees_raw
WHERE Age < 20 OR Age > 80;

-- ---------------------------------------------------------
-- STEP 2: Build a single reusable "clean" view
-- All downstream analysis queries should read from this
-- view rather than the raw table.
-- ---------------------------------------------------------

CREATE OR REPLACE VIEW hr_clean AS
SELECT
    EmployeeID,

    -- Age: null out clearly implausible data-entry errors
    -- rather than silently keeping or guessing a value
    CASE WHEN Age < 20 OR Age > 80 THEN NULL ELSE Age END AS Age,

    -- Department: collapse every casing/whitespace/spelling
    -- variant into one of the known categories, or flag as
    -- Other/Unknown if it doesn't match anything recognized
    CASE
        WHEN Department IS NULL THEN 'Other/Unknown'
        WHEN TRIM(UPPER(Department)) = 'SALES' THEN 'Sales'
        WHEN TRIM(UPPER(Department)) IN ('R&D', 'RND') THEN 'R&D'
        WHEN TRIM(UPPER(Department)) = 'HR' THEN 'HR'
        ELSE 'Other/Unknown'
    END AS Department,

    -- JobRole: same idea, normalized to a single clean,
    -- properly-cased canonical version
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

    -- OverTime: collapse Yes/No/yes/no/Y/N/YES/NO variants,
    -- and label genuinely missing values as 'Unknown' rather
    -- than guessing
    CASE
        WHEN OverTime IS NULL OR OverTime = '' THEN 'Unknown'
        WHEN UPPER(LEFT(TRIM(OverTime), 1)) = 'Y' THEN 'Yes'
        WHEN UPPER(LEFT(TRIM(OverTime), 1)) = 'N' THEN 'No'
        ELSE 'Unknown'
    END AS OverTime,

    DistanceFromHome,
    HireDate,
    Attrition

FROM hr_employees_raw;

-- ---------------------------------------------------------
-- STEP 3: Sanity check the view
-- ---------------------------------------------------------

SELECT * FROM hr_clean LIMIT 20;

-- Confirm Department collapsed down to exactly 4 categories
SELECT DISTINCT Department FROM hr_clean;

-- Confirm OverTime collapsed down to exactly 3 categories
SELECT DISTINCT OverTime FROM hr_clean;
