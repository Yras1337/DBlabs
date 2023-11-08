-- Средняя оценка для каждого продукта
SELECT
    p.id AS product_id,
    p.name AS product_name,
    COALESCE(AVG(r.rate), -1) AS average_rating
FROM
    product p
LEFT JOIN
    review r ON p.id = r.product_id
GROUP BY
    p.id, p.name
ORDER BY
    p.id;


--Получение среднего чека каждого клиента для последних 3 покупок
WITH recent_orders AS (
  SELECT
    o.client_id,
    o.total_price,
    ROW_NUMBER() OVER (PARTITION BY o.client_id ORDER BY o.date DESC) AS rn
  FROM order_table o
)
SELECT
  ro.client_id,
  AVG(ro.total_price) AS average_order_price
FROM recent_orders ro
WHERE ro.rn <= 3
GROUP BY ro.client_id;


--Получение даты самого первого заказа для каждого клиента
WITH FirstPurchase AS (
  SELECT
    o.client_id,
    MIN(o.date) AS first_purchase_date
  FROM
    order_table o
  GROUP BY
    o.client_id
)
SELECT
  fp.client_id,
  o.id AS order_id,
  o.date AS purchase_date,
  o.total_price AS purchase_total_price
FROM
  FirstPurchase fp
  JOIN order_table o ON fp.client_id = o.client_id AND fp.first_purchase_date = o.date;

--Использование EXISTS для поиска клиентов, оставивших отзывы:
SELECT c.name, c.surname
FROM client c
WHERE EXISTS (SELECT 1 FROM review r WHERE r.client_id = c.id);

--Не оставили отзывы
SELECT c.name, c.surname
FROM client c
WHERE NOT EXISTS (
  SELECT 1
  FROM review r
  WHERE r.client_id = c.id
);

-- EXPLAIN
EXPLAIN SELECT * FROM product WHERE category_id = 1;

-- Выбрать средние стоимости продуктов в каждой категории, у которых средняя стоимость больше 50
SELECT c.name AS category, AVG(p.cost) AS average_cost
FROM product p
JOIN category c ON p.category_id = c.id
GROUP BY c.name
HAVING AVG(p.cost) > 50;

-- Выбрать имена клиентов и поставщиков из таблицы "client" и "provider" и объединить их в один список
SELECT name AS name FROM client
UNION
SELECT name AS name FROM provider;

-- Выбрать имя продукта и его описание, а также добавить статус в зависимости от наличия товара в наличии
SELECT name, description,
  CASE
    WHEN in_stock = true THEN 'In Stock'
    ELSE 'Out of Stock'
  END AS status
FROM product;

--CROSS JOIN - Возвращает все возможные комбинации строк из двух таблиц, без каких-либо условий.
SELECT client.name, product.name
FROM client
CROSS JOIN product;

--FULL JOIN (Полное объединение) - Возвращает все строки из обеих таблиц. 
--Если совпадений нет, то возвращается NULL для соответствующих столбцов.
SELECT product.name, review.rate
FROM product
FULL JOIN review ON product.id = review.product_id;

--LEFT JOIN - Возвращает все строки из левой таблицы и соответствующие строки из правой таблицы.
--Если совпадений нет, то возвращается NULL для столбцов из правой таблицы.
SELECT client.name, order_table.date
FROM client
LEFT JOIN order_table ON client.id = order_table.client_id;

--SELF JOIN - Используется, когда нужно объединить таблицу саму с собой.
SELECT c1.name AS name1, c2.name AS name2, c1.address
FROM client c1, client c2
WHERE c1.id < c2.id; -- чтобы избежать дубликатов и возврата пар в обоих направлениях


CREATE VIEW order_details AS
SELECT ot.id AS order_id, ot.date, c.name AS client_name, p.name AS product_name, ot.total_price
FROM order_table ot
JOIN client c ON ot.client_id = c.id
JOIN order_product op ON ot.id = op.order_id
JOIN product p ON op.product_id = p.id;
