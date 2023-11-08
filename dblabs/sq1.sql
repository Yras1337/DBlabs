SELECT * FROM product
WHERE category_id = (SELECT id FROM category WHERE name = 'Electronics');

SELECT * FROM order_table
WHERE client_id = (SELECT id FROM client WHERE name = 'John' AND surname = 'Doe');


UPDATE order_table
SET status = 'shipped'
WHERE id = 1;

DELETE FROM basket_product
WHERE basket_id = 1 AND product_id = 3;

SELECT COUNT(*) FROM basket_product
WHERE basket_id = 2;

SELECT DISTINCT c.name, c.surname
FROM client c
JOIN review r ON c.id = r.client_id;

SELECT AVG(rate) FROM review
WHERE product_id = 1;
