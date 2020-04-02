/* The Online Shop Database based on the schema diagram shown in the report. Adapted UML notation is from the textbook 
"Database System Concepts" by A. Silberschatz, H.F. Korth and S. Sudarshan, McGraw-Hill International Edition, 
Sixth Edition, 2011. 
OnlineShopDB.sql is a script for creating tables for the Online Shop database and populating them with data */

DROP DATABASE IF EXISTS BSOS;
CREATE DATABASE BSOS;

USE BSOS;

/* If the tables already exists, then they are deleted! */
DROP TABLE IF EXISTS Deals;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Rating;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS City;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Orders;

/* Table creation! Create Tables with Foreign Keys after the referenced tables are created! */

CREATE TABLE City
	(customer_zipcode INT(4) NOT NULL AUTO_INCREMENT,
    city_name VARCHAR(50),
    PRIMARY KEY(customer_zipcode)
    );

CREATE TABLE Customer
	(
    customer_id		INT NOT NULL AUTO_INCREMENT,
    customer_first_name VARCHAR(50),
    customer_last_name VARCHAR(50),
    customer_zipcode INT(4),
    customer_address VARCHAR(50),
    customer_phone VARCHAR(8),
    customer_email VARCHAR(50),
    customer_accept_news BOOLEAN,
    PRIMARY KEY(customer_id),
    FOREIGN KEY(customer_zipcode) REFERENCES City(customer_zipcode) ON DELETE SET NULL ON UPDATE CASCADE
    );

CREATE TABLE Orders 
   (order_id 			INT NOT NULL AUTO_INCREMENT,
	customer_id 		INT,
	order_date 			DATETIME,
	order_approval 		BOOLEAN,
	order_shipped 		DATETIME,
	order_payment_info 	ENUM("mobilepay","visa","paypal","mastercard", "transaction"),
	PRIMARY KEY(order_id),
	FOREIGN KEY(customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
    ); 
    /*when deleted we could also delete customer, but customer might have more
    than one order, so shouldn't be deleted.*/

CREATE TABLE Deals
	(
	 deal_id		INT NOT NULL AUTO_INCREMENT,
	 deal_discount		DECIMAL(3,2), 
	 deal_starts	DATETIME, 
	 deal_expires	DATETIME,
	 PRIMARY KEY(deal_id)
	);

CREATE TABLE Product
	(product_id		INT NOT NULL AUTO_INCREMENT,
	 product_date	DATE,
     product_type 	ENUM("pants","tshirt","sweater","hoodie","dress",
						"shirt","jacket","tops","unspecified"), 
	 product_name	VARCHAR(50),
     product_price	DECIMAL(8,2),
     product_stock  INT,
	 product_brand	ENUM("bsosdesign","adidas","nike","calvinklein",
						"boohoo","zara","obey","veromoda","levis"),
	 deal_id		INT,
	 PRIMARY KEY(product_id),
     FOREIGN KEY(deal_id) REFERENCES Deals(deal_id)
	);

CREATE TABLE OrderItem
	(order_id INT REFERENCES Product,
    product_id INT REFERENCES Orders,
    order_item_quantity INT,
    PRIMARY KEY(product_id, order_id)
    );


CREATE TABLE Rating
	(product_id		INT REFERENCES Product,
	 customer_id	INT REFERENCES Customer,
     rating_quality ENUM("1","2","3","4","5"), 
	 rating_fit		ENUM("1","2","3","4","5"),
     rating_review	CHAR(250),
     PRIMARY KEY(product_id, customer_id)
	);


/* Insertion of table rows one by one! */
INSERT Deals VALUES
(1, 0.50, '2018-01-01 7:00:00', '2018-01-05 17:00:00'),
(2, 0.10, '2019-05-01 7:00:00', '2018-05-10 17:00:00'),
(3, 0.20, '2020-02-10 7:00:00', '2018-02-20 17:00:00');

INSERT Product VALUES
(1,'2020-02-03','tops','sports top, just do it',300,20,'nike', NULL),
(2,'2019-11-06','jacket','comfy winter jacket',1200,30,'zara', NULL),
(3,'2019-01-16','tshirt','bsos basic tshirt darkblue',89,189,'bsosdesign', 2),
(4,'2019-01-16','tshirt','bsos basic tshirt black',89,200,'bsosdesign', 2),
(5,'2019-05-06','unspecified','denim underpants',100,2000,'bsosdesign', NULL),
(6,'2020-01-02','dress','boohoo colourful dress',280,40,'boohoo', NULL),
(7,'2019-12-09','shirt','casual shirt',600,20,'obey', NULL),
(8,'2019-07-09','pants','stretchy sports tights',449,50,'nike', 3),
(9,'2018-12-09','pants','bsos slim fit jeans',700,150,'bsosdesign', NULL),
(11,'2018-12-09','sweater','bsos christmas sweater',300,150,'bsosdesign', NULL),
(12,'2019-10-09','sweater','bsos wow theme recked bro, LIMITED EDITION',600,10,'bsosdesign', NULL),
(13,'2018-01-01','pants','very good pants',1200,0,'nike', 1);

INSERT City VALUES
(2850, 'Nærum'),
(2100, 'København Ø'),
(2300, 'København S'),
(4900, 'Nakskov'),
(9000, 'Aalborg'),
(4000, 'Roskilde'),
(2750, 'Ballerup'),
(2830, "Virum"),
(9999, 'Orgrimmar');

INSERT Customer VALUES
(1,'Christian', 'Glisov', 2830, 'Gammel Haslevvej 32',66778899, 'glissovsen@gmail.com', TRUE),
(2,'Mikkel', 'Grønning', 2100, 'Østerbro Alle 109',	'11223344', 'spam607@mail.com', FALSE),
(3,'Melina', 'Barhagh', 2300, 'Amager Road, 1 th', '11223344', 'Barhagh@live.com', TRUE),
(4,'Kamilla',	'Bonde', 4900, 'Nakeskov Bouldevard 69 3 th', '44556677', 'skafte@hotmail.com', TRUE),
(5,'Anne', 'Haxthausen',  9000,  'Aalborg gade 10, 1 th',	'45257510', 'aeha@dtu.dk', 	FALSE),
(6,'Charlotte', 'Theisen', 9000,  'Aarhusvej 10',	'00112112', 'XXXXXX@student.dtu.dk', TRUE),
(7,'Asgarath', 'Boomkin',  9999,  'Orgrimmar Road 14', '12345678', 'nerd@worldofwarcraft.com', TRUE);

INSERT Orders VALUES
(1, 1, '2019-01-01 10:34:00',  TRUE, '2019-01-01 09:30:01', 'mobilepay'),
(2, 1, '2019-02-10 04:58:00',  TRUE, '2019-02-15 11:42:01', 'paypal'),
(3, 2, '2019-03-07 14:35:00',  TRUE, '2019-03-15 11:07:01', 'mobilepay'),
(4, 3, '2019-03-09 17:25:00',  TRUE, '2019-03-09 13:00:01', 'transaction'),
(5, 2, '2019-04-18 03:14:00',  TRUE, '2019-04-23 15:58:01', 'visa'),
(6, 1, '2019-04-24 09:58:00',  TRUE, '2019-04-29 14:39:01', 'visa'),
(7, 4, '2019-05-03 16:57:00',  TRUE, '2019-05-06 14:38:01', 'mastercard'),
(8, 5, '2019-05-27 18:12:00',  TRUE, '2019-06-04 12:57:01', 'mobilepay'),
(9, 3, '2019-05-29 19:47:00',  TRUE, '2019-06-04 17:52:01', 'transaction'),
(10, 6, '2019-06-02 13:36:00',  TRUE, '2019-06-04 12:35:01', 'mobilepay'),
(11, 4, '2019-06-07 12:52:00',  TRUE, '2019-06-15 14:39:01', 'mastercard'),
(12, 7, '2019-07-31 17:41:00',  TRUE, '2019-08-04 14:09:01', 'mobilepay');


INSERT OrderItem VALUES
(1, 2, 2),
(1, 6, 1),
(1, 10, 3),
(2, 3, 2),
(2, 2, 4),
(2, 4, 1),
(3, 6, 1),
(3, 9, 1),
(4, 2, 5),
(4, 10, 1),
(4, 9, 1),
(4, 1, 3),
(5, 6, 1),
(6, 3, 1),
(6, 6, 1),
(6, 9, 2),
(6, 1, 2),
(7, 3, 1),
(7, 2, 1);

INSERT Rating VALUES
(2, 7, "1","5","bad quality, but awesome fit"),
(2, 1, "4","4", "nice"),
(3, 2, "1", "1", "I DID NOT LIKE THIS PRODUCT! I DEMAND REFUND, NOW"),
(4, 2, "5", "5", "!!! OMG, it was just the best piece of clothe i have ever had hahhah"),
(9, 6, "3", "3", "average"),
(6, 6, "4", "4", "jeg kan lide det");

