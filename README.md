# Employee Attrition Risk Analysis

A SQL + Tableau project analyzing employee attrition patterns to identify key risk factors and support data-driven retention strategy.

**[View the live dashboard on Tableau Public →](https://public.tableau.com/app/profile/pooja.shah8865/viz/HR_Attrition_Analysis_17863973710400/Dashboard2#1)**

---

## Overview

Using a simulated HR dataset (schema modeled on the IBM HR Analytics Attrition dataset), this project answers five core business questions an HR or People Analytics team would realistically ask:

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
- A composite risk score combining these factors was validated against real outcomes: employees who left scored **2.14** on average vs. **1.40** for those who stayed, confirming the score identifies a genuine pattern — not just noise

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

## Extension: A Validated Risk Score

Beyond the five core questions, this project includes a second dashboard page that goes a step further than reporting rates — it builds and validates a simple predictive-style signal.

**What it does:** each active employee gets a composite risk score (0–4), earning one point for each risk factor already proven to matter in the core analysis: tenure of 2 years or less, working overtime, low job satisfaction (bottom half of the scale), and an above-average commute distance.

**Why it's trustworthy, not just invented:** the score isn't just assumed to work — it's checked against real outcomes. Employees who actually left the company scored **2.14** on average, versus **1.40** for employees who stayed. That gap confirms the score captures a genuine signal rather than being an arbitrary formula.

**The output:** a ranked, color-coded view of currently active employees sitting above the average risk threshold — turning a set of aggregate findings into a concrete, actionable list rather than just a set of charts.

**A note on scope:** this is a simple rule-based composite score (each factor weighted equally), not a statistical or machine-learning model — it's meant to demonstrate the *thinking* behind predictive risk flagging (build a hypothesis, test it against real outcomes, only trust it once validated) rather than to be production-grade. A more rigorous version would weight factors by their actual statistical relationship to attrition rather than treating all four equally.

## Repository Contents

| File | Description |
|---|---|
| `hr_attrition_dataset.xlsx` | Raw, intentionally messy source data |
| `01_cleaning.sql` | Data quality audit + the `hr_clean` view definition |
| `02_analysis.sql` | The five core business-question queries |
| `03_risk_score.sql` | Composite risk score, active-employee watchlist, and validation query |
| `dashboard_screenshot.png` | Preview of the final Tableau dashboard |

## Methodology Notes

- Attrition rate is calculated as `(employees with Attrition = 'Yes') / (total employees) * 100`, consistently applied at every level of aggregation (overall, by department, by tenure band, by job role)
- Rows with an unresolvable category (e.g., a job role with only 1 employee) were excluded from role-level comparisons to avoid drawing conclusions from statistically meaningless sample sizes — noted explicitly rather than silently dropped
- All comparisons between subgroups (e.g., "left" vs. "stayed") apply identical filtering logic on both sides to ensure a fair, consistent comparison

## Author

Pooja Shah — [LinkedIn](https://linkedin.com/in/poojashah) · [Email](mailto:poojadshah1999@gmail.com)
