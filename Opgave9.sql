USE BSOS;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL event_scheduler = 1;

/* UPDATE */
SELECT customer_id, customer_first_name, customer_last_name, customer_email, customer_accept_news
FROM Customer
WHERE customer_id = 3;

UPDATE Customer
SET customer_email = 'barhagh@hotmail.com', customer_accept_news = 0
WHERE customer_id = 3;

/* DELETE */
SELECT *
FROM Orders;

DELETE FROM Orders
WHERE order_date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR);

/* FUNCTION 												*/
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
CREATE EVENT Shipped
ON SCHEDULE EVERY 1 DAY STARTS '2020-04-04 15:00:00' -- Change to 1 MINUTE to see immediate change in order_shipped 
DO UPDATE Orders 
	SET order_shipped = CASE WHEN order_approval = 1 and order_shipped IS NULL THEN CURRENT_TIMESTAMP
							 ELSE order_shipped END;

