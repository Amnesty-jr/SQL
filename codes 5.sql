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
					
CREATE TABLE order_date_status(
			order_id int not null,		
			order_date date not null,
			order_status text not null,
			FOREIGN KEY(order_id) REFERENCES orders(order_id))
			 
				
CREATE TABLE product_cost_price(
			product_id int not null,
			unit_cost numeric(5,2) not null,
	  		unit_price numeric(5,2) not null,
			FOREIGN KEY(product_id) REFERENCES product(product_id))
			


select * from order_date_status
select * from product_cost_price
select * from product
select * from orders

---1 How have the orders changed over time(monthly)

SELECT CASE DATE_PART('month', order_date) 
WHEN 1 THEN 'JANUARY'
WHEN 2 THEN 'FEBRUARY'
WHEN 3 THEN 'MARCH'
WHEN 4 THEN 'APRIL'
WHEN 5 THEN 'MAY'
WHEN 6 THEN 'JUNE'
WHEN 7 THEN 'JULY'
WHEN 8 THEN 'AUGUST'
WHEN 9 THEN 'SEPTEMBER'
WHEN 10 THEN 'OCTOBER'
WHEN 11 THEN 'NOVEMBER'
WHEN 12 THEN 'DECEMBER'
END AS MONTHS,
TO_CHAR(DATE_TRUNC('Year', order_date),'YYYY') AS Years,
COUNT(*) AS total_orders
FROM order_date_status
GROUP BY DATE_PART ('month', order_date), TO_CHAR(DATE_TRUNC ('Year', order_date),'YYYY')
ORDER BY Years

---2 Are they any weekly fluctuations in the size of orders?

SELECT CONCAT('Week',' ',DATE_PART('Week', order_date)) AS Week_num,
		DATE_PART('Year', order_date) AS Years, 
		COUNT(*) as Total_count
FROM order_date_status
GROUP BY date_part('Week', order_date), DATE_PART('Year', order_date)
ORDER BY Years

---3 What is the average number of orders placed by the day of the week

SELECT (SELECT COUNT(*) from orders)/COUNT(*) AS Average_orders, order_dow as Days
FROM orders
GROUP BY order_dow
ORDER BY Average_orders DESC


---4 What is the hour of the day with the highest number of orders?

SELECT order_hour_of_day as Hour_of_the_day, 
		COUNT(*) as Total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY Total_orders DESC
LIMIT 1

---5 Which department has the highest average spent per customer?

SELECT department, ROUND(AVG(unit_price),2) AS Average_spent
FROM department d
JOIN product p
ON d.department_id = p.department_id
JOIN product_cost_price pc
ON p.product_id = pc.product_id
GROUP BY department
ORDER BY average_spent DESC
LIMIT 1

--6 What product generated more profit

SELECT product_name, SUM(unit_price - unit_cost) AS Profit
FROM product p
JOIN product_cost_price pc
ON p.product_id = pc.product_id
JOIN orders o
ON o.product_id = pc.product_id
GROUP BY product_name
ORDER BY profit DESC
LIMIT 1


---7 What are the 3 aisles with the most orders, and which departments do these orders belong to

With Mostorders AS (
		SELECT aisle, o.order_id, department
		FROM aisles a
		JOIN department d on a.department_id = d.department_id
		JOIN product p on p.aisle_id = a.aisle_id
		JOIN orders o on o.product_id = p.product_id
)

SELECT aisle, COUNT(*) AS Totalorders, department
FROM Mostorders
GROUP BY aisle,department
ORDER BY Totalorders DESC
LIMIT 3
	
---8 Which 3 users generated the highest revenue and how many aisles did they order from

With Users AS (
			SELECT aisle, user_id, unit_price
			FROM aisles a
			JOIN product p on p.aisle_id= a.aisle_id
			JOIN orders o on o.product_id = p.product_id
			JOIN product_cost_price pc on pc.product_id = p.product_id

)
SELECT user_id, COUNT(*) as aislecount ,SUM(unit_price) AS Totalrevenue
FROM Users
GROUP BY user_id
ORDER BY Totalrevenue DESC
LIMIT 3


