## Advanced Analytics Pipeline: Investor RFM Behavioral Segmentation 🎯 Executive Summary
This full-stack data analytics project optimizes asset retention and targets high-net-worth client cohorts for wealth management institutions. This project re-engineers the traditional retail RFM (Recency, Frequency, Monetary) framework to analyze financial transactional behavior:

* Recency (R): Days of account inactivity calibrated dynamically relative to the latest global transaction timestamp.
* Frequency (F): Longitudinal transaction volume velocity per distinct entity.
* Monetary (M): Total Assets Under Management (AUM), programmatically isolated from each investor's latest chronological closing balance snapshot.

By architecting an end-to-end analytics pipeline using PostgreSQL, Python, and Tableau, this project scales from raw transaction logs into an algorithmic scoring layer, culminating in an executive-ready business intelligence dashboard.

## 🏗️ Pipeline Architecture & Methodology
Rather than relying on automated auto-segmentation tools, this project utilizes a custom SQL-to-Python pipeline designed for computational efficiency and statistical normalization.

[Raw SQL DB] ──> [Dynamic Context Aggregation] ──> [Python Normalization Engine] ──> [Tableau Public BI Layer]

## 1. Data Engineering & Window Aggregation (PostgreSQL)
The data layer processes highly granular, non-aggregated transaction ledgers. To minimize local machine latency, compute-heavy window sorting and grouping functions are handled directly at the database level:

* Dynamic Recency Anchoring: Employs a non-correlated subquery evaluating MAX(transaction_timestamp) as a global metric baseline, preventing system breaks during rolling updates.
* AUM Isolation: To accurately capture financial position without inflating a user's ledger, the pipeline uses a optimized DISTINCT ON (account_id) statement sorted chronologically to isolate the true closing balance.

WITH max_date_cte AS (
	SELECT MAX(transaction_timestamp) AS global_max_date
	FROM financial_transactions
),
last_balance AS (
	SELECT DISTINCT ON (account_id) account_id, account_balance
	FROM financial_transactions
	ORDER BY account_id, transaction_timestamp DESC
)SELECT f.account_id, 
	(SELECT global_max_date::date FROM max_date_cte) - MAX(f.transaction_timestamp)::date AS recency,
	COUNT(f.transaction_id) AS frequency,
	l.account_balance AS total_aumFROM financial_transactions fJOIN last_balance l 
	ON f.account_id = l.account_id
	GROUP BY f.account_id, l.account_balance
	ORDER BY f.account_id;

## 2. Statistical Scoring & Algorithmic Clustering (Python)
In order to handle the heavy right-skew typical of financial asset distributions (where a minority of users hold a majority of capital), the Python optimization layer uses rank-based statistical quintiles (pd.qcut) over raw numeric bins. This normalizes the variances into clean 1–5 scale intervals.

# Recency: Inverse ranking (lower inactivity days map to peak behavioral score of 5)
df['R_Score'] = pd.qcut(df['recency'].rank(method='first', ascending=True), q=5, labels=[5,4,3,2,1])
# Frequency & Monetary: Forward ranking (highest volumes and capital map to peak score of 5)
df['F_Score'] = pd.qcut(df['frequency'].rank(method='first'), q=5, labels=[1,2,3,4,5])
df['M_Score'] = pd.qcut(df['total_aum'].rank(method='first'), q=5, labels=[1,2,3,4,5])

## 🎯 Strategic Cohort Definitions
Using deterministic conditional logic, investors are systematically assigned to core business personas to support cross-functional marketing and client-success initiatives:

* VIP Whale Investor (R ≥ 4, F ≥ 4, M ≥ 4): Elite active users holding top-tier asset concentrations. High-priority profiles for relationship managers.
* High Value Churn Risk (R ≤ 2, F ≥ 3, M ≥ 3): High-AUM investors displaying sudden platform abandonment signals. Immediate priority for advisory intervention.
* Active / Low Capital User (R ≥ 3, F ≥ 3, M ≤ 2): Highly active algorithmic or low-tier retail accounts. Primary targets for capital funding/deposit deposit match campaigns.
* New Account Profile (R ≥ 4, F ≤ 2): Onboarded users showing prompt engagement but minimal depth. Requires product-led adoption workflows.
* Dormant Account (R ≤ 2, F ≤ 2, M ≤ 2): Inactive, low-tier accounts optimized for automated, low-cost programmatic re-engagement channels.

## 3. Executive Enterprise Visualization (Tableau)
The finalized analytical output is delivered via a production-grade interactive dashboard designed for executive stakeholders and regional desk heads.
🔗 Interactive Live Dashboard: [Explore the Live Tableau Public Dashboard](https://public.tableau.com/app/profile/monika.mitchell2582/viz/RFMANALYSIS_17895114907100/Dashboard1?publish=yes)

* Portfolio Health KPIs: Aggregated macro-views displaying overall platform AUM, active account distributions, and shifting segment counts.
* Capital Risk Quadrants: Interactive scatter plots mapping individual frequency metrics against total asset valuations, cross-filtered dynamically by Recency tiers to reveal capital flight vulnerabilities.

------------------------------
## 📈 Data-Driven Business Impact

* Capital Flight Prevention: Quantified and mapped the total dollar volume of capital locked in the High Value Churn Risk cohort, giving the business development desk a high-probability target list to mitigate churn.
* Operational Tailoring: Segmented programmatic traders from traditional buy-and-hold capital, allowing product engineers to customize user interfaces according to execution frequency.
