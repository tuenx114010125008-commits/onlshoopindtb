-- File: 05_indexes.sql

USE online_shopping_db;

-- index bắt buộc theo đề bài
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_product_category_id ON product(category_id);

-- index bổ sung
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_product_price ON product(price);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_item_product_id ON order_item(product_id);
