/* The Online Shop Database based on the schema diagram shown in the report. Adapted UML notation is from the textbook 
"Database System Concepts" by A. Silberschatz, H.F. Korth and S. Sudarshan, McGraw-Hill International Edition, 
Sixth Edition, 2011. 
OnlineShopDB.sql is a script for creating tables for the Online Shop database and populating them with data */

/* If the tables already exists, then they are deleted! */
DROP TABLE IF EXISTS Deals;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Rating;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS City;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Orders;

/* Table creation! Create Tables with Foreign Keys after the referenced tables are created! */

CREATE TABLE Customer
	(
    customer_id		INT NOT NULL AUTO_INCREMENT,
    customer_first_name VARCHAR(50),
    customer_last_name VARCHAR(50),
    customer_phone VARCHAR(8),
    customer_zipcode INT(4),
    customer_address VARCHAR(50),
    customer_email VARCHAR(50),
    customer_accept_news BOOLEAN,
    PRIMARY KEY(customer_id)
    );

CREATE TABLE Orders 
   (order_id 			INT NOT NULL AUTO_INCREMENT,
	customer_id 		INT,
	order_date 			DATETIME,
	order_approval 		BOOLEAN,
	order_shipped 		DATETIME,
	order_total_price 	DECIMAL(8,2),
	order_payment_info 	ENUM("mobilepay","visa","paypal","mastercard", "transaction"),
	PRIMARY KEY(order_id),
	FOREIGN KEY(customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL
    ); #when deleted we could also delete customer, but customer might have more
    #than one order, so shouldn't be deleted.

CREATE TABLE Product
	(product_id		INT NOT NULL AUTO_INCREMENT,
	 product_date	DATE,
     product_type 	ENUM("pants","tshirt","sweater","hoodie","dress","shirt","jacket","tops","unspecified"), 
	 product_name	VARCHAR(50),
     product_price	DECIMAL(8,2),
     product_stock  INT,
	 product_brand	ENUM("bsosdesign","adidas","nike","calvinklein","boohoo","zara","obey","veromoda","levis"),
	 PRIMARY KEY(product_id)
	);

CREATE TABLE Deals
	(deal_id		INT NOT NULL AUTO_INCREMENT, 
     product_id		INT,
	 discount		DECIMAL(1,2), 
	 deal_starts	DATETIME, 
	 deal_expires	DATETIME,
	 PRIMARY KEY(deal_id),
	 FOREIGN KEY(product_id) REFERENCES Product(product_id) ON DELETE SET NULL
	);

CREATE TABLE OrderItem
	(order_id INT,
    product_id INT,
    order_item_quantity INT,
    PRIMARY KEY(product_id, order_id),
    FOREIGN KEY(product_id) REFERENCES Product(product_id) ON DELETE SET NULL,
	FOREIGN KEY(order_id) REFERENCES Orders(order_id) ON DELETE SET NULL
    );

CREATE TABLE Rating
	(product_id		INT,
	 customer_id	INT,
     rating_quality ENUM("1","2","3","4","5"), 
	 rating_fit		ENUM("1","2","3","4","5"),
     rating_review	CHAR(500),
     PRIMARY KEY(product_id, customer_id),
     FOREIGN KEY(product_id) REFERENCES Product(product_id) ON DELETE SET NULL,
     FOREIGN KEY(customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL
	);


CREATE TABLE City
	(customer_zipcode INT(4),
    city_name VARCHAR(50),
    PRIMARY KEY(customer_zipcode),
    FOREIGN KEY(customer_zipcode) REFERENCES Customer(customer_zipcode) ON DELETE SET NULL
    );


/* Insertion of table rows one by one! */

INSERT Product VALUES
('2018-12-09 12:15:00','sweater','','Painter','514','B'),



CREATE TABLE Product
	(product_id		INT NOT NULL AUTO_INCREMENT,
	 product_date	DATE,
     product_type 	ENUM("pants","shorts","tshirt","sweater","hoodie","dress","shirt","jacket","tops","unspecified"), 
	 product_name	VARCHAR(50),
     product_price	DECIMAL(8,2),
     product_stock  INT,
	 product_brand	ENUM("bsosdesign","adidas","nike","calvinklein","boohoo","zara","obey","veromoda","levis"),
	 PRIMARY KEY(product_id)
	);
    
    
#ENUM til type og brand
#ENUM til order_payment_info

