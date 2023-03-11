CREATE TABLE customers(
			customer_id int PRIMARY KEY,
			customer_name varchar(50) NOT NULL,
			email varchar(50) NOT NULL,
			phone varchar(50) NOT NULL);
			
CREATE TABLE orders(
			order_id int PRIMARY KEY,
			customer_id int NOT NULL,
			order_date date NOT NULL,
			product_id int NOT NULL,
			quantity int NOT NULL,
			delivery_status varchar(50) NOT NULL,
			FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
			FOREIGN KEY (product_id) REFERENCES products(product_id));
			
CREATE TABLE products(
			product_id int PRIMARY KEY,
			product_name varchar(50) NOT NULL,
			description varchar(225) NOT NULL,
			product_category varchar(100) NOT NULL,
			unit_price numeric(7,2) NOT NULL);
		
CREATE TABLE payment(
			payment_id int PRIMARY KEY,
			order_id int NOT NULL,
			payment_date date NOT NULL,
			FOREIGN KEY (order_id) REFERENCES orders(order_id));