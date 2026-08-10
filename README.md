# Employee Attrition Risk Analysis

A SQL + Tableau project analyzing employee attrition patterns...

**[View the live dashboard on Tableau Public →](https://public.tableau.com/app/profile/pooja.shah8865/viz/HR_Attrition_Analysis_17863973710400/Dashboard2#1)**

---

## Overview

A self-directed project applying SQL and Tableau to HR attrition analysis, inspired by real workforce challenges encountered during my HR analytics roles at Linear Loop and Qable and Tatvic Analytics — where I worked on onboarding redesign and retention initiatives using similar (though less structured) analysis. This project answers five core business questions an HR or People Analytics team would realistically ask:

1. What's the overall attrition rate, and how does it break down by department?
2. How do employees who left compare to those who stayed, in tenure, satisfaction, and income?
3. Is there a tenure "danger zone" where attrition risk is highest?
4. Which job roles have the highest attrition relative to the company average?
5. Does working overtime correlate with a higher likelihood of leaving?

## Key Findings

- **Overall attrition rate: 37.6%** across 133 employees
- **Overtime is the strongest risk signal identified**: employees who work overtime leave at **more than 2x the rate** of those who don't (60% vs. 29%)
- **Tenure danger zone**: employees with **0-2 years** of tenure show a **49%** attrition rate — nearly double the rate of employees with 6+ years
- **Sales** is the highest-risk department at **42.9%**, and **Sales Executive** and **HR Manager** are the highest-risk individual job roles, both sitting above the company-wide average

## Data Cleaning

The raw dataset intentionally mirrors real-world data quality issues commonly found in exported HR systems:

- **Inconsistent categorical formatting** — e.g., `Department` values like `'Sales'`, `'sales'`, `'SALES'`, `' Sales'` all needed to be standardized to a single canonical value
- **Multiple true spelling variants** — e.g., `'R&D'` vs `'RnD'`, which formatting fixes (TRIM/UPPER) alone can't resolve; required explicit mapping via `CASE`
- **Missing values** across `MonthlyIncome`, `JobSatisfaction`, `DistanceFromHome`, `HireDate`, and `Age` — audited and quantified rather than silently dropped
- **A data entry outlier** (`Age = 150`) — flagged using a plausible-range condition rather than hardcoding the specific bad row
- **An orphaned foreign key** — one employee referenced a `department_id` that didn't exist in the lookup table, surfaced via a `LEFT JOIN` + `IS NULL` check

All cleaning logic is consolidated into a single reusable SQL `VIEW` (`hr_clean`), so every downstream analysis query reads from one consistent, tidy source rather than repeating cleaning logic per query.

## Tech Stack

- **MySQL** — data cleaning (CASE, TRIM, COALESCE), aggregation, CTEs, window functions
- **Tableau Public** — dashboard visualization, calculated fields, reference lines

## Repository Contents

| File | Description |
|---|---|
| `hr_attrition_dataset.xlsx` | Raw, intentionally messy source data |
| `01_cleaning.sql` | Data quality audit + the `hr_clean` view definition |
| `02_analysis.sql` | The five core business-question queries |
| `dashboard_screenshot.png` | Preview of the final Tableau dashboard |

## Methodology Notes

- Attrition rate is calculated as `(employees with Attrition = 'Yes') / (total employees) * 100`, consistently applied at every level of aggregation (overall, by department, by tenure band, by job role)
- Rows with an unresolvable category (e.g., a job role with only 1 employee) were excluded from role-level comparisons to avoid drawing conclusions from statistically meaningless sample sizes — noted explicitly rather than silently dropped
- All comparisons between subgroups (e.g., "left" vs. "stayed") apply identical filtering logic on both sides to ensure a fair, consistent comparison

## Author

Pooja Shah — [LinkedIn](https://linkedin.com/in/poojashah) · [Email](mailto:poojadshah1999@gmail.com)
