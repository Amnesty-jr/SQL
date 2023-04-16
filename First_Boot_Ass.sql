CREATE TABLE customers(
		customer_id int NOT null PRIMARY KEY,
		customer_name varchar(50) NOT NULL,
		email varchar(50) NOT NULL,
		phone varchar(25) NOT NULL);

CREATE TABLE orders(
		order_id int NOT NULL PRIMARY KEY,
		customer_id int NOT NULL,
		order_date date NOT NULL,
		product_id varchar(25) NOT NULL,
		quantity int NOT NULL,
		delivery_status varchar(20) NOT NULL, 	
		FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
		FOREIGN KEY (product_id) REFERENCES product(product_id));


CREATE TABLE product(
		product_id varchar(25) NOT NULL PRIMARY KEY,
		product_name varchar(50) NOT NULL,
		description varchar(100) NOT NULL,
		product_category varchar(50) NOT NULL,
		unit_price numeric(10,2) NOT NULL);

CREATE TABLE payment(
		payment_id varchar(25) NOT NULL PRIMARY KEY,
		order_id int NOT NULL,
		payment_date date NOT NULL,
		FOREIGN KEY (order_id) references orders(order_id));
		
SELECT *
FROM customers

ALTER TABLE product
ADD unit_cost numeric(10,2)

UPDATE product
SET unit_cost = (0.95 * unit_price)


CREATE TABLE credit_card(
			card_number numeric(15,0) NOT NULL,
			customer_id int NOT NULL,
			card_expiry_date date NOT NULL,
			bank_name varchar (100) NOT NULL,
			FOREIGN KEY (customer_id) REFERENCES customers(customer_id));

-- I want to find the highest and lowest price products along with their prices
SELECT product_name,
		unit_price
FROM product
where unit_price = (SELECT MAX(unit_price) from product)
or unit_price = (select MIN(unit_price) from product);

-- So according to the code above it was discoverd that furniture and health care are the highest and lowest priced products respectively.
SELECT DISTINCT(product_name),
	   unit_price
FROM product
WHERE product_name = 'Furniture'
AND product_name = 'Health care'

-- Find the total number of orders in each month in the year 2022
SELECT *
FROM orders

ALTER TABLE orders
ADD years int

UPDATE orders
SET years = extract(year from order_date)

ALTER TABLE orders
ADD months int

UPDATE orders
SET months = extract(month from order_date)


SELECT months,
       SUM(quantity) AS total_order
FROM orders
WHERE years = 2022
GROUP BY months
ORDER BY SUM(quantity) DESC


-- Find the average unit_price and unit_cost for each product category 
SELECT product_category,
	   ROUND(AVG(unit_price),2) AS Avg_price,
	   ROUND(AVG(unit_cost),2) AS Avg_cost
FROM product
GROUP BY product_category


--Find all orders that were placed on or after August 1, 2022
SELECT order_id,
	   product_id,
	   order_date
FROM orders
WHERE order_date >= '2022-08-01'


-- count the number of payments made on april 12,2023
SELECT Count(payment_id) AS number_of_payment,
	   payment_date
FROM payment
WHERE payment_date = '2023-04-12'
GROUP BY payment_date


-- Which customer_id has the highest order placed in the order table
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 1;

--What is the total number of orders made by each customer id.
SELECT customer_id, SUM(quantity) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC

--How many orders were delivered between Jan and Feb 2023?
SELECT COUNT(*) AS num_orders
FROM orders
WHERE delivery_status = 'delivered' 
  AND order_date >= '2023-01-01' 
  AND order_date < '2023-03-01';
  
--Retrieve all the information associated with the credit card that is next to expire from the “credit card" table?
SELECT *
FROM credit_card
WHERE card_expiry_date = (
  SELECT MIN(card_expiry_date)
  FROM credit_card
  WHERE card_expiry_date >= CURRENT_DATE
);

--how many have expired?
SELECT COUNT(*)
FROM credit_card
WHERE card_expiry_date < CURRENT_DATE;
