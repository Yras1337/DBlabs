-- Создание таблиц
CREATE TABLE product (
  id serial PRIMARY KEY,
  name varchar(50) UNIQUE,
  cost real NOT NULL,
  in_stock bool DEFAULT true,
  category_id integer NOT NULL,
  provider_id integer NOT NULL,
  description varchar(2000) DEFAULT '',
  specifications varchar(100) DEFAULT '',
  image bytea
);

CREATE TABLE discount (
  id serial PRIMARY KEY,
  type varchar(10) NOT NULL,
  date_start date NOT NULL,
  date_end date NOT NULL
);

CREATE TABLE product_discount (
  discount_id integer,
  product_id integer,
  PRIMARY KEY (discount_id, product_id)
);

CREATE TABLE category (
  id serial PRIMARY KEY,
  name varchar(50) NOT NULL
);

CREATE TABLE order_table (
  id serial PRIMARY KEY,
  delivery_id integer NOT NULL,
  date date NOT NULL,
  client_id integer NOT NULL,
  status varchar(10) NOT NULL,
  total_price real NOT NULL
);

CREATE TABLE order_product (
  order_id integer NOT NULL,
  product_id integer NOT NULL,
  PRIMARY KEY (order_id, product_id)
);

CREATE TABLE client (
  id serial PRIMARY KEY,
  name varchar(20) NOT NULL,
  surname varchar(20) NOT NULL,
  address varchar(100) NOT NULL,
  mail varchar(100) NOT NULL,
  phone_number varchar(30) NOT NULL
);

CREATE TABLE basket (
  id serial PRIMARY KEY,
  total_price real DEFAULT 0,
  client_id integer NOT NULL
);

CREATE TABLE basket_product (
  basket_id integer NOT NULL,
  product_id integer NOT NULL,
  PRIMARY KEY (basket_id, product_id)
);

CREATE TABLE review (
  id serial PRIMARY KEY,
  client_id integer NOT NULL,
  product_id integer NOT NULL,
  rate integer NOT NULL,
  date date NOT NULL,
  comment varchar(1000) NOT NULL
);

CREATE TABLE delivery (
  id serial PRIMARY KEY,
  address varchar(100) NOT NULL,
  type varchar(10) NOT NULL
);

CREATE TABLE provider (
  id serial PRIMARY KEY,
  name varchar(20) NOT NULL,
  description varchar(2000),
  address varchar(100) NOT NULL,
  phone varchar(30) NOT NULL,
  mail varchar(100) NOT NULL
);

-- Ограничение целостности для внешних ключей
-- Foreign key constraints
ALTER TABLE product_discount 
ADD CONSTRAINT product_discount_discount_id_fk FOREIGN KEY (discount_id) REFERENCES discount(id) ON DELETE CASCADE;
ALTER TABLE product_discount 
ADD CONSTRAINT product_discount_product_id_fk FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;
ALTER TABLE order_product 
ADD CONSTRAINT order_product_order_id_fk FOREIGN KEY (order_id) REFERENCES order_table(id) ON DELETE CASCADE;
ALTER TABLE basket
ADD CONSTRAINT basket_client_id_fk FOREIGN KEY (client_id) REFERENCES client(id) ON DELETE CASCADE;
ALTER TABLE order_product 
ADD CONSTRAINT order_product_product_id_fk FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT;
ALTER TABLE basket_product 
ADD CONSTRAINT basket_product_basket_id_fk FOREIGN KEY (basket_id) REFERENCES basket(id) ON DELETE CASCADE;
ALTER TABLE basket_product 
ADD CONSTRAINT basket_product_product_id_fk FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT;
ALTER TABLE review 
ADD CONSTRAINT review_client_id_fk FOREIGN KEY (client_id) REFERENCES client(id) ON DELETE CASCADE;
ALTER TABLE review 
ADD CONSTRAINT review_product_id_fk FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;

-- Создание уникального ключа для поля mail в таблице client
ALTER TABLE client
ADD CONSTRAINT unique_mail UNIQUE (mail);

-- Создание уникального ключа для поля name в таблице category
ALTER TABLE category
ADD CONSTRAINT unique_name UNIQUE (name);

-- Ограничение проверки для столбца status в таблице order
ALTER TABLE order_table
ADD CONSTRAINT check_status CHECK (status IN ('processing', 'shipped', 'cancelled', 'refunded'));


-- Проставление индексов

-- PRODUCT 
CREATE INDEX idx_product_name ON product ("name");

CREATE INDEX idx_product_description ON product ("description");

CREATE INDEX idx_product_specifications ON product ("specifications");

-- CLIENT 
CREATE INDEX idx_client_mail ON client ("mail");

-- ORDER_TABLE
CREATE INDEX idx_order_table_date ON "order_table" ("date");

CREATE INDEX idx_order_table_client_id ON "order_table" ("client_id");

-- ORDER_PRODUCT
CREATE INDEX idx_order_product_order_id ON order_product ("order_id");

CREATE INDEX idx_order_product_product_id ON order_product ("product_id");

-- BASKET
CREATE INDEX idx_basket_client_id ON basket ("client_id");

-- BASKET_PRODUCT
CREATE INDEX idx_basket_product_basket_id ON basket_product ("basket_id");

CREATE INDEX idx_basket_product_product_id ON basket_product ("product_id");

-- REVIEW
CREATE INDEX idx_review_product_id ON review ("product_id");

CREATE INDEX idx_review_client_id ON review ("client_id");
