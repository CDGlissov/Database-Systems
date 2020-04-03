/* PART 7 */
USE BSOS;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL event_scheduler = 1;

SELECT * FROM city;
SELECT * FROM customer;
SELECT * FROM deals;
SELECT * FROM orderitem;
SELECT * FROM orders;
SELECT * FROM product;
SELECT * FROM rating;
SELECT * FROM customerorders;
SELECT * FROM productprice;
SELECT * FROM stockhealth;

/*Calculates the average rating of a product*/
SELECT product_id, AVG(rating_quality) as avg_quality_rating, 
				AVG(rating_fit) as avg_fit_rating, 
                (AVG(rating_quality)+AVG(rating_fit))/2 AS avg_rating
                FROM rating NATURAL LEFT OUTER JOIN product 
                GROUP BY product_id 
                ORDER BY (AVG(rating_quality)+AVG(rating_fit))/2 DESC;

/*Shows the rating reviews of a product and the persons who wrote it*/
SELECT CONCAT(customer_first_name,' ',customer_last_name) as full_name, 
		rating_review, product_type, product_name, product_brand FROM rating 
        JOIN customer ON customer.customer_id = rating.customer_id 
        JOIN product ON product.product_id = rating.product_id;

/*Shows the amount customers have spent on products*/
SELECT customer.customer_id, product.product_id, customer_last_name, 
						SUM(order_item_quantity*product_price*IFNULL(1-deal_discount,1)) 
                        AS total_spending FROM 
						customer 
						INNER JOIN orders ON
                        orders.order_id = customer.customer_id 
						INNER JOIN orderitem ON
                        orders.order_id = orderitem.order_id
                        INNER JOIN product ON
                        product.product_id = orderitem.product_id
						NATURAL LEFT OUTER JOIN deals 
                        GROUP BY customer.customer_id
                        ORDER BY total_spending DESC;

/* Shows the orders and the items of a customer*/
SELECT orders.customer_id, orderitem.order_id, orderitem.product_id, order_item_quantity FROM orderitem 
                                   JOIN orders ON orders.order_id=orderitem.order_id ORDER BY orders.customer_id;

/* PART 8 */
/* Make a campaign of deals */
SELECT * FROM Product WHERE product_brand = 'bsosdesign';
UPDATE product SET deal_id = 3 WHERE product_brand = 'bsosdesign';
SELECT * FROM Product WHERE product_brand = 'bsosdesign';

/* Price scaler by input, makes the client adjust price for products */
DROP  PROCEDURE  IF  EXISTS  priceScaler;

DELIMITER  //
CREATE  PROCEDURE  priceScaler(IN  scale  DECIMAL (3,2), vproduct INT)
BEGIN 
	UPDATE product SET product_price=product_price*scale WHERE product_id = vproduct;
END; //
DELIMITER ;
SELECT * FROM product WHERE product_id = 1;
CALL priceScaler(1.02, 1);
SELECT * FROM product WHERE product_id = 1;

/* Delete bad ratings */
SELECT * FROM Rating;
DELETE FROM Rating WHERE rating_quality <= 2;
SELECT * FROM Rating;

/* Delete an ordered item */
DROP  PROCEDURE  IF  EXISTS  delete_orderitem;

DELIMITER  //
CREATE  PROCEDURE  delete_orderitem(IN vorder_id INT, vproduct_id INT)
BEGIN 
	DELETE FROM orderitem WHERE order_id = vorder_id AND product_id = vproduct_id ;
END; //
DELIMITER ;
SELECT * FROM orderitem;
CALL delete_orderitem(4,1);
SELECT * FROM orderitem;

/* Update customer mail and if they want to accept newsletters */
SELECT customer_id, customer_first_name, customer_last_name, customer_email, customer_accept_news
FROM Customer
WHERE customer_id = 3;
UPDATE Customer
SET customer_email = 'barhagh@hotmail.com', customer_accept_news = 0 WHERE customer_id = 3;

/* DELETE orders older than a year, to uphold the GDPR rule! */
SELECT * FROM Orders;
DELETE FROM Orders WHERE order_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR);
SELECT * FROM Orders;

/* PART 9 */

DROP  FUNCTION  IF  EXISTS  CustomerPrice;

/*Use the function below gets the total spending of a customer*/
DELIMITER //
CREATE FUNCTION CustomerPrice (vCustomer_id INT) 
RETURNS FLOAT
BEGIN
	DECLARE vPrice FLOAT;
	SELECT SUM(order_item_quantity*product_price*IFNULL(1-deal_discount,1)) INTO vPrice
						FROM customer 
						INNER JOIN orders ON
						orders.order_id = customer.customer_id 
						INNER JOIN orderitem ON
						orders.order_id = orderitem.order_id
						INNER JOIN product ON
						product.product_id = orderitem.product_id
						NATURAL LEFT OUTER JOIN deals 
						WHERE  customer.customer_id = vCustomer_id;
	RETURN vPrice;
END; //
DELIMITER ;
SELECT customer_id, CustomerPrice(customer_id) AS total_spending FROM customer ORDER BY total_spending DESC;
SELECT CustomerPrice(4) AS Customer_4;
/* The procedure creates a new deal for a week, this can be used as a campaign deal */
DROP  PROCEDURE  IF  EXISTS  standardDeal;
DELIMITER  //
CREATE  PROCEDURE  standardDeal (IN  discount  DECIMAL (3,2))
BEGIN 
	INSERT  Deals(deal_discount , deal_starts , deal_expires)
	VALUES (discount , NOW(), NOW() + INTERVAL 7 DAY);
END; //
DELIMITER ;
CALL standardDeal(0.50);
SELECT * FROM deals;

/* Check if all items are in stock for a specific order_id */
DROP FUNCTION IF EXISTS in_stock;
DELIMITER //
CREATE FUNCTION in_stock(orderid INT) RETURNS BOOLEAN
BEGIN
	DECLARE approved BOOLEAN; 
    SELECT sum(order_item_quantity <= product_stock) = count(distinct product_id)
		INTO approved
	FROM OrderItem
    LEFT JOIN Product using(product_id)
    WHERE order_id = orderid;
    RETURN approved;
END; //
DELIMITER ;

/* Check if all items are in stock before approving order */
DROP TRIGGER IF EXISTS approve_order;
DELIMITER //
CREATE TRIGGER approve_order
AFTER INSERT ON OrderItem FOR EACH ROW
BEGIN
	UPDATE Orders
		SET Orders.order_approval = in_stock(NEW.order_id) WHERE NEW.order_id = Orders.order_id;
END; // 
DELIMITER ;

/* Check if all items are in stock for a specific order_id  */
DROP FUNCTION IF EXISTS in_stock;
DELIMITER //
CREATE FUNCTION in_stock(orderid INT) RETURNS BOOLEAN
BEGIN
	DECLARE approved BOOLEAN; 
    SELECT sum(order_item_quantity <= product_stock) = count(distinct product_id)
		INTO approved
	FROM OrderItem
    LEFT JOIN Product using(product_id)
    WHERE order_id = orderid;
    RETURN approved;
END; //
DELIMITER ;

-- Test case
SELECT in_stock(7); -- Test if items in order with order_id = 7 is in stock

/* TRIGGER 												  */
/* Check if all items are in stock before approving order */
DROP TRIGGER IF EXISTS approve_order;
DELIMITER //
CREATE TRIGGER approve_order
AFTER INSERT ON OrderItem FOR EACH ROW
BEGIN
	UPDATE Orders
		SET Orders.order_approval = in_stock(NEW.order_id) WHERE NEW.order_id = Orders.order_id;
END; // 
DELIMITER ;

-- Test case
INSERT Orders VALUES
(13, 1, '2020-01-01 08:13:00',  FALSE, null, 'mobilepay');
INSERT OrderItem VALUES
(13,1,2),
(13,12,1); -- This item is not in stock, this order_approved is expected to = 0

INSERT Orders VALUES
(14, 1, '2020-01-01 08:15:00',  FALSE, null, 'mobilepay');
INSERT OrderItem VALUES
(14,11,1),
(14,1,2); -- All items are in stock

SELECT *
FROM Orders; -- Order 13 is denied while order 14 is approved

/* TRANSACTION										*/
/* Transaction that updates the stock in Product	*/
/* according to the quantity in OrderItems 			*/
DROP PROCEDURE IF EXISTS Stock_update;
DELIMITER //
CREATE PROCEDURE Stock_update(IN vproduct INT, vquantity INT, vapproval BOOLEAN, OUT vStatus VARCHAR(45))
BEGIN
DECLARE Oldstock, Newstock INT DEFAULT 0; 
START TRANSACTION;
	SET Oldstock = (SELECT product_stock FROM Product WHERE product_id = vproduct); SET Newstock = Oldstock - vquantity;
	UPDATE Product SET product_stock = Newstock WHERE product_id = vproduct;
	IF (vapproval)
	THEN SET vStatus = 'Transaction Transfer committed!'; COMMIT;
	ELSE SET vStatus = 'Transaction Transfer rollback'; ROLLBACK; END IF;
END; // 
DELIMITER ;

-- Test case
SELECT product_id, product_stock
FROM Product
WHERE Product_id = 1;

CALL Stock_update(1,2,1,@Status); -- Changing the stock by -2 of product with id = 1 t (order_approved = 1)
SELECT @Status;

SELECT product_id, product_stock
FROM Product
WHERE Product_id = 1;

CALL Stock_update(1,2,0,@Status); -- order_approved = 0, thus we do not expect a stock update
SELECT @Status;

/* EVENT  */
DROP EVENT IF EXISTS Shipped;
CREATE EVENT Shipped
ON SCHEDULE EVERY 1 DAY STARTS '2020-04-04 15:00:00' -- Change to 1 MINUTE to see immediate change in order_shipped 
DO UPDATE Orders 
	SET order_shipped = CASE WHEN order_approval = 1 and order_shipped IS NULL THEN CURRENT_TIMESTAMP
							 ELSE order_shipped END;

#SET SQL_SAFE_UPDATES = 1;
