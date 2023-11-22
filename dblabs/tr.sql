CREATE OR REPLACE FUNCTION update_basket_total_price()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate the total price for the given basket_id
    UPDATE basket
    SET total_price = (
        SELECT COALESCE(SUM(p.cost), 0)
        FROM basket_product bp
        JOIN product p ON bp.product_id = p.id
        WHERE bp.basket_id = COALESCE(NEW.basket_id, OLD.basket_id)
    )
    WHERE id = COALESCE(NEW.basket_id, OLD.basket_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_basket_total_price_trig ON basket_product

CREATE TRIGGER update_basket_total_price_trig
AFTER INSERT OR UPDATE OR DELETE ON basket_product
FOR EACH ROW
EXECUTE FUNCTION update_basket_total_price();


INSERT INTO basket (id, total_price, client_id) VALUES (10, 0, 1);

INSERT INTO product (id, name, cost, category_id, provider_id) VALUES (10, 'SSS Product', 10.99, 1, 1);
INSERT INTO product (id, name, cost, category_id, provider_id) VALUES (11, 'S Product', 10.99, 1, 1);
INSERT INTO product (id, name, cost, category_id, provider_id) VALUES (12, '33333 Product', 100.99, 1, 1);
INSERT INTO basket_product (basket_id, product_id) VALUES (10, 11);
INSERT INTO basket_product (basket_id, product_id) VALUES (10, 12);
DELETE FROM basket_product WHERE basket_id = 10 AND product_id = 11;

SELECT * FROM basket WHERE id = 10;

SELECT * FROM basket_product

SELECT * FROM basket


CREATE OR REPLACE FUNCTION generate_order_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.id := nextval('order_table_id_seq');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_generate_order_id
BEFORE INSERT ON order_table
FOR EACH ROW
EXECUTE FUNCTION generate_order_id();

SELECT * FROM order_table

INSERT INTO order_table(id, delivery_id, date, client_id, status, total_price) VALUES(1, 1, '2023-11-11', 2, 'processing', 455)

CREATE OR REPLACE FUNCTION enforce_max_basket_total_price()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_price > 5000 THEN
        RAISE EXCEPTION 'Basket total price exceeds the maximum limit ($1000)';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_max_basket_total_price_before_update
BEFORE UPDATE ON basket
FOR EACH ROW
EXECUTE FUNCTION enforce_max_basket_total_price();

INSERT INTO basket (client_id) VALUES (1);

SELECT * FROM basket

INSERT INTO basket (id, total_price, client_id) VALUES (20, 0, 2);

SELECT * FROM product
	
INSERT INTO basket_product (basket_id, product_id) VALUES (20, 1);



CREATE OR REPLACE FUNCTION add_product_to_basket_with_discount()
RETURNS TRIGGER AS $$
DECLARE
    product_cost real;
    discounted_cost real;
    discount_type varchar(10);
BEGIN
    SELECT COALESCE(MIN(d.type), 'none')
    INTO discount_type
    FROM product_discount pd
    JOIN discount d ON pd.discount_id = d.id
    WHERE pd.product_id = NEW.product_id
    AND d.date_start <= CURRENT_DATE
    AND d.date_end >= CURRENT_DATE;

    IF discount_type != 'none' THEN
        SELECT cost INTO product_cost FROM product WHERE id = NEW.product_id;

        SELECT CASE
            WHEN discount_type = 'percent' THEN product_cost * (1 - (d.value / 100))
            WHEN discount_type = 'fixed' THEN product_cost - d.value
            ELSE product_cost
        END
        INTO discounted_cost
        FROM product_discount pd
        JOIN discount d ON pd.discount_id = d.id
        WHERE pd.product_id = NEW.product_id
        AND d.date_start <= CURRENT_DATE
        AND d.date_end >= CURRENT_DATE;
    ELSE
        discounted_cost := product_cost;
    END IF;

    INSERT INTO basket_product (basket_id, product_id)
    VALUES (NEW.basket_id, NEW.product_id);

    UPDATE basket
    SET total_price = total_price + discounted_cost
    WHERE id = NEW.basket_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS add_product_to_basket_with_discount_after_insert ON basket_product
CREATE TRIGGER add_product_to_basket_with_discount_before_insert
BEFORE INSERT ON basket_product
FOR EACH ROW
EXECUTE FUNCTION add_product_to_basket_with_discount();

SELECT * FROM product_discount
SELECT * FROM discount
SELECT * FROM product
SELECT * FROM basket

INSERT INTO basket (id, total_price, client_id) VALUES (21, 0, 2);

INSERT INTO basket_product (basket_id, product_id) VALUES (21, 1);


CREATE OR REPLACE PROCEDURE assign_discount_to_product(
    p_discount_id integer,
    p_product_id integer
)
AS
$$
BEGIN
    INSERT INTO product_discount (discount_id, product_id)
    VALUES (p_discount_id, p_product_id);
END;
$$ LANGUAGE plpgsql;

CALL assign_discount_to_product(1, 3);

CREATE OR REPLACE PROCEDURE delete_product_discount(
    p_discount_id integer,
    p_product_id integer
)
AS
$$
BEGIN
    DELETE FROM product_discount
    WHERE discount_id = p_discount_id AND product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

CALL delete_product_discount(1, 3)

CREATE OR REPLACE PROCEDURE add_discount(IN p_type varchar(10), IN p_value real)
LANGUAGE plpgsql
AS $$
DECLARE
  v_start_date date;
  v_end_date date;
BEGIN
  v_start_date := CURRENT_DATE;
  v_end_date := CURRENT_DATE + INTERVAL '1 week';

  INSERT INTO discount (type, date_start, date_end, value)
  VALUES (p_type, v_start_date, v_end_date, p_value);

  RAISE NOTICE 'Добавлена новая запись: type=%, date_start=%, date_end=%, value=%', p_type, v_start_date, v_end_date, p_value;
END;
$$;

CALL add_discount('fixed', 100);


CREATE OR REPLACE FUNCTION update_product_price()
RETURNS TRIGGER AS $$
DECLARE
  discount_type varchar(10);
  discount_value real;
BEGIN
  SELECT type, value INTO discount_type, discount_value
  FROM discount
  WHERE id = NEW.discount_id;
RAISE NOTICE 'Discount Type: %, Discount Value: %, product_id: %', discount_type, discount_value, NEW.product_id;
  IF discount_type = 'fixed' THEN
    RAISE NOTICE 'Discount Type: %, Discount Value: %, product_id: %', discount_type, discount_value, NEW.product_id;
    UPDATE product
    SET cost = product.cost - discount_value
    WHERE id = NEW.product_id;
  ELSIF discount_type = 'percentage' THEN
    UPDATE product
    SET cost = product.cost * (1 - discount_value / 100)
    WHERE id = NEW.product_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_product_price_trigger
AFTER INSERT ON product_discount
FOR EACH ROW
EXECUTE FUNCTION update_product_price();

SELECT * FROM product
SELECT * FROM product_discount
SELECT * FROM discount
CALL assign_discount_to_product(2, 6);
CALL delete_product_discount(2, 6);