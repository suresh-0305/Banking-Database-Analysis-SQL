--CREATE A DATA BASE
-----------------------------------------------------
USE BankingDB;
GO
--ADD PRIMARY KEYS
----------------------------------------------------
ALTER TABLE branches
ADD CONSTRAINT PK_branches
PRIMARY KEY (branch_id);

ALTER TABLE accounts
ADD CONSTRAINT PK_accounts
PRIMARY KEY (account_id);

--Relation b/n tables using foreign keys
----------------------------------------------------
ALTER TABLE accounts
ADD CONSTRAINT FK_accounts_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

--ADD FOREIGN KEYS TO REFERENCES THE TABLES
ALTER TABLE accounts
ADD CONSTRAINT FK_accounts_branches
FOREIGN KEY (branch_id)
REFERENCES branches(branch_id);

ALTER TABLE cards
ADD CONSTRAINT FK_cards_accounts
FOREIGN KEY (account_id)
REFERENCES accounts(account_id);

ALTER TABLE loan_payments
ADD CONSTRAINT FK_loan_payments_loans
FOREIGN KEY (loan_id)
REFERENCES loans(loan_id);

ALTER TABLE loans
ADD CONSTRAINT FK_loans_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE loans
ADD CONSTRAINT FK_loans_branches
FOREIGN KEY (branch_id)
REFERENCES branches(branch_id);

ALTER TABLE transactions
ADD CONSTRAINT FK_transactions_accounts
FOREIGN KEY (account_id)
REFERENCES accounts(account_id);

--TOTAL NO.OF CUSTOMERS
SELECT COUNT(*) AS total_customers
FROM customers;

--TOTAL NO.OF ACCOUNTS
SELECT COUNT(*) AS total_accounts
FROM accounts;

--TO CHECK THE PK ADN FK IN THE TABLES
EXEC sp_help customers;
EXEC sp_help accounts;
EXEC sp_help cards;
EXEC sp_help branches;
EXEC sp_help loans;
EXEC sp_help loan_payments;
EXEC sp_help transactions;

--CLEAN AND CHECK THE DATA

--TO FIND NULL VALUES IN ALL TABLES

SELECT * FROM customers
WHERE customer_id IS NULL;

SELECT * FROM accounts
WHERE account_id IS NULL;

SELECT * FROM branches
WHERE branch_id IS NULL;

SELECT * FROM cards
WHERE card_id IS NULL;

SELECT * FROM loan_payments
WHERE payment_id IS NULL;

SELECT * FROM loans
WHERE loan_id IS NULL;

SELECT * FROM transactions
WHERE transaction_id IS NULL;

--TO FIND DUPLICATES IN ALL TABLES

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) >1;

SELECT account_id, COUNT(*) 
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT branch_id, COUNT(*) 
FROM branches
GROUP BY branch_id
HAVING COUNT(*) > 1;

SELECT card_id, COUNT(*)
FROM cards
GROUP BY card_id
HAVING COUNT(*) > 1;

SELECT payment_id, COUNT(*)
FROM loan_payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

SELECT loan_id,COUNT(*) 
FROM loans
GROUP BY loan_id
HAVING COUNT(*) > 1;

SELECT transaction_id, COUNT(*)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

--TOTAL CUSTOMERS IN THE BANK DATASET

SELECT  COUNT(*) AS total_customers
FROM customers;

--HOW MANY ACCOUNTS

SELECT COUNT(*) AS total_accont
FROM accounts;

--ACCOUNT TYPE IN BANK DATASET

SELECT DISTINCT account_type
FROM accounts;

--NUMBER OF ACCOUNTS BY TYPE

SELECT 
     account_type,COUNT(*) account_count
FROM accounts
GROUP BY account_type;

--TOTAL MONEY IN ACCOUNTS
SELECT 
     SUM(current_balance) AS total_balance
FROM accounts;

--AVG ACCOUNT BALANCE
SELECT 
     AVG(current_balance) AS avg_balance
FROM accounts;

--CUSTOMERS BY GENDER
SELECT 
       gender, 
       COUNT(*) AS customer_count
FROM  customers
GROUP BY gender;

--CUSTOMERS BY STATE
SELECT 
       state,
       COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

--CUSTOMERS BY CITY
SELECT 
        city,
        COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;

---JOIN ANALYSIS--
-----------------------------------------------
--CUSTOMER AND ACCOUNT INFO
SELECT 
     c.customer_id,
     c.first_name,
     a.account_id,
     a.account_type,
     a.current_balance
FROM customers c
JOIN accounts a
     ON c.customer_id = a.customer_id;

--CUSTOMERS WITH HIGHEST BALANCES

SELECT 
     c.customer_id,
     c.first_name,
     SUM(a.current_balance) AS total_balance
FROM customers c
JOIN accounts a 
    ON c.customer_id = a.customer_id
GROUP BY 
     c.customer_id,
     c.first_name
ORDER BY total_balance DESC;

--ACCOUNTS PER BRANCH

SELECT 
      b.branch_id,
      b.branch_name,
      COUNT(a.account_id) AS total_accounts
FROM branches b
LEFT JOIN accounts a
       ON b.branch_id = a.branch_id
GROUP BY
    b.branch_id,
    b.branch_name
ORDER BY total_accounts DESC;


--TOTAL BALANCE BY BRANCH

SELECT 
    b.branch_name,
    SUM(a.current_balance) AS total_balance
FROM branches b
JOIN accounts a
      ON b.branch_id = a.branch_id
GROUP BY b.branch_name
ORDER BY total_balance DESC;

--TOTAL TRANSATIONS

SELECT COUNT(*) AS total_transactions
FROM transactions;

--TOTAL TRANSATIONS AMMOUNT

SELECT SUM(amount) AS total_transaction_ammount
FROM transactions;

--TRANSACTIONS BY TYPE 

SELECT transaction_type,
     COUNT(*) AS total_trans,
     SUM(amount) AS total_trans_amout
FROM transactions
GROUP BY transaction_type
ORDER BY total_trans_amout DESC;


---MOST ACTIVE CUSTOMERS

SELECT 
    c.customer_id,
    c.first_name,
    COUNT(t.transaction_id) AS transaction_count
FROM customers c
JOIN accounts a
      ON c.customer_id = a.customer_id
JOIN transactions t
     ON a.account_id = t.account_id
GROUP BY
      c.customer_id,
      c.first_name
ORDER BY transaction_count DESC;
        
--TOTAL LOANS

SELECT COUNT(*) AS total_loans
FROM loans;

--TOTAL LOAN AMOUNT

SELECT 
     SUM(principal_amount) AS total_loan_amount
FROM loans;

--TOTAL AVG LOAN AMOUNT

SELECT
      AVG(principal_amount) AS avg_loan_amount
FROM loans;

--LOAN BY TYPE 

SELECT 
      loan_type,
      COUNT(*) AS loan_count,
      SUM(principal_amount) AS total_loan_amount
FROM loans
GROUP BY loan_type
ORDER BY total_loan_amount;

--LOAN REPAYMENT ANLAYSIS


SELECT 
    l.loan_id,
    l.customer_id,
    l.principal_amount,
    COALESCE(SUM(lp.paid_amount), 0) AS total_paid,
    l.principal_amount -
    COALESCE(SUM(lp.paid_amount),0) AS remaining_amount
FROM loans l
LEFT JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY 
         l.loan_id,
         l.customer_id,
        l. principal_amount;

--FIND THE CUSTOMERS WITH LOAN

SELECT 
     c.customer_id,
     c.first_name,
     COUNT(l.loan_id) AS number_of_loans,
     SUM(l.principal_amount) AS totla_loan_amount
FROM customers c
JOIN loans l
   on c.customer_id = l.customer_id
GROUP BY 
       c.customer_id,
       c.first_name
ORDER BY totla_loan_amount DESC;


--CARD ANALYSIS
----------------------------------------------------------------
--CARDS BY TYPE

SELECT card_type, COUNT(*) AS total_cards
FROM cards
GROUP BY card_type;

--CARD BY STATUS

SELECT is_active, COUNT(*) AS card_count
FROM cards
GROUP BY is_active;

--CUSTOMERS WITH MULTIPLE CARDS

--SELECT 
--     c.customer_id,
--    c.first_name,
   --  COUNT(cd.card_id) AS total_cards
--FROM customers c
--JOIN cards cd
 --   ON c.customer_id = cd.customer_id


--FIND CUSTOMERS WITH > 100,000:

WITH cutomer_balance AS 
(
   SELECT 
          c.customer_id,
          c.first_name,
          SUM(a.current_balance) AS total_balance
   FROM customers c
   JOIN accounts a
       ON c.customer_id = a.customer_id
   GROUP BY c.customer_id,
            c.first_name
    )
SELECT * FROM cutomer_balance
WHERE total_balance > 100000;

--RANKING THE CUSTOMERS

WITH cutomer_balance AS 
( 
   SELECT 
         c.customer_id,
         c.first_name,
         SUM(a.current_balance) AS total_balance
    FROM customers c
    JOIN accounts a
      ON c.customer_id = a.customer_id
    GROUP BY c.customer_id,
             c.first_name
)
SELECT 
      customer_id,
      first_name,
      total_balance,
      RANK() OVER(
          ORDER BY total_balance DESC
          ) AS balance_rank
  FROM cutomer_balance;


--CUSTOMERS WHOSE BALANCE IS ABOVE THE AVG
SELECT * FROM accounts
WHERE current_balance > ( 
       SELECT AVG(current_balance)
       FROM accounts );


--CUSTOMERS WHO HAVE A LOAN > THAN AVG LOAN

SELECT * FROM loans
WHERE principal_amount > (
    SELECT AVG(principal_amount) FROM loans)
    ORDER BY principal_amount DESC;



SELECT * FROM accounts;
