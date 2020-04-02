/* PART 6 */

/*View the total price of a discounted product*/
CREATE VIEW ProductPrice AS SELECT product_price, deal_discount, 
			product_price*IFNULL(1-deal_discount,1) AS total_price, 
			product_price-product_price*IFNULL(1-deal_discount,1) AS savings 
            FROM product NATURAL LEFT OUTER JOIN deals;
SELECT * FROM ProductPrice;
DROP VIEW ProductPrice;

/*View the order of each customer and some contact information*/
CREATE VIEW CustomerOrders AS SELECT customer_id, 
			CONCAT(customer_first_name,' ',customer_last_name) AS full_name, 
            customer_phone, order_id 
            FROM Orders NATURAL LEFT OUTER JOIN Customer;
SELECT * FROM CustomerOrders;
DROP VIEW CustomerOrders;

/*View the stock of a product and gives an indicator if the stock is low*/
CREATE VIEW StockHealth AS SELECT product_id, product_stock, (CASE 
						WHEN product_stock <= 15 THEN 'Warning: Low' 
                        WHEN 15 < product_stock AND product_stock <= 100 THEN 'Medium' 
                        WHEN 100 < product_stock THEN 'High' 
                        END 
            ) AS stock_level FROM product;
SELECT * FROM StockHealth;
DROP VIEW StockHealth;

/* PART 7 */

/*Calculates the average rating of a product*/
SELECT product_id, AVG(rating_quality) as avg_quality_rating, 
				AVG(rating_fit) as avg_fit_rating, 
                (AVG(rating_quality)+AVG(rating_fit))/2
                FROM rating NATURAL LEFT OUTER JOIN product 
                GROUP BY product_id 
                ORDER BY (AVG(rating_quality)+AVG(rating_fit))/2 DESC;

/*Shows the rating reviews of a product and the persons who wrote it*/
SELECT CONCAT(customer_first_name,' ',customer_last_name) as full_name, 
		rating_review, product_type, product_name, product_brand FROM rating 
        JOIN customer ON customer.customer_id = rating.customer_id 
        JOIN product ON product.product_id = rating.product_id;

/*Shows the amount a customer have spent on products*/
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
                        ORDER BY total_spending DESC

# clothing type
# zip code, hvor er customers
# customers og hvad de har købt join

#make price range table (order in sections, what is expensive and what is not)
#total price of each for a customer

