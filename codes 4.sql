CREATE TABLE department(
			department_id int not null PRIMARY KEY,
			department varchar(50) not null)
			
CREATE TABLE aisles(
			aisle_id int not null PRIMARY KEY,
			aisle varchar(50) not null,
			department_id int not null,
			FOREIGN KEY(department_id) REFERENCES department(department_id))
	

CREATE TABLE product(
			product_id int not null PRIMARY KEY,
			product_name varchar(225) not null,		
			department_id int not null,
			aisle_id int not null,
			FOREIGN KEY(department_id) REFERENCES department(department_id),
			FOREIGN KEY(aisle_id) REFERENCES aisles(aisle_id))
			
	
CREATE TABLE orders(
			order_id int not null PRIMARY KEY,		
			product_id int not null,
			user_id int not null,
			order_dow varchar(25) not null,		
			order_hour_of_day int not null,
			days_since_prior_order int not null,
			FOREIGN KEY(product_id) REFERENCES product(product_id))		
	
	
drop table product cascade	
select * from orders
select * from department
select * from product
select * from aisles


----1. On which day/s of the week are condoms mostly sold
With WeekDays AS (
			SELECT p.product_id, p.product_name, order_dow
			FROM orders o
			JOIN product p on o.product_id = p.product_id
			WHERE p.product_name like '%Condoms%'
	)

SELECT order_dow, count(order_dow) as Totalsales
FROM WeekDays
GROUP BY order_dow
ORDER BY Totalsales DESC


--2. At what time of the day is condoms mostly sold

With Time as (
			SELECT p.product_id, p.product_name,o.order_hour_of_day
			FROM orders o
			JOIN product p on o.product_id = p.product_id
			WHERE p.product_name LIKE '%Condoms%'
)

SELECT order_hour_of_day, COUNT(order_hour_of_day) as Hours
FROM Time
GROUP BY order_hour_of_day
ORDER BY Hours DESC


--3.What type of condom do the customers prefer?

With preferred AS(
				SELECT o.order_id, product_name
				FROM orders o
				JOIN product p on o.product_id = p.product_id
				WHERE p.product_name LIKE '%Condoms%'
)

SELECT product_name ,count(product_name) as Totalnum
FROM preferred
GROUP BY product_name
ORDER BY Totalnum desc

--4. Which aisle contains most of the organic products?

With aislecount AS(
				SELECT a.aisle, product_name
				FROM aisles a
				JOIN product p on a.aisle_id = p.aisle_id
				WHERE p.product_name LIKE '%Organic%'
)

SELECT aisle, COUNT(product_name) AS Totalnum
FROM aislecount
GROUP BY aisle
ORDER BY Totalnum DESC

---5. Which aisle/s can i find all the non-alcoholic drinks?

SELECT a.aisle, d.department
FROM aisles a
JOIN department d on a.department_id = d.department_id
WHERE d.department in ('beverages');

