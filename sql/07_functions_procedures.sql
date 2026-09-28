-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 07_functions_procedures.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Xây dựng Stored Procedures và Functions xử lý nghiệp vụ
-- ============================================================

USE online_shopping_db;

DROP PROCEDURE IF EXISTS sp_create_order;
DROP PROCEDURE IF EXISTS sp_cancel_order;
DROP FUNCTION IF EXISTS fn_get_customer_total_spent;

DELIMITER //

-- ------------------------------------------------------------
-- 1. PROCEDURE: sp_create_order
-- Nghiệp vụ: Tạo một đơn hàng mới an toàn toàn vẹn dữ liệu
-- Các bước xử lý:
--   1. Kiểm tra khách hàng tồn tại và còn hoạt động (active).
--   2. Kiểm tra sản phẩm tồn tại và đang kinh doanh.
--   3. Kiểm tra số lượng tồn kho có đáp ứng số lượng đặt mua hay không.
--   4. Bắt đầu TRANSACTION.
--   5. Khởi tạo bản ghi orders với thông tin giao hàng.
--   6. Thêm dòng chi tiết sản phẩm vào order_item.
--   7. Trừ số lượng tồn kho trong bảng inventory và product.
--   8. Khởi tạo bản ghi thanh toán tương ứng trong bảng payment.
--   9. Trả về p_order_id vừa tạo qua tham số OUT.
-- ------------------------------------------------------------
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

    -- Handler xử lý rollback tự động nếu xảy ra lỗi SQL bất ngờ
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Kiểm tra khách hàng
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

    -- 2. Kiểm tra số lượng mua hợp lệ
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số lượng đặt mua phải lớn hơn 0!';
    END IF;

    -- 3. Kiểm tra sản phẩm
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

    -- 4. Kiểm tra tồn kho
    SELECT quantity INTO v_stock
    FROM inventory
    WHERE product_id = p_product_id;

    IF v_stock IS NULL OR v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sản phẩm không đủ hàng trong kho!';
    END IF;

    -- 5. Bắt đầu TRANSACTION tạo đơn
    START TRANSACTION;

    SET v_subtotal = v_price * p_quantity;

    -- 6. Tạo đơn hàng mới
    INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address)
    VALUES (p_customer_id, NOW(), 'pending', v_subtotal, p_shipping_address);

    SET p_order_id = LAST_INSERT_ID();

    -- 7. Thêm chi tiết đơn hàng
    INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal)
    VALUES (p_order_id, p_product_id, p_quantity, v_price, v_subtotal);

    -- 8. Cập nhật tồn kho
    UPDATE inventory
    SET quantity = quantity - p_quantity,
        updated_at = NOW()
    WHERE product_id = p_product_id;

    UPDATE product
    SET stock_quantity = stock_quantity - p_quantity,
        updated_at = NOW()
    WHERE product_id = p_product_id;

    -- 9. Tạo giao dịch thanh toán khởi tạo
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


-- ------------------------------------------------------------
-- 2. PROCEDURE: sp_cancel_order
-- Nghiệp vụ: Hủy đơn hàng và hoàn lại số lượng tồn kho tự động
-- ------------------------------------------------------------
CREATE PROCEDURE sp_cancel_order(
    IN p_order_id INT,
    IN p_cancel_reason TEXT
)
BEGIN
    DECLARE v_current_status VARCHAR(20);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_prod_id INT;
    DECLARE v_qty INT;

    -- Con trỏ duyệt qua các sản phẩm trong đơn để hoàn kho
    DECLARE cur_items CURSOR FOR 
        SELECT product_id, quantity FROM order_item WHERE order_id = p_order_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Kiểm tra đơn hàng tồn tại
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

    -- 2. Cập nhật trạng thái đơn hàng sang cancelled
    UPDATE orders
    SET status = 'cancelled'
    WHERE order_id = p_order_id;

    -- 3. Mở con trỏ hoàn kho
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

    -- 4. Cập nhật trạng thái thanh toán
    UPDATE payment
    SET payment_status = CASE 
            WHEN payment_status = 'completed' THEN 'refunded'
            ELSE 'failed'
        END
    WHERE order_id = p_order_id;

    COMMIT;
END //


-- ------------------------------------------------------------
-- 3. FUNCTION: fn_get_customer_total_spent
-- Nghiệp vụ: Tính tổng tiền khách hàng đã thanh toán thành công
-- ------------------------------------------------------------
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
