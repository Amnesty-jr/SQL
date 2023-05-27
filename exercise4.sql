CREATE TABLE denormalized (
    product_id bigint,
    product_name text,
    aisle_id integer,
    department_id bigint,
    aisle text,
    order_id bigint,
    user_id bigint,
    order_dow integer,
    order_hour_of_day integer,
    days_since_prior_order integer,
    department text
);


SELECT * FROM denormalized


CREATE VIEW product_view AS 
SELECT DISTINCT (product_id),
	   product_name,
	   aisle_id,
	   department_id
FROM denormalized
ORDER BY product_id;


CREATE VIEW order_view AS 
SELECT DISTINCT (order_id),
       user_id,
	   order_dow,
	   order_hour_of_day,
	   days_since_prior_order,
	   product_id
FROM denormalized
ORDER BY order_id


CREATE VIEW aisle_view AS 
SELECT DISTINCT (aisle_id),
	   aisle
FROM denormalized
ORDER BY aisle_id


CREATE VIEW department_view AS 
SELECT DISTINCT (department_id),
       department
FROM denormalized
ORDER BY department_id


--CREATE THE TABLES TO TRANSFER THE VIEWS INTO

CREATE TABLE department (
    department_id bigint PRIMARY KEY,
    department VARCHAR (25));


CREATE TABLE aisles (
    aisle_id bigint PRIMARY KEY,
    aisle text);

CREATE TABLE products (
    product_id bigint PRIMARY KEY,
    product_name text,
    aisle_id bigint REFERENCES aisles (aisle_id),
    department_id bigint REFERENCES department (department_id)
);


CREATE TABLE orders (
    order_id bigint PRIMARY KEY,
    user_id bigint,
    order_dow integer,
    order_hour_of_day integer,
    days_since_prior_order integer,
    product_id bigint REFERENCES products (product_id)
);


--INSERT THE VIEW INTO THE CREATED TABLES

INSERT INTO department (department_id, department)
SELECT department_id,
	   department
FROM department_view
ORDER BY department_id;

INSERT INTO aisles (aisle_id, aisle)
SELECT DISTINCT aisle_id, 
       aisle
FROM aisle_view order BY aisle_id;

INSERT INTO products (product_id, product_name, aisle_id, department_id)
SELECT product_id, 
	   product_name,
	   aisle_id,
	   department_id
FROM product_view ORDER BY product_id;

INSERT INTO orders (order_id, user_id, order_dow, order_hour_of_day, days_since_prior_order, product_id)
SELECT DISTINCT (order_id), 
	   user_id,
	   order_dow,
	   order_hour_of_day,
	   days_since_prior_order,
	   product_id
FROM denormalized ORDER BY order_id;


--Questions

--1. On which day/s of the week are condoms mostly sold?
With WeekDays AS (
			SELECT p.product_id, 
				   p.product_name,
				   order_dow
			FROM orders o
			JOIN products p on o.product_id = p.product_id
			WHERE p.product_name ILIKE '%Condoms%'
	)

SELECT CASE
		  WHEN order_dow = 0 THEN 'Sunday'
	      WHEN order_dow = 1 THEN 'Monday'
		  WHEN order_dow = 2 THEN 'Tuesday'
		  WHEN order_dow = 3 THEN 'Wednesday'
		  WHEN order_dow = 4 THEN 'Thursday'
		  WHEN order_dow = 5 THEN 'Friday'
		  WHEN order_dow = 6 THEN 'Saturday'
		  END AS days_of_week,
	  COUNT (order_dow) as Totalsales		
FROM WeekDays
GROUP BY order_dow
ORDER BY Totalsales DESC

--2. At what time of the day is it mostly sold?
SELECT o.order_hour_of_day, COUNT(*) as num_sales
FROM products p
JOIN aisles a ON a.aisle_id = p.aisle_id
JOIN orders o ON p.product_id = o.product_id
JOIN department d ON p.department_id = d.department_id
WHERE p.product_name ILIKE '%Condom%'
GROUP BY o.order_hour_of_day
ORDER BY num_sales DESC
LIMIT 1;

--3. What type of condom do the customers prefer?
SELECT p.product_name, COUNT(product_name) as num_sales
FROM products p
JOIN aisles a ON a.aisle_id = p.aisle_id
JOIN orders o ON p.product_id = o.product_id
JOIN department d ON p.department_id = d.department_id
WHERE p.product_name ILIKE '%Condom%'
GROUP BY p.product_name
ORDER BY num_sales DESC
LIMIT 1;

--4. Which aisle contains most of the organic products?
With aislecount AS(
				SELECT a.aisle, product_name
				FROM aisles a
				JOIN products p on a.aisle_id = p.aisle_id
				WHERE p.product_name ILIKE '%Organic%'
				)

SELECT aisle, COUNT(product_name) AS Totalnum
FROM aislecount
GROUP BY aisle
ORDER BY Totalnum DESC
LIMIT 1;

--5. Which aisle/s can I find all the non-alcoholic drinks?
SELECT a.aisle, COUNT(*) AS num_non_alcoholic_drinks, 
       string_agg(DISTINCT p.product_name, ', ') AS non_alcoholic_drinks
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN department d ON p.department_id = d.department_id
WHERE p.product_name ILIKE '%non-alcoholic%' 
OR p.product_name ILIKE '%non alcoholic%' 
OR p.product_name ILIKE '%non alcohol%'
OR p.product_name ILIKE '%no alcohol%'
GROUP BY a.aisle
ORDER BY num_non_alcoholic_drinks DESC;


-- PHASE 2
-- I was given another table to load into the database so as to Answer some Questions
CREATE TEMPORARY TABLE order_date_status(
			order_id bigint,		
			order_date date,
			order_status varchar(25)
			);
			 
COPY order_date_status FROM 'C:\Users\HP\Desktop\Bootcamp\All SQL asss/order_date_status.csv'		 
			 WITH(FORMAT CSV, HEADER true);

ALTER TABLE orders
ADD order_date date,
ADD order_status varchar(25)


UPDATE orders as o
SET order_date = t.order_date,
	order_status = t.order_status
FROM order_date_status t
WHERE o.order_id = t.order_id
			 
				
CREATE TABLE product_cost_price(
			product_id int not null,
			unit_cost numeric(5,2) not null,
	  		unit_price numeric(5,2) not null,
			FOREIGN KEY(product_id) REFERENCES products (product_id));