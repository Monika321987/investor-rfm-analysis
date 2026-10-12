/* Create raw transactions table */
CREATE TABLE financial_transactions(
transaction_id INT PRIMARY KEY,
account_id INT,
transaction_timestamp TIMESTAMP,
transaction_type VARCHAR(50),
transaction_amount NUMERIC (12,2),
account_balance NUMERIC(12,2)
);

COPY financial_transactions 
FROM 'C:\Users\Public\Financial Transactions.csv'
WITH (FORMAT CSV,HEADER);

/* Create CTE to calculate specific baselines metrics.*/
WITH max_date_cte AS (
	SELECT MAX(transaction_timestamp) AS global_max_date
	FROM financial_transactions
),
last_balance AS (
	SELECT DISTINCT ON (account_id) account_id, account_balance
	FROM financial_transactions
	ORDER BY account_id, transaction_timestamp DESC
)
SELECT f.account_id, 
	/* Calculate days of inactivity relative to lastest date in dataset.*/
	(SELECT global_max_date::date FROM max_date_cte) - MAX(f.transaction_timestamp)::date AS recency,
	COUNT(f.transaction_id) AS frequency,
	l.account_balance AS total_aum
FROM financial_transactions f
JOIN last_balance l 
	ON f.account_id = l.account_id
	GROUP BY f.account_id, l.account_balance
	ORDER BY f.account_id;

