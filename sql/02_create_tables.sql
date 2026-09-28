-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 02_create_tables.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Tạo 7 bảng thực thể chính theo chuẩn 3NF
-- ============================================================

USE online_shopping_db;

-- Tắt kiểm tra khóa ngoại tạm thời để xóa các bảng cũ an toàn
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS customer;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- 1. BẢNG: customer (Quản lý khách hàng)
-- ------------------------------------------------------------
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính tài khoản khách hàng',
    full_name VARCHAR(100) NOT NULL COMMENT 'Họ và tên khách hàng',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Địa chỉ email đăng nhập duy nhất',
    phone VARCHAR(20) UNIQUE COMMENT 'Số điện thoại liên hệ duy nhất',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Mật khẩu đã băm bảo mật',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo tài khoản',
    status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT 'Trạng thái: active, inactive, blocked',
    deleted_at DATETIME NULL DEFAULT NULL COMMENT 'Thời gian soft delete nếu tài khoản bị xóa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lưu trữ thông tin tài khoản khách hàng';

-- ------------------------------------------------------------
-- 2. BẢNG: category (Quản lý danh mục sản phẩm)
-- ------------------------------------------------------------
CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính danh mục',
    category_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Tên danh mục duy nhất',
    description TEXT COMMENT 'Mô tả chi tiết về danh mục',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo danh mục'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục phân loại các sản phẩm';

-- ------------------------------------------------------------
-- 3. BẢNG: product (Quản lý sản phẩm)
-- ------------------------------------------------------------
CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính sản phẩm',
    category_id INT NOT NULL COMMENT 'Khóa ngoại tham chiếu bảng category',
    product_name VARCHAR(150) NOT NULL COMMENT 'Tên sản phẩm',
    description TEXT COMMENT 'Mô tả chi tiết tính năng sản phẩm',
    price DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Giá niêm yết sản phẩm (>= 0)',
    stock_quantity INT NOT NULL DEFAULT 0 COMMENT 'Số lượng hàng hiển thị (>= 0)',
    status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT 'Trạng thái: active, inactive, out_of_stock',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày đăng sản phẩm',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật thông tin gần nhất',
    deleted_at DATETIME NULL DEFAULT NULL COMMENT 'Thời gian xóa mềm nếu ngừng bán'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin chi tiết sản phẩm kinh doanh';

-- ------------------------------------------------------------
-- 4. BẢNG: inventory (Quản lý tồn kho thực tế - Quan hệ 1:1 với product)
-- ------------------------------------------------------------
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính tồn kho',
    product_id INT NOT NULL UNIQUE COMMENT 'Khóa ngoại 1:1 tham chiếu bảng product',
    quantity INT NOT NULL DEFAULT 0 COMMENT 'Số lượng tồn kho thực tế (>= 0)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm kiểm kê/cập nhật kho gần nhất'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Theo dõi số lượng tồn kho theo sản phẩm (quan hệ 1:1)';

-- ------------------------------------------------------------
-- 5. BẢNG: orders (Quản lý đơn đặt hàng)
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính đơn hàng',
    customer_id INT NOT NULL COMMENT 'Khóa ngoại tham chiếu khách hàng đặt',
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm đặt hàng',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'Trạng thái: pending, processing, shipped, delivered, cancelled',
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Tổng giá trị đơn hàng (>= 0)',
    shipping_address TEXT NOT NULL COMMENT 'Địa chỉ giao hàng chi tiết'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn đặt hàng từ khách hàng';

-- ------------------------------------------------------------
-- 6. BẢNG: order_item (Chi tiết đơn hàng - Bảng trung gian giải quyết quan hệ N:N)
-- ------------------------------------------------------------
CREATE TABLE order_item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính dòng chi tiết đơn hàng',
    order_id INT NOT NULL COMMENT 'Khóa ngoại tham chiếu đơn hàng',
    product_id INT NOT NULL COMMENT 'Khóa ngoại tham chiếu sản phẩm',
    quantity INT NOT NULL DEFAULT 1 COMMENT 'Số lượng đặt mua (> 0)',
    unit_price DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Đơn giá chốt tại thời điểm mua (>= 0)',
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Thành tiền = quantity * unit_price (>= 0)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết các sản phẩm trong từng đơn hàng';

-- ------------------------------------------------------------
-- 7. BẢNG: payment (Quản lý thanh toán - Quan hệ 1:1 với orders)
-- ------------------------------------------------------------
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa chính thanh toán',
    order_id INT NOT NULL UNIQUE COMMENT 'Khóa ngoại 1:1 tham chiếu đơn hàng',
    payment_method VARCHAR(50) NOT NULL COMMENT 'Phương thức: Credit Card, Bank Transfer, COD, E-Wallet',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'Trạng thái: pending, completed, failed, refunded',
    amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Số tiền thanh toán (>= 0)',
    paid_at DATETIME NULL DEFAULT NULL COMMENT 'Thời điểm hoàn tất thanh toán',
    transaction_code VARCHAR(100) UNIQUE COMMENT 'Mã đối soát giao dịch duy nhất'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin giao dịch thanh toán cho đơn hàng';
