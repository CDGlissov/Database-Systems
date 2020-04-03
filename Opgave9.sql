SET SQL_SAFE_UPDATES = 1;

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
/*DROP TRIGGER IF EXISTS approve_order;
DELIMITER //
CREATE TRIGGER approve_order
BEFORE INSERT ON Orders FOR EACH ROW
BEGIN
	IF in_stock(NEW.order_id) THEN SET NEW.order_approval = 1;
    ELSE SET NEW.order_approval = 0;
    END  IF;
END; //
DELIMITER ;
*/
DROP TRIGGER IF EXISTS approve_order;
DELIMITER //
CREATE TRIGGER approve_order
AFTER INSERT ON OrderItem FOR EACH ROW
BEGIN
	IF in_stock(NEW.order_id)
    THEN UPDATE Orders
		SET Orders.order_approval = 1 WHERE NEW.order_id = Orders.order_id;
    ELSE UPDATE Orders
		SET Orders.order_approval = 0 WHERE NEW.order_id = Orders.order_id;
    END  IF;
END; // 
DELIMITER ;


DROP TRIGGER IF EXISTS update_stock;
DELIMITER $$
CREATE TRIGGER update_stock
AFTER UPDATE ON Orders FOR EACH ROW
IF NEW.order_approval
THEN UPDATE Product
	SET product_stock = product_stock - (SELECT order_item_quantity FROM OrderItem WHERE Product.product_id = OrderItem.product_id and NEW.order_id = OrderItem.order_id);
END IF; $$
DELIMITER ;

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

INSERT Orders VALUES
(14, 1, '2020-01-01 08:15:00',  FALSE, null, 'mobilepay');

INSERT OrderItem VALUES
(14,11,1);

SELECT *
FROM Product;

SELECT in_stock(7);





