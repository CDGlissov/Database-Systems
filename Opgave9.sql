USE BSOS;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL event_scheduler = 1;

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


/* Transaction that updates the stock in Product according to the quantity in OrderItems */
DELIMITER //
DROP PROCEDURE IF EXISTS Stock_update;
CREATE PROCEDURE Stock_update(
IN vproduct INT, vquantity INT, approval BOOLEAN, OUT vStatus VARCHAR(45))
BEGIN
DECLARE Oldstock, Newstock INT DEFAULT 0; START TRANSACTION;
SET Oldstock = (SELECT product_stock FROM Product WHERE product_id = vproduct); SET Newstock = Oldstock - vquantity;
UPDATE Product SET product_stock = Newstock WHERE product_id = vproduct;
IF (approval)
THEN SET vStatus = 'Transaction Transfer committed!'; COMMIT;
ELSE SET vStatus = 'Transaction Transfer rollback'; ROLLBACK; END IF;
END; // DELIMITER ;



DROP TRIGGER IF EXISTS update_stock;
DELIMITER $$
CREATE TRIGGER update_stock
AFTER UPDATE ON Orders FOR EACH ROW
BEGIN
	DECLARE prodId INT;
    DECLARE quantity INT;
    DECLARE approval BOOLEAN;
	SELECT product_id, order_item_quantity, order_approval INTO ProdId, quantity, approval FROM OrderItem LEFT JOIN Orders using(order_id);

	CALL Stock_update(prodId, quantity, approval, @Status);
END; $$
DELIMITER ;


/* Event */
CREATE EVENT Shipped
ON SCHEDULE EVERY 1 MINUTE -- 15 DAY_HOUR
DO UPDATE Orders 
	SET order_shipped = CASE WHEN order_approval = 1 and order_shipped IS NULL THEN CURRENT_TIMESTAMP
							 ELSE order_shipped END;



INSERT Orders VALUES
(13, 1, '2020-01-01 08:13:00',  FALSE, null, 'mobilepay');

SELECT *
FROM Product;

INSERT OrderItem VALUES
(13,1,2),
(13,12,1);

SELECT *
FROM Orders;

SELECT *
FROM Product;

SELECT * FROM OrderItem;

INSERT Orders VALUES
(14, 1, '2020-01-01 08:15:00',  FALSE, null, 'mobilepay');

INSERT OrderItem VALUES
(14,11,1),
(14,1,2);

SELECT *
FROM Orders;

SELECT * FROM OrderItem;

SELECT *
FROM Product;

SELECT in_stock(14);

