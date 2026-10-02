-- File: 09_bonus.sql

USE online_shopping_db;

-- ============================================================
-- PHẦN 1: EXPLAIN ANALYZE
-- ============================================================

EXPLAIN ANALYZE
SELECT 
    o.order_id,
    c.full_name,
    c.email,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    o.total_amount,
    o.order_date
FROM orders o
INNER JOIN customer c ON o.customer_id = c.customer_id
INNER JOIN order_item oi ON o.order_id = oi.order_id
INNER JOIN product p ON oi.product_id = p.product_id
WHERE o.customer_id = 1
ORDER BY o.order_date DESC;


-- ============================================================
-- PHẦN 2: TRANSACTION
-- ============================================================

-- KH 2 mua 2 cái Sony WH-1000XM5
START TRANSACTION;

INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address)
VALUES (2, NOW(), 'pending', 15980000.00, '456 Nguyễn Huệ, Quận 1, TP.HCM');

SET @new_order_id = LAST_INSERT_ID();

INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal)
VALUES (@new_order_id, 7, 2, 7990000.00, 15980000.00);

UPDATE inventory 
SET quantity = quantity - 2, updated_at = NOW() 
WHERE product_id = 7;

UPDATE product 
SET stock_quantity = stock_quantity - 2, updated_at = NOW() 
WHERE product_id = 7;

INSERT INTO payment (order_id, payment_method, payment_status, amount, transaction_code)
VALUES (@new_order_id, 'Bank Transfer', 'pending', 15980000.00, CONCAT('TXN-TRANS-', @new_order_id));

COMMIT;


-- ============================================================
-- PHẦN 3: AUDIT LOG
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,
    record_id INT,
    old_value JSON,
    new_value JSON,
    changed_by VARCHAR(50) DEFAULT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TRIGGER IF EXISTS trg_audit_product_update;

DELIMITER //

CREATE TRIGGER trg_audit_product_update
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, old_value, new_value, changed_by)
    VALUES (
        'product',
        'UPDATE',
        NEW.product_id,
        JSON_OBJECT('price', OLD.price, 'stock_quantity', OLD.stock_quantity, 'status', OLD.status),
        JSON_OBJECT('price', NEW.price, 'stock_quantity', NEW.stock_quantity, 'status', NEW.status),
        USER()
    );
END //

DELIMITER ;

-- test
UPDATE product SET price = 28990000.00 WHERE product_id = 1;
-- SELECT * FROM audit_log ORDER BY changed_at DESC;


-- ============================================================
-- PHẦN 4: SOFT DELETE
-- ============================================================

DROP PROCEDURE IF EXISTS sp_soft_delete_customer;

DELIMITER //

CREATE PROCEDURE sp_soft_delete_customer(IN p_customer_id INT)
BEGIN
    UPDATE customer
    SET deleted_at = NOW(),
        status = 'inactive'
    WHERE customer_id = p_customer_id AND deleted_at IS NULL;
END //

DELIMITER ;

CREATE OR REPLACE VIEW v_active_customers AS
SELECT 
    customer_id,
    full_name,
    email,
    phone,
    created_at,
    status
FROM customer
WHERE deleted_at IS NULL;
