-- File: 07_functions_procedures.sql

USE online_shopping_db;

DROP PROCEDURE IF EXISTS sp_create_order;
DROP PROCEDURE IF EXISTS sp_cancel_order;
DROP FUNCTION IF EXISTS fn_get_customer_total_spent;

DELIMITER //

-- Tạo đơn hàng mới, kiểm tra KH + sản phẩm + tồn kho trước khi insert
CREATE PROCEDURE sp_create_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_shipping_address TEXT,
    IN p_payment_method VARCHAR(50),
    OUT p_order_id INT
)
BEGIN
    DECLARE v_price DECIMAL(12, 2);
    DECLARE v_stock INT;
    DECLARE v_subtotal DECIMAL(12, 2);
    DECLARE v_customer_status VARCHAR(20);
    DECLARE v_product_status VARCHAR(20);
    DECLARE v_product_name VARCHAR(150);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT status INTO v_customer_status
    FROM customer
    WHERE customer_id = p_customer_id AND deleted_at IS NULL;

    IF v_customer_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Khách hàng không tồn tại trong hệ thống!';
    END IF;

    IF v_customer_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tài khoản khách hàng không ở trạng thái active, không thể đặt hàng!';
    END IF;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số lượng đặt mua phải lớn hơn 0!';
    END IF;

    SELECT product_name, price, status INTO v_product_name, v_price, v_product_status
    FROM product
    WHERE product_id = p_product_id AND deleted_at IS NULL;

    IF v_product_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sản phẩm không tồn tại trong hệ thống!';
    END IF;

    IF v_product_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sản phẩm hiện không hoạt động kinh doanh!';
    END IF;

    SELECT quantity INTO v_stock
    FROM inventory
    WHERE product_id = p_product_id;

    IF v_stock IS NULL OR v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sản phẩm không đủ hàng trong kho!';
    END IF;

    START TRANSACTION;

    SET v_subtotal = v_price * p_quantity;

    INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address)
    VALUES (p_customer_id, NOW(), 'pending', v_subtotal, p_shipping_address);

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal)
    VALUES (p_order_id, p_product_id, p_quantity, v_price, v_subtotal);

    UPDATE inventory
    SET quantity = quantity - p_quantity,
        updated_at = NOW()
    WHERE product_id = p_product_id;

    UPDATE product
    SET stock_quantity = stock_quantity - p_quantity,
        updated_at = NOW()
    WHERE product_id = p_product_id;

    INSERT INTO payment (order_id, payment_method, payment_status, amount, transaction_code)
    VALUES (
        p_order_id, 
        IFNULL(p_payment_method, 'COD'), 
        'pending', 
        v_subtotal, 
        CONCAT('TXN-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(p_order_id, 4, '0'))
    );

    COMMIT;
END //


-- Hủy đơn hàng và hoàn lại tồn kho
CREATE PROCEDURE sp_cancel_order(
    IN p_order_id INT,
    IN p_cancel_reason TEXT
)
BEGIN
    DECLARE v_current_status VARCHAR(20);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_prod_id INT;
    DECLARE v_qty INT;

    DECLARE cur_items CURSOR FOR 
        SELECT product_id, quantity FROM order_item WHERE order_id = p_order_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT status INTO v_current_status
    FROM orders
    WHERE order_id = p_order_id;

    IF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Đơn hàng không tồn tại!';
    END IF;

    IF v_current_status IN ('shipped', 'delivered') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Đơn hàng đã được giao hoặc đang vận chuyển, không thể hủy!';
    END IF;

    IF v_current_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Đơn hàng này đã được hủy trước đó!';
    END IF;

    START TRANSACTION;

    UPDATE orders
    SET status = 'cancelled'
    WHERE order_id = p_order_id;

    OPEN cur_items;
    read_loop: LOOP
        FETCH cur_items INTO v_prod_id, v_qty;
        IF done THEN
            LEAVE read_loop;
        END IF;

        UPDATE inventory
        SET quantity = quantity + v_qty,
            updated_at = NOW()
        WHERE product_id = v_prod_id;

        UPDATE product
        SET stock_quantity = stock_quantity + v_qty,
            updated_at = NOW()
        WHERE product_id = v_prod_id;
    END LOOP;
    CLOSE cur_items;

    UPDATE payment
    SET payment_status = CASE 
            WHEN payment_status = 'completed' THEN 'refunded'
            ELSE 'failed'
        END
    WHERE order_id = p_order_id;

    COMMIT;
END //


-- Tổng tiền đã thanh toán thành công của một khách hàng
CREATE FUNCTION fn_get_customer_total_spent(p_customer_id INT)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(o.total_amount), 0.00) INTO v_total
    FROM orders o
    INNER JOIN payment p ON o.order_id = p.order_id
    WHERE o.customer_id = p_customer_id 
      AND o.status <> 'cancelled'
      AND p.payment_status = 'completed';

    RETURN v_total;
END //

DELIMITER ;
