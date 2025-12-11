--creating tables
--costumers
CREATE TABLE customers (  
    customer_id SERIAL PRIMARY KEY,  
    iin VARCHAR(12) UNIQUE NOT NULL,   
    full_name TEXT NOT NULL,  
    phone TEXT,  
    email TEXT,  
    status TEXT CHECK (status IN ('active', 'blocked', 'frozen')) DEFAULT 'active',  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    daily_limit_kzt NUMERIC DEFAULT 1000000  
);
--accounts
CREATE TABLE accounts (  
    account_id SERIAL PRIMARY KEY,  
    customer_id INTEGER REFERENCES customers(customer_id),  
    account_number TEXT UNIQUE NOT NULL, -- i made them start with KZ cuz its cute  
    currency TEXT CHECK (currency IN ('KZT','USD','EUR','RUB')),  
    balance NUMERIC DEFAULT 0,  
    is_active BOOLEAN DEFAULT TRUE,  
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    closed_at TIMESTAMP  
);
--transactions
CREATE TABLE transactions (  
    transaction_id SERIAL PRIMARY KEY,  
    from_account_id INTEGER REFERENCES accounts(account_id),  
    to_account_id INTEGER REFERENCES accounts(account_id),  
    amount NUMERIC NOT NULL,  
    currency TEXT NOT NULL,  
    exchange_rate NUMERIC,  
    amount_kzt NUMERIC,  
    type TEXT CHECK (type IN ('transfer','deposit','withdrawal')),  
    status TEXT CHECK (status IN ('pending','completed','failed','reversed')) DEFAULT 'pending',  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    completed_at TIMESTAMP,  
    description TEXT  
);
--exchange_rates
CREATE TABLE exchange_rates (  
    rate_id SERIAL PRIMARY KEY,  
    from_currency TEXT NOT NULL,  
    to_currency TEXT NOT NULL,  
    rate NUMERIC NOT NULL,  
    valid_from TIMESTAMP NOT NULL,  
    valid_to TIMESTAMP  
);
-- audit log
CREATE TABLE audit_log (  
    log_id SERIAL PRIMARY KEY,  
    table_name TEXT NOT NULL,  
    record_id BIGINT NOT NULL,  
    action TEXT CHECK (action IN ('INSERT','UPDATE','DELETE')),  
    old_values JSONB,  
    new_values JSONB,  
    changed_by TEXT,  
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    ip_address TEXT  
);
--insert data
INSERT INTO customers (iin, full_name, phone, email, status) VALUES  
('900101300001', 'Ainur', '+77771112233', 'ainur@mail.com', 'active'),  
('900101300002', 'Diana', '+77772223344', 'diana@mail.com', 'active'),  
('900101300003', 'Kamila', '+77773334455', 'kamila@mail.com', 'blocked'),  
('900101300004', 'Madina', '+77774445566', 'madina@mail.com', 'active'),  
('900101300005', 'Sabina', '+77775556677', 'sabina@mail.com', 'frozen'),  
('900101300006', 'Tomiris', '+77776667788', 'tomiris@mail.com', 'active'),  
('900101300007', 'Zere', '+77777778899', 'zere@mail.com', 'active'),  
('900101300008', 'Aruzhan', '+77778889900', 'aruzhan@mail.com', 'active'),  
('900101300009', 'Aigerim', '+77779990011', 'aigerim@mail.com', 'active'),  
('900101300010', 'Symbat', '+77770001122', 'symbat@mail.com', 'active');

INSERT INTO accounts (customer_id, account_number, currency, balance) VALUES  
(1, 'KZ860000000000000001', 'KZT', 5000000),  
(1, 'KZ860000000000000002', 'USD', 10000),  
(2, 'KZ860000000000000003', 'EUR', 5000),  
(3, 'KZ860000000000000004', 'RUB', 100000),  
(4, 'KZ860000000000000005', 'KZT', 3000000),  
(5, 'KZ860000000000000006', 'USD', 2000),  
(6, 'KZ860000000000000007', 'KZT', 800000),  
(7, 'KZ860000000000000008', 'EUR', 7000),  
(8, 'KZ860000000000000009', 'RUB', 50000),  
(9, 'KZ860000000000000010', 'KZT', 10000000);

INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description) VALUES
(1, 2, 100000, 'KZT', 1, 100000, 'transfer', 'completed', 'Test transfer'),
(2, 3, 100, 'USD', 450, 45000, 'transfer', 'completed', 'Test'),
(3, 4, 50, 'EUR', 500, 25000, 'transfer', 'failed', 'Insufficient funds'),
(4, 5, 5000, 'RUB', 6, 30000, 'deposit', 'completed', 'Deposit'),
(5, 6, 200000, 'KZT', 1, 200000, 'withdrawal', 'completed', 'Withdrawal'),
(6, 7, 200, 'USD', 450, 90000, 'transfer', 'reversed', 'Reversed transfer'),
(7, 8, 100, 'EUR', 500, 50000, 'transfer', 'completed', 'Test'),
(8, 9, 10000, 'RUB', 6, 60000, 'transfer', 'completed', 'Test'),
(9, 10, 300000, 'KZT', 1, 300000, 'transfer', 'completed', 'Test'),
(10, 1, 300, 'USD', 450, 135000, 'transfer', 'completed', 'Test');

INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to) VALUES
('USD', 'KZT', 450, '2023-01-01', NULL),
('EUR', 'KZT', 500, '2023-01-01', NULL),
('RUB', 'KZT', 6, '2023-01-01', NULL),
('KZT', 'USD', 1/450, '2023-01-01', NULL),
('KZT', 'EUR', 1/500, '2023-01-01', NULL),
('KZT', 'RUB', 1/6, '2023-01-01', NULL),
('USD', 'EUR', 0.9, '2023-01-01', NULL),
('EUR', 'USD', 1/0.9, '2023-01-01', NULL),
('USD', 'RUB', 75, '2023-01-01', NULL),
('RUB', 'USD', 1/75, '2023-01-01', NULL);

INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by, ip_address) VALUES
('transactions', 1, 'INSERT', NULL, ' 100000', 'system', '127.0.0.1'),
('transactions', 2, 'INSERT', NULL, '100', 'system', '127.0.0.1'),
('transactions', 3, 'INSERT', NULL, '50', 'system', '127.0.0.1'),
('transactions', 4, 'INSERT', NULL, '500', 'system', '127.0.0.1'),
('transactions', 5, 'INSERT', NULL, '20', 'system', '127.0.0.1'),
('transactions', 6, 'INSERT', NULL, '200', 'system', '127.0.0.1'),
('transactions', 7, 'INSERT', NULL, '2000', 'system', '127.0.0.1'),
('transactions', 8, 'INSERT', NULL, '1000', 'system', '127.0.0.1'),
('transactions', 9, 'INSERT', NULL, '30', 'system', '127.0.0.1'),
('transactions', 10, 'INSERT', NULL, '300', 'system', '127.0.0.1');

--task1
CREATE OR REPLACE PROCEDURE process_transfer(
    from_acc TEXT,
    to_acc TEXT,
    amt NUMERIC,
    cur TEXT,
    descr TEXT DEFAULT ''
)
LANGUAGE plpgsql AS $$
DECLARE
    from_id INT; to_id INT; from_bal NUMERIC; from_cur TEXT; rate NUMERIC := 1;
    amt_kzt NUMERIC;
BEGIN
    -- validate both accs
    SELECT account_id, balance, currency INTO from_id, from_bal, from_cur
    FROM accounts WHERE account_number = from_acc AND is_active FOR UPDATE;

    SELECT account_id INTO to_id
    FROM accounts WHERE account_number = to_acc AND is_active FOR UPDATE;

    IF from_id IS NULL OR to_id IS NULL THEN
        RAISE EXCEPTION 'account not found or inactive';
    END IF;

    IF cur != from_cur THEN
        RAISE EXCEPTION 'Wrong currency';
    END IF;

    -- exchange 
    rate := CASE cur WHEN 'USD' THEN 480 WHEN 'EUR' THEN 520 ELSE 1 END;
    amt_kzt := amt * rate;

    -- checks
    IF from_bal < amt THEN RAISE EXCEPTION 'Not enough money'; END IF;

    -- daily limit check
    IF (SELECT COALESCE(SUM(amount_kzt),0) FROM transactions
        WHERE from_account_id = from_id AND created_at::date = CURRENT_DATE) + amt_kzt
       > (SELECT daily_limit_kzt FROM customers c JOIN accounts a ON c.customer_id=a.customer_id WHERE a.account_id=from_id)
    THEN
        RAISE EXCEPTION 'Daily limit exceeded';
    END IF;

    --  transfer
    UPDATE accounts SET balance = balance - amt WHERE account_id = from_id;
    UPDATE accounts SET balance = balance + amt * rate WHERE account_id = to_id;

    INSERT INTO transactions (from_account_id, to_account_id, amount, currency, amount_kzt, type, status, description)
    VALUES (from_id, to_id, amt, cur, amt_kzt, 'transfer', 'completed', descr);

    RAISE NOTICE 'Transfer OK!';
END;
$$;
--savepoint
SAVEPOINT sp_transfer;
--updates
BEGIN
        UPDATE accounts SET balance = balance - amt WHERE account_id = from_id;
        UPDATE accounts SET balance = balance + (amt * CASE accounts.currency WHEN 'USD' THEN 1/480 WHEN 'EUR' THEN 1/520 ELSE 1 END) WHERE account_id = to_id;
--task2
--custumer_balance_summary
CREATE VIEW customer_balance_summary AS
SELECT c.customer_id, 
c.full_name, 
COUNT(a.account_id) as num_accounts,
       SUM(a.balance * CASE a.currency WHEN 'USD' THEN 480 WHEN 'EUR' THEN 520 ELSE 1 END) AS total_kzt,
       RANK() OVER (ORDER BY SUM(a.balance * CASE a.currency WHEN 'USD' THEN 480 WHEN 'EUR' THEN 520 ELSE 1 END) DESC) as rank
FROM customers c JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.full_name;
--daily_transaction_report
CREATE VIEW daily_transaction_report AS
SELECT created_at::date as day, type, COUNT(*) as count, SUM(amount_kzt) as total_kzt,
       SUM(SUM(amount_kzt)) OVER (ORDER BY created_at::date) as running_total
FROM transactions WHERE status = 'completed'
GROUP BY day, type
ORDER BY day DESC;
--suspicious_activity_view
CREATE VIEW suspicious_activity_view WITH (security_barrier) AS
SELECT t.transaction_id, t.amount_kzt, t.from_account_id,
       CASE WHEN t.amount_kzt > 5000000 THEN 'High Value' ELSE 'Normal' END as flag
FROM transactions t WHERE status = 'completed';
--task3
CREATE INDEX idx_accounts_number ON accounts(account_number);
--hash on iin
CREATE INDEX idx_customers_iin_hash ON customers USING hash(iin);
--partial on active
CREATE INDEX idx_active_accounts ON accounts(customer_id) WHERE is_active;
--composite for reports
CREATE INDEX idx_tx_date_type ON transactions(created_at, type);
--GIN on JSON
ALTER TABLE customers ADD COLUMN email TEXT;
CREATE INDEX idx_email_lower ON customers(LOWER(email));
--task4
CREATE OR REPLACE PROCEDURE process_salary_batch(
    company_acc TEXT,
    payments JSONB
)
LANGUAGE plpgsql AS $$
DECLARE
    r JSONB; emp_acc TEXT; amt NUMERIC; iin TEXT; success_cnt INT := 0; fail_cnt INT := 0; fails JSONB := '[]';
    lock_key BIGINT := 12345;  
BEGIN
-- Advisory lock
    IF NOT pg_try_advisory_lock(lock_key) THEN
        RAISE EXCEPTION 'Batch locked';
    END IF;

    SAVEPOINT sp_batch; 
    FOR r IN SELECT * FROM jsonb_array_elements(payments)
    LOOP
        iin := r->>'iin';
        amt := (r->>'amount')::NUMERIC;

        SAVEPOINT sp_payment;  -- Per payment 

        BEGIN
            SELECT account_number INTO emp_acc
            FROM customers c JOIN accounts a ON c.customer_id = a.customer_id
            WHERE c.iin = iin AND a.currency = 'KZT' AND a.is_active LIMIT 1;

            IF emp_acc IS NULL THEN RAISE EXCEPTION 'No account'; END IF;

            -- Call transfer 
            PERFORM process_transfer(company_acc, emp_acc, amt, 'KZT', 'Salary - bypass limit');

            success_cnt := success_cnt + 1;
        EXCEPTION WHEN OTHERS THEN
            ROLLBACK TO sp_payment;  -- Rollback this payment only
            fail_cnt := fail_cnt + 1;
            fails := fails || jsonb_build_object('iin', iin, 'error', SQLERRM);
        END;
    END LOOP;

    -- Release lock
    PERFORM pg_advisory_unlock(lock_key);

    RAISE NOTICE 'Success: %, Fail: %, Fails: %', success_cnt, fail_cnt, fails;

    COMMIT;
END;
$$;

-- tests
-- success
CALL process_transfer('KZ111111111111111111','KZ222222222222222222',100000,'KZT','test');
-- fail 
CALL process_transfer('KZ111111111111111111','KZ222222222222222222',99999999,'KZT','fail');

