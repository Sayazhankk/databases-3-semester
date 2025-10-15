 --task1.1
 CREATE TABLE employees
 (
     employee_id INTEGER PRIMARY KEY,
 first_name
     TEXT NOT NULL,
 last_name
     TEXT NOT NULL,
 age
     INTEGER CHECK(AGE BETWEEN 18 AND 65),
 salary
     NUMERIC CHECK(salary > 0)
     );
--1.2
CREATE TABLE products_catalog
 (
     product_id INTEGER PRIMARY KEY,
 product_name
     TEXT NOT NULL,
 product_price
     NUMERIC ,
 discount_price
     NUMERIC ,
     CONSTRAINT valid_discount
 CHECK(
     regular_price>0
     AND dicount_price>0
     AND discount_price<regular_price
     )

     );
--1.3
CREATE TABLE bookings
 (
     booking_id INTEGER PRIMARY KEY,
 check_in_date
     DATE NOT NULL ,
 check_out_date
     DATE NOT NULL ,
num_guests
 INTEGER CHECK( num_guests BETWEEN 1 AND 10)
 CHECK ( check_out_date > check_in_date)
     );
--1.4
INSERT INTO employees(employee_id, first_name, last_name, age, salary)
VALUES (1,'Tony','Stark',17,-1);
INSERT INTO products_catalog(product_id, product_name, product_price, discount_price)
VALUES (24,'soap',54,62);
INSERT INTO bookings(booking_id, check_in_date, check_out_date, num_guests)
VALUES (5,'2024-10-15','2023-10-15',15);
--all constraints are violated except product_price and discount_price,because the values I wrote doesnt meet the requirements
--2.1
CREATE TABLE customers
 (
     customer_id INTEGER  NOT NULL ,
 email
     TEXT NOT NULL ,
 phone
     TEXT ,
registration_date
 DATE NOT NULL
     );
--2.2
CREATE TABLE inventory
 (
     item_id INTEGER  NOT NULL ,
 item_name
     TEXT NOT NULL ,
 quantity
    INTEGER NOT NULL CHECK( quantity>=0) ,
     unit_price
    NUMERIC NOT NULL CHECK( unit_price>=0) ,
last_updated
 TIMESTAMP NOT NULL
     );
-2.3
INSERT INTO customers(customer_id, email, phone, registration_date)
VALUES (1,'saya@mail.ru','777772546225,'2025-10-14);
INSERT INTO inventory(item_id, item_name, quantity, unit_price, last_updated)
VALUES (101,'item',10,99,CURRENT_TIMESTAMP);
-3.1
CREATE TABLE users(
    user_id INTEGER,
    username TEXT UNIQUE ,
    email TEXT UNIQUE ,
    created_at TIMESTAMP
);
--3.2
CREATE TABLE course_enrollments(
    enrollmet_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id,course_code,semester)
);
-3.3
ALTER TABLE users
ADD CONSTRAINT  unique_username UNIQUE  (username);
ALTER TABLE users
ADD CONSTRAINT  unique_email UNIQUE  (email);
INSERT INTO users (user_id, username, email, created_at)
VALUES (1, 'tony', 'tony@stark.com', CURRENT_TIMESTAMP);

INSERT INTO users (user_id, username, email, created_at)
VALUES (2, 'tonya', 'tony@stark.com', CURRENT_TIMESTAMP);
-4.1
CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY ,
    depr_ame TEXT NOT NULL ,
    location TEXT
);
INSERT INTO departments(dept_id, depr_ame, location)
VALUES (2,'tony','house');
INSERT INTO departments(dept_id, depr_ame, location)
VALUES (2,'lol','home');
INSERT INTO departments(dept_id, depr_ame, location)
VALUES (NULL,'ony','dom');

--4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);
--4.3
--PRIMARY KEY can not contain NULL ,while UNIQUE can
--single column when one column uniqely identifies each record and composite when single column is not enough
--only one primary key because it defines the main way to identify each record
--5.1
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES
(101, 'Alice', 1, '2022-05-10'),
(102, 'Bob ', 2, '2023-03-14'),
(103, 'Kim', 3, '2024-01-20');
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (104,  Lee', 99, '2024-10-14'');
--5.2

    CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors (author_id, author_name, country)
VALUES
(1, ' Rowling', 'United Kingdom');
INSERT INTO publishers(publisher_id, publisher_name, city)
VALUES (2,'Abay','almaty');
INSERT INTO  books(book_id, title, author_id, publisher_id, publication_year, isbn)
VALUES (103, 'Kafka on the Shore', 3, 3, 2002, '9781400079278');
--5.3
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);
DELETE FROM categories WHERE category_id = 1; --Prevents deletion if referenced
DELETE FROM orders WHERE order_id = 1001; --Automatically deletes dependent rows
--6.1
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0) NOT NULL,
    stock_quantity INTEGER CHECK (stock_quantity >= 0) NOT NULL
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) NOT NULL
);
CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER CHECK (quantity > 0) NOT NULL,
    unit_price NUMERIC CHECK (unit_price >= 0) NOT NULL
);

