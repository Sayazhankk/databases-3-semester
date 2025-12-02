
--3.1
CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);
--3.2
BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
COMMIT;
-- a)
--    Alice = 900.00
--    Bob   = 600.00
-- b) Both UPDATEs must be in one transaction to ensure atomicity
-- c) Without a transaction, a system crash
--3.3
BEGIN;
UPDATE accounts SET balance = balance - 500.00
 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
-- a) Alice’s balance after UPDATE (before rollback): 500.00
-- b) Alice’s balance after ROLLBACK: 1000.00
-- c) ROLLBACK is used to undo mistakes, incorrect inputs
--3.4
BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Wally';
COMMIT;
-- a)
--    Alice = 900.00
--    Bob   = 500.00
--    Wally = 850.00
-- b) Bob was credited temporarily
-- c) SAVEPOINT lets you undo part of a transaction without restarting the whole transaction
--3.5
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
--    Terminal 1 sees old data first, then sees new data after Terminal 2 commits.
-- b)
--    Terminal 1 always sees the original data; conflicting changes are blocked or cause errors.
-- c) READ COMMITTED allows non-repeatable reads; SERIALIZABLE prevents all anomalies.
--3.6\
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;
-- a) Under REPEATABLE READ, Terminal 1 does NOT see the new inserted row
-- b) new rows appear in repeated SELECT queries
-- c) SERIALIZABLE prevents phantom reads
--3.7
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
 WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;
-- a) Terminal 1 sees the uncommitted value 99.99, which is later rolled back — this is unsafe
-- b) reading data that has not been committed
-- c) READ UNCOMMITTED should be avoided because it allows reading invalid, temporary data
--4.1
BEGIN;

DO $$
DECLARE
    bob_balance DECIMAL;
BEGIN
    SELECT balance INTO bob_balance FROM accounts WHERE name='Bob';

    IF bob_balance < 200 THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
END $$;

UPDATE accounts
    SET balance = balance - 200
    WHERE name='Bob';

UPDATE accounts
    SET balance = balance + 200
    WHERE name='Wally';

COMMIT;
--4.2
BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('TestShop', 'Tea', 5.00);

SAVEPOINT s1;

UPDATE products SET price = 7.00
WHERE product='Tea';

SAVEPOINT s2;

DELETE FROM products
WHERE product='Tea';

ROLLBACK TO s1;

COMMIT;
--4.3
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name='Alice';
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
COMMIT;
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name='Alice';
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
COMMIT;
--4.4
T1: SELECT MAX(price) → 10
T2: UPDATE price=20
T1: SELECT MIN(price) → 30

BEGIN;
SELECT MAX(price), MIN(price);
COMMIT;