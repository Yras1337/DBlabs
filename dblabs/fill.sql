INSERT INTO category (name)
VALUES
  ('Electronics'),
  ('Clothing'),
  ('Home and Garden');

INSERT INTO discount (type, date_start, date_end)
VALUES
  ('percent', '2023-01-01', '2023-12-31'),
  ('fixed', '2023-02-01', '2023-02-28'),
  ('coupon', '2023-03-01', '2023-03-31');

INSERT INTO client (name, surname, address, mail, phone_number)
VALUES
  ('John', 'Doe', '123 Main St', 'john.doe@email.com', '555-123-4567'),
  ('Alice', 'Smith', '456 Elm St', 'alice.smith@email.com', '555-987-6543'),
  ('Monica', 'Geller', '123 Elm St', 'monicag@email.com', '555-123-4567'),
  ('Phoebe', 'Buffay', '789 Broadway', 'phoebeb@email.com', '555-987-6543'),
  ('Rachel', 'O''nil', '978 Main St', 'raon.d@email.com', '333-456-748');

INSERT INTO provider (name, description, address, phone, mail)
VALUES
  ('Provider A', 'Electronics supplier', '789 Provider St', '555-111-2222', 'providerA@email.com'),
  ('Provider B', 'Clothing supplier', '456 Clothes Ave', '555-333-4444', 'providerB@email.com');

INSERT INTO product (name, cost, in_stock, category_id, provider_id, description, specifications, image)
VALUES
  ('Smartphone', 599.99, true, 1, 1, 'A high-end smartphone', '5.5" display, 12MP camera', NULL),
  ('Laptop', 999.99, true, 1, 2, 'Powerful laptop for work', '15" display, 16GB RAM', NULL),
  ('T-shirt', 19.99, true, 2, 3, 'Comfortable cotton t-shirt', 'Available in multiple colors', NULL),
  ('Computer Mouse', 29.99, false, 1, 1, 'Optical USB mouse', '3-button design', NULL),
  ('Shorts', 24.99, false, 2, 3, 'Casual shorts', 'Available in various sizes and colors', NULL);

INSERT INTO order_table (delivery_id, date, client_id, status, total_price)
VALUES
  (1, '2023-10-30', 1, 'processing', 599.99),
  (2, '2023-10-31', 2, 'shipped', 999.99),
  (2, '2023-10-30', 1, 'processing', 101.99),
  (1, '2023-10-31', 2, 'shipped', 250.99),
  (1, '2022-02-02', 1, 'processing', 450.60),
  (2, '2009-12-15', 2, 'shipped', 500.50);

INSERT INTO order_product (order_id, product_id)
VALUES
  (1, 1),
  (2, 2);

INSERT INTO product_discount (product_id, discount_id)
VALUES
  (1, 1),
  (2, 2);

INSERT INTO basket (total_price, client_id)
VALUES
  (199.99, 1),
  (49.99, 2);

INSERT INTO basket_product (basket_id, product_id)
VALUES
  (1, 3),
  (2, 3);

INSERT INTO review (client_id, product_id, rate, date, comment)
VALUES
  (1, 1, 5, '2023-10-31', 'Great product!'),
  (2, 2, 4, '2023-11-01', 'Good laptop.'),
  (2, 1, 1, '2023-10-30', 'Bad product!'),
  (1, 2, 2, '2023-11-02', 'Bad laptop.'),
  (1, 3, 3, '2023-09-09', 'It''s an OK T-shirt' ),
  (2, 3, 5, '2023-01-01', 'I like this T-shirt so much!');
