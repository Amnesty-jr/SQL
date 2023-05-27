create table customers(
customer_id int not null primary key,
customer_name varchar(50) not null,
email varchar(50) not null,
phone varchar(25) not null
);

create table product(
product_id varchar(25) not null primary key,
product_name varchar(50) not null,
description varchar(100) not null,
product_category varchar(50) not null,
unit_price numeric(10,2) not null 
);

create table orders(
order_id int not null primary key,
customer_id int not null,
order_date date not null,
product_id varchar(25) not null,
quantity int not null,
delivery_status varchar(20) not null, 
	
foreign key (customer_id) references customers(customer_id),
foreign key (product_id) references product(product_id)
);

create table payment(
payment_id varchar(25) not null primary key,
order_id int not null,
payment_date date not null,

foreign key (order_id) references orders(order_id)
);

create table credit_card(
card_number numeric(15,0) not null primary key,
customer_id int not null,
card_expirydate date not null,
bank_name varchar(40) not null,
foreign key (customer_id) references customers(customer_id)
);

select * from orders;
select * from customers;
select * from product;
select * from payment;
select * from credit_card;


---Removing the records in orders and payment table
truncate orders cascade
truncate payment cascade


alter table product
add column unit_cost numeric(10,5);

alter table product
alter column unit_cost type numeric(10,4);

update product
set unit_cost= unit_price * 0.95;


select * from product where product_category like 'Health and Beauty';


---What is the sum of the product category, minimum unitprice, and also fetch the average of the product category
select product_category, min(unit_price), sum(unit_price), round(avg(unit_price),2)
from product
group by product_category
having sum(unit_price) > 500


select product_name, max(unit_price)as maximum_price
from product
group by product_name
order by maximum_price desc
limit 1

select product_name, min(unit_price) as minimum_price
from product
group by product_name
order by minimum_price desc
limit 1
 

---Find the highest priced products with their prices
select product_name, unit_price, 'Maximum_price' as price_category
from product
where unit_price = (select max(unit_price) from product)
union all
---Find the lowest priced products with their prices
select product_name, unit_price ,'Minimum_price' as price_category
from product
where unit_price = (select min(unit_price) from product)

--Adding year column to order table

ALTER TABLE orders
ADD years int

--Extracting the year from the order_date and filling up the year column

UPDATE orders
SET years = extract(year from order_date)

--Adding month column to order table

ALTER TABLE orders
add column months varchar(15)

--Extracting the month from the order_date and filling up the month column

UPDATE orders
SET months = to_char(order_date, 'Month')

--Find the total number of orders in each month in year 2022
SELECT months,SUM(quantity) AS total_order
FROM orders
WHERE years = 2022
GROUP BY months
ORDER BY SUM(quantity) DESC

--Find the Average unitprice and unitcost for each product category
Select product_category, round(avg(unit_price),2) as Averageunitprice, round(avg(unit_cost),2)as Averagecostprice
from product
group by product_category

--Find all orders that were placed on or after August 1, 2022
SELECT order_id,product_id, order_date
FROM orders
WHERE order_date >= '2022-08-01'

--Count the number of payments made on March/April 14,2023
SELECT Count(payment_id) as number_of_payment, payment_date
FROM payment
WHERE payment_date = '2023-03-12'
GROUP BY payment_date

--Which customer id has the highest orders placed in the order table
select customer_id, count(*) from orders
group by customer_id
order by count(*) desc

--What is the total number of orders made by each customer id
select customer_id, sum(quantity) from orders
group by customer_id
order by sum(quantity) desc


--How many orders were delivered between January and February 2023
Select count(order_id) as total_orders, months from orders
where order_date >= '2023-01-01'
and order_date < '2023-03-01'
group by months

----Creating a credit_card table

create table credit_card(
card_number numeric(15,0) not null primary key,
customer_id int not null,
card_expirydate date not null,
bank_name varchar(40) not null,
foreign key (customer_id) references customers(customer_id)
);

select * from credit_card

--Total number of cards that has expired 
Select count(*) Totalexpiredcard 
from credit_card
where card_expirydate < '2023-03-01'

--List of Card Informations that has expired 
Select *
from credit_card
where card_expirydate < '2023-03-01'
