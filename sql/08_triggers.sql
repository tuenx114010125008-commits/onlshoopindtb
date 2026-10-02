-- File: 08_triggers.sql

USE online_shopping_db;

DROP TRIGGER IF EXISTS trg_calc_order_item_subtotal_insert;
DROP TRIGGER IF EXISTS trg_calc_order_item_subtotal_update;
DROP TRIGGER IF EXISTS trg_update_order_total_insert;
DROP TRIGGER IF EXISTS trg_update_order_total_update;
DROP TRIGGER IF EXISTS trg_update_order_total_delete;

DELIMITER //

-- Tự động tính subtotal = quantity * unit_price khi thêm dòng order_item
CREATE TRIGGER trg_calc_order_item_subtotal_insert
BEFORE INSERT ON order_item
FOR EACH ROW
BEGIN
    IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
        SET NEW.unit_price = (SELECT price FROM product WHERE product_id = NEW.product_id);
    END IF;
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


-- Tự động cập nhật total_amount trong orders khi order_item thay đổi
CREATE TRIGGER trg_update_order_total_insert
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_new_total
    FROM order_item WHERE order_id = NEW.order_id;

    UPDATE orders SET total_amount = v_new_total WHERE order_id = NEW.order_id;
    UPDATE payment SET amount = v_new_total
        WHERE order_id = NEW.order_id AND payment_status = 'pending';
END //

CREATE TRIGGER trg_update_order_total_update
AFTER UPDATE ON order_item
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_new_total
    FROM order_item WHERE order_id = NEW.order_id;

    UPDATE orders SET total_amount = v_new_total WHERE order_id = NEW.order_id;
    UPDATE payment SET amount = v_new_total
        WHERE order_id = NEW.order_id AND payment_status = 'pending';
END //

CREATE TRIGGER trg_update_order_total_delete
AFTER DELETE ON order_item
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_new_total
    FROM order_item WHERE order_id = OLD.order_id;

    UPDATE orders SET total_amount = v_new_total WHERE order_id = OLD.order_id;
    UPDATE payment SET amount = v_new_total
        WHERE order_id = OLD.order_id AND payment_status = 'pending';
END //

DELIMITER ;
