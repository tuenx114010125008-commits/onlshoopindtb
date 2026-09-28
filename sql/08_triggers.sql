-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 08_triggers.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Thiết lập các Triggers tự động hóa nghiệp vụ và bảo toàn tính nhất quán
-- ============================================================

USE online_shopping_db;

DROP TRIGGER IF EXISTS trg_calc_order_item_subtotal_insert;
DROP TRIGGER IF EXISTS trg_calc_order_item_subtotal_update;
DROP TRIGGER IF EXISTS trg_update_order_total_insert;
DROP TRIGGER IF EXISTS trg_update_order_total_update;
DROP TRIGGER IF EXISTS trg_update_order_total_delete;

DELIMITER //

-- ------------------------------------------------------------
-- 1. TRIGGER 1: TỰ ĐỘNG TÍNH SUBTOTAL TRONG ORDER_ITEM (BẮT BUỘC)
-- Công thức: subtotal = quantity * unit_price
-- ------------------------------------------------------------
CREATE TRIGGER trg_calc_order_item_subtotal_insert
BEFORE INSERT ON order_item
FOR EACH ROW
BEGIN
    -- Nếu đơn giá chưa được truyền hoặc bằng 0, tự động lấy giá niêm yết từ bảng product
    IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
        SET NEW.unit_price = (SELECT price FROM product WHERE product_id = NEW.product_id);
    END IF;

    -- Tự động tính thành tiền
    SET NEW.subtotal = NEW.quantity * NEW.unit_price;
END //

CREATE TRIGGER trg_calc_order_item_subtotal_update
BEFORE UPDATE ON order_item
FOR EACH ROW
BEGIN
    IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
        SET NEW.unit_price = (SELECT price FROM product WHERE product_id = NEW.product_id);
    END IF;

    SET NEW.subtotal = NEW.quantity * NEW.unit_price;
END //


-- ------------------------------------------------------------
-- 2. TRIGGER 2: TỰ ĐỘNG CẬP NHẬT TOTAL_AMOUNT VÀO BẢNG ORDERS
-- Khi thêm, sửa hoặc xóa dòng chi tiết sản phẩm, tổng tiền trong orders sẽ tự cập nhật lại
-- ------------------------------------------------------------
CREATE TRIGGER trg_update_order_total_insert
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_new_total
    FROM order_item
    WHERE order_id = NEW.order_id;

    UPDATE orders
    SET total_amount = v_new_total
    WHERE order_id = NEW.order_id;

    UPDATE payment
    SET amount = v_new_total
    WHERE order_id = NEW.order_id AND payment_status = 'pending';
END //

CREATE TRIGGER trg_update_order_total_update
AFTER UPDATE ON order_item
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_new_total
    FROM order_item
    WHERE order_id = NEW.order_id;

    UPDATE orders
    SET total_amount = v_new_total
    WHERE order_id = NEW.order_id;

    UPDATE payment
    SET amount = v_new_total
    WHERE order_id = NEW.order_id AND payment_status = 'pending';
END //

CREATE TRIGGER trg_update_order_total_delete
AFTER DELETE ON order_item
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_new_total
    FROM order_item
    WHERE order_id = OLD.order_id;

    UPDATE orders
    SET total_amount = v_new_total
    WHERE order_id = OLD.order_id;

    UPDATE payment
    SET amount = v_new_total
    WHERE order_id = OLD.order_id AND payment_status = 'pending';
END //

DELIMITER ;
