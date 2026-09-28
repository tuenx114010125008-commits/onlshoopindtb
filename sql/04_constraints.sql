-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 04_constraints.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Thiết lập các ràng buộc toàn vẹn dữ liệu (Constraints)
--           Bao gồm: FOREIGN KEY, UNIQUE, CHECK constraints
-- ============================================================

USE online_shopping_db;

-- ------------------------------------------------------------
-- 1. FOREIGN KEY CONSTRAINTS (Khóa ngoại đảm bảo toàn vẹn tham chiếu)
-- ------------------------------------------------------------

-- product.category_id -> category.category_id
ALTER TABLE product 
    ADD CONSTRAINT fk_product_category 
    FOREIGN KEY (category_id) REFERENCES category(category_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- inventory.product_id -> product.product_id (Quan hệ 1:1)
ALTER TABLE inventory 
    ADD CONSTRAINT fk_inventory_product 
    FOREIGN KEY (product_id) REFERENCES product(product_id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

-- orders.customer_id -> customer.customer_id
ALTER TABLE orders 
    ADD CONSTRAINT fk_orders_customer 
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- order_item.order_id -> orders.order_id
ALTER TABLE order_item 
    ADD CONSTRAINT fk_order_item_order 
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

-- order_item.product_id -> product.product_id
ALTER TABLE order_item 
    ADD CONSTRAINT fk_order_item_product 
    FOREIGN KEY (product_id) REFERENCES product(product_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- payment.order_id -> orders.order_id (Quan hệ 1:1)
ALTER TABLE payment 
    ADD CONSTRAINT fk_payment_order 
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
    ON UPDATE CASCADE ON DELETE CASCADE;


-- ------------------------------------------------------------
-- 2. UNIQUE CONSTRAINTS (Ràng buộc duy nhất bổ sung)
-- ------------------------------------------------------------

-- order_item: Mỗi sản phẩm chỉ xuất hiện 1 lần trong 1 đơn hàng (tránh trùng lặp dòng)
ALTER TABLE order_item 
    ADD CONSTRAINT uq_order_item_order_product 
    UNIQUE (order_id, product_id);


-- ------------------------------------------------------------
-- 3. CHECK CONSTRAINTS (Ràng buộc miền giá trị hợp lệ - MySQL 8.0+)
-- ------------------------------------------------------------

-- product: Giá và số lượng không được âm
ALTER TABLE product 
    ADD CONSTRAINT chk_product_price 
    CHECK (price >= 0);

ALTER TABLE product 
    ADD CONSTRAINT chk_product_stock 
    CHECK (stock_quantity >= 0);

-- inventory: Tồn kho không được âm
ALTER TABLE inventory 
    ADD CONSTRAINT chk_inventory_quantity 
    CHECK (quantity >= 0);

-- order_item: Số lượng phải lớn hơn 0, đơn giá và thành tiền không âm
ALTER TABLE order_item 
    ADD CONSTRAINT chk_order_item_quantity 
    CHECK (quantity > 0);

ALTER TABLE order_item 
    ADD CONSTRAINT chk_order_item_unit_price 
    CHECK (unit_price >= 0);

ALTER TABLE order_item 
    ADD CONSTRAINT chk_order_item_subtotal 
    CHECK (subtotal >= 0);

-- orders: Tổng tiền không âm và trạng thái hợp lệ
ALTER TABLE orders 
    ADD CONSTRAINT chk_orders_total_amount 
    CHECK (total_amount >= 0);

ALTER TABLE orders 
    ADD CONSTRAINT chk_orders_status 
    CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'));

-- payment: Số tiền thanh toán không âm và trạng thái hợp lệ
ALTER TABLE payment 
    ADD CONSTRAINT chk_payment_amount 
    CHECK (amount >= 0);

ALTER TABLE payment 
    ADD CONSTRAINT chk_payment_status 
    CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded'));
