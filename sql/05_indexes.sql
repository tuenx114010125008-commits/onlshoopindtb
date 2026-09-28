-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 05_indexes.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Thiết lập chỉ mục B-Tree (Indexes) tối ưu hóa hiệu năng truy vấn
-- ============================================================

USE online_shopping_db;

-- ------------------------------------------------------------
-- 1. INDEX BẮT BUỘC THEO ĐỀ BÀI
-- ------------------------------------------------------------

-- Index 1: Tìm kiếm đơn hàng theo khách hàng nhanh chóng
-- Thường dùng trong màn hình "Lịch sử mua hàng của tôi" và phép JOIN giữa customer - orders
CREATE INDEX idx_orders_customer_id 
    ON orders(customer_id);

-- Index 2: Tìm kiếm sản phẩm theo danh mục
-- Thường dùng khi khách hàng duyệt sản phẩm theo từng chuyên mục trên website
CREATE INDEX idx_product_category_id 
    ON product(category_id);


-- ------------------------------------------------------------
-- 2. CÁC INDEX BỔ SUNG NÂNG CAO (OPTIMIZATION)
-- ------------------------------------------------------------

-- Index 3: Lọc đơn hàng theo khoảng thời gian
-- Thường dùng cho các báo cáo doanh thu theo ngày/tháng/quý hoặc dashboard quản trị
CREATE INDEX idx_orders_order_date 
    ON orders(order_date);

-- Index 4: Sắp xếp và lọc sản phẩm theo khoảng giá
-- Thường dùng khi người dùng lọc: giá từ X đến Y hoặc ORDER BY price ASC/DESC
CREATE INDEX idx_product_price 
    ON product(price);

-- Index 5: Lọc đơn hàng theo trạng thái xử lý
-- Thường dùng cho bộ phận vận hành/kho: tìm các đơn pending hoặc processing
CREATE INDEX idx_orders_status 
    ON orders(status);

-- Index 6: Lọc chi tiết đơn hàng theo sản phẩm
-- Thường dùng khi thống kê số lượng bán ra của một sản phẩm và JOIN orders - order_item - product
CREATE INDEX idx_order_item_product_id 
    ON order_item(product_id);
