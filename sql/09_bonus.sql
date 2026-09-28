-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 09_bonus.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Triển khai các tính năng nâng cao (Bonus features):
--           1. Tối ưu truy vấn với EXPLAIN ANALYZE
--           2. Quản lý giao dịch Transaction (COMMIT / ROLLBACK)
--           3. Hệ thống ghi nhật ký thay đổi Audit Log
--           4. Xóa mềm (Soft Delete)
-- ============================================================

USE online_shopping_db;

-- ============================================================
-- PHẦN 1: TỐI ƯU QUERY VỚI EXPLAIN ANALYZE (QUERY OPTIMIZATION)
-- ============================================================

-- Tình huống: Truy vấn tìm danh sách các đơn hàng của khách hàng có ID cụ thể
-- kèm chi tiết sản phẩm và tổng tiền.

-- 1.1. Chạy EXPLAIN ANALYZE trên MySQL 8.0+ để phân tích cây kế hoạch thực thi:
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

-- Giải thích kết quả EXPLAIN ANALYZE trên MySQL:
-- - Khi chưa có index trên orders(customer_id): MySQL phải thực hiện Table scan trên orders (Cost cao).
-- - Khi đã có idx_orders_customer_id: Bộ tối ưu Optimizer sử dụng Index lookup (ref/range) trên idx_orders_customer_id.
-- - Thời gian thực thi (actual time) và số dòng duyệt qua (rows examined) giảm rõ rệt.


-- ============================================================
-- PHẦN 2: TRANSACTION XỬ LÝ ĐẶT HÀNG (ACID COMPLIANCE)
-- ============================================================

-- Kịch bản: Khách hàng số 2 (Trần Thị Bích) mua sản phẩm số 7 (Tai nghe Sony WH-1000XM5)
-- Toàn bộ quy trình phải nằm trong 1 Transaction đảm bảo tính nguyên tử (Atomicity).

START TRANSACTION;

-- Bước 1: Tạo đơn hàng
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address)
VALUES (2, NOW(), 'pending', 15980000.00, '456 Nguyễn Huệ, Quận 1, TP.HCM');

SET @new_order_id = LAST_INSERT_ID();

-- Bước 2: Thêm chi tiết đơn hàng (mua 2 chiếc giá 7.990.000)
INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal)
VALUES (@new_order_id, 7, 2, 7990000.00, 15980000.00);

-- Bước 3: Trừ tồn kho
UPDATE inventory 
SET quantity = quantity - 2, updated_at = NOW() 
WHERE product_id = 7;

UPDATE product 
SET stock_quantity = stock_quantity - 2, updated_at = NOW() 
WHERE product_id = 7;

-- Bước 4: Tạo thanh toán
INSERT INTO payment (order_id, payment_method, payment_status, amount, transaction_code)
VALUES (@new_order_id, 'Bank Transfer', 'pending', 15980000.00, CONCAT('TXN-TRANS-', @new_order_id));

-- Xác nhận giao dịch thành công (Nếu lỗi, dùng lệnh ROLLBACK;)
COMMIT;


-- ============================================================
-- PHẦN 3: AUDIT LOG (GHI NHẬT KÝ THAY ĐỔI DỮ LIỆU)
-- ============================================================

-- 3.1. Tạo bảng audit_log
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,      -- INSERT, UPDATE, DELETE
    record_id INT,
    old_value JSON,
    new_value JSON,
    changed_by VARCHAR(50) DEFAULT NULL COMMENT 'Tài khoản MySQL thực hiện thay đổi',
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nhật ký biến động dữ liệu';

-- 3.2. Trigger tự động ghi log cho bảng product khi cập nhật giá hoặc số lượng
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
        JSON_OBJECT(
            'price', OLD.price,
            'stock_quantity', OLD.stock_quantity,
            'status', OLD.status
        ),
        JSON_OBJECT(
            'price', NEW.price,
            'stock_quantity', NEW.stock_quantity,
            'status', NEW.status
        ),
        USER()
    );
END //

DELIMITER ;

-- 3.3. Test thử tính năng Audit Log
UPDATE product 
SET price = 28990000.00 
WHERE product_id = 1;

-- Kiểm tra kết quả ghi log:
-- SELECT * FROM audit_log ORDER BY changed_at DESC;


-- ============================================================
-- PHẦN 4: SOFT DELETE (XÓA MỀM)
-- ============================================================

-- Bảng customer và product đã có cột deleted_at DATETIME NULL.
-- Thay vì xóa vĩnh viễn (Hard delete làm mất dữ liệu lịch sử liên kết khóa ngoại),
-- ta đánh dấu thời điểm xóa.

-- 4.1. Stored Procedure soft delete cho customer
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

-- 4.2. View lọc ra khách hàng còn hoạt động (Active Customers Only)
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
