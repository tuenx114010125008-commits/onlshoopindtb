-- File: 04_constraints.sql

USE online_shopping_db;

ALTER TABLE product 
    ADD CONSTRAINT fk_product_category 
    FOREIGN KEY (category_id) REFERENCES category(category_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE inventory 
    ADD CONSTRAINT fk_inventory_product 
    FOREIGN KEY (product_id) REFERENCES product(product_id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE orders 
    ADD CONSTRAINT fk_orders_customer 
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE order_item 
    ADD CONSTRAINT fk_order_item_order 
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE order_item 
    ADD CONSTRAINT fk_order_item_product 
    FOREIGN KEY (product_id) REFERENCES product(product_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE payment 
    ADD CONSTRAINT fk_payment_order 
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

-- mỗi sản phẩm chỉ xuất hiện 1 lần trong 1 đơn
ALTER TABLE order_item 
    ADD CONSTRAINT uq_order_item_order_product 
    UNIQUE (order_id, product_id);

ALTER TABLE product 
    ADD CONSTRAINT chk_product_price 
    CHECK (price >= 0);

ALTER TABLE product 
    ADD CONSTRAINT chk_product_stock 
    CHECK (stock_quantity >= 0);

ALTER TABLE inventory 
    ADD CONSTRAINT chk_inventory_quantity 
    CHECK (quantity >= 0);

ALTER TABLE order_item 
    ADD CONSTRAINT chk_order_item_quantity 
    CHECK (quantity > 0);

ALTER TABLE order_item 
    ADD CONSTRAINT chk_order_item_unit_price 
    CHECK (unit_price >= 0);

ALTER TABLE order_item 
    ADD CONSTRAINT chk_order_item_subtotal 
    CHECK (subtotal >= 0);

ALTER TABLE orders 
    ADD CONSTRAINT chk_orders_total_amount 
    CHECK (total_amount >= 0);

ALTER TABLE orders 
    ADD CONSTRAINT chk_orders_status 
    CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'));

ALTER TABLE payment 
    ADD CONSTRAINT chk_payment_amount 
    CHECK (amount >= 0);

ALTER TABLE payment 
    ADD CONSTRAINT chk_payment_status 
    CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded'));
