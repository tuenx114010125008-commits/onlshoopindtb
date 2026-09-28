-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: queries/queries.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Tập hợp 15 câu truy vấn SQL từ cơ bản đến nâng cao
-- ============================================================

USE online_shopping_db;

-- ============================================================
-- Q01 - SELECT CƠ BẢN
-- Mục đích: Tìm các sản phẩm đang hoạt động kinh doanh (active),
--          sắp xếp theo giá giảm dần, lấy ra 10 sản phẩm đắt nhất.
-- Kỹ thuật: SELECT, WHERE, ORDER BY, LIMIT
-- ============================================================
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity,
    status
FROM product
WHERE status = 'active' AND deleted_at IS NULL
ORDER BY price DESC
LIMIT 10;


-- ============================================================
-- Q02 - INNER JOIN
-- Mục đích: Hiển thị thông tin sản phẩm cùng tên danh mục tương ứng.
-- Kỹ thuật: INNER JOIN giữa PRODUCT và CATEGORY
-- ============================================================
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock_quantity
FROM product p
INNER JOIN category c ON p.category_id = c.category_id
WHERE p.deleted_at IS NULL
ORDER BY c.category_name ASC, p.price DESC;


-- ============================================================
-- Q03 - LEFT JOIN
-- Mục đích: Hiển thị toàn bộ khách hàng và tổng số đơn hàng đã đặt,
--          kể cả các khách hàng chưa từng đặt đơn nào (kết quả hiển thị 0).
-- Kỹ thuật: LEFT JOIN giữa CUSTOMER và ORDERS, GROUP BY, COUNT
-- ============================================================
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    COUNT(o.order_id) AS total_orders
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.deleted_at IS NULL
GROUP BY c.customer_id, c.full_name, c.email, c.phone
ORDER BY total_orders DESC, c.customer_id ASC;


-- ============================================================
-- Q04 - GROUP BY + COUNT
-- Mục đích: Thống kê số lượng sản phẩm và lượng tồn kho trong từng danh mục.
-- Kỹ thuật: GROUP BY, COUNT, SUM
-- ============================================================
SELECT 
    c.category_id,
    c.category_name,
    COUNT(p.product_id) AS total_products,
    COALESCE(SUM(p.stock_quantity), 0) AS total_inventory_units
FROM category c
LEFT JOIN product p ON c.category_id = p.category_id AND p.deleted_at IS NULL
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC, c.category_name ASC;


-- ============================================================
-- Q05 - GROUP BY + SUM
-- Mục đích: Thống kê tổng doanh thu thực tế thu được theo từng khách hàng
--          (chỉ tính các đơn hàng có trạng thái không bị hủy).
-- Kỹ thuật: GROUP BY, SUM, JOIN
-- ============================================================
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(o.order_id) AS completed_orders,
    SUM(o.total_amount) AS total_revenue
FROM customer c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY total_revenue DESC;


-- ============================================================
-- Q06 - HÀM TỔNG HỢP: AVG / MIN / MAX
-- Mục đích: Thống kê giá bán sản phẩm: giá trung bình, giá rẻ nhất và đắt nhất.
-- Kỹ thuật: AVG, MIN, MAX, ROUND
-- ============================================================
SELECT 
    ROUND(AVG(price), 0) AS average_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    COUNT(*) AS total_active_products
FROM product
WHERE status = 'active' AND deleted_at IS NULL;


-- ============================================================
-- Q07 - SUBQUERY (TRUY VẤN CON)
-- Mục đích: Tìm các sản phẩm có giá bán cao hơn mức giá trung bình của toàn bộ cửa hàng.
-- Kỹ thuật: Subquery trong mệnh đề WHERE
-- ============================================================
SELECT 
    product_id,
    product_name,
    price,
    (SELECT ROUND(AVG(price), 0) FROM product WHERE deleted_at IS NULL) AS overall_avg_price
FROM product
WHERE price > (SELECT AVG(price) FROM product WHERE deleted_at IS NULL)
  AND deleted_at IS NULL
ORDER BY price DESC;


-- ============================================================
-- Q08 - WINDOW FUNCTION (MySQL 8.0+)
-- Mục đích: Xếp hạng sản phẩm theo tổng doanh thu bán được.
-- Kỹ thuật: DENSE_RANK() OVER (ORDER BY ... DESC)
-- ============================================================
SELECT 
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity), 0) AS total_sold_quantity,
    COALESCE(SUM(oi.subtotal), 0) AS total_product_revenue,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(oi.subtotal), 0) DESC) AS revenue_rank
FROM product p
LEFT JOIN order_item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue_rank ASC;


-- ============================================================
-- Q09 - MỆNH ĐỀ CASE WHEN (PHÂN LOẠI KHÁCH HÀNG)
-- Mục đích: Phân loại nhóm khách hàng dựa trên tổng số tiền đã mua sắm:
--          - VIP: >= 30.000.000 VNĐ
--          - Regular: >= 10.000.000 VNĐ
--          - Normal: < 10.000.000 VNĐ (có phát sinh đơn)
--          - New: Chưa có đơn hàng nào
-- Kỹ thuật: CASE WHEN, COALESCE, LEFT JOIN, GROUP BY
-- ============================================================
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COALESCE(SUM(o.total_amount), 0) AS total_spending,
    CASE 
        WHEN COALESCE(SUM(o.total_amount), 0) >= 30000000.00 THEN 'VIP Member'
        WHEN COALESCE(SUM(o.total_amount), 0) >= 10000000.00 THEN 'Regular Member'
        WHEN COALESCE(SUM(o.total_amount), 0) > 0.00 THEN 'Normal Member'
        ELSE 'New Lead (No orders)'
    END AS customer_tier
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status <> 'cancelled'
WHERE c.deleted_at IS NULL
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY total_spending DESC;


-- ============================================================
-- Q10 - TÌM DỮ LIỆU KHÔNG TỒN TẠI (NON-EXISTENT DATA)
-- Mục đích: Tìm danh sách các khách hàng chưa từng phát sinh bất kỳ đơn hàng nào.
-- Kỹ thuật: Cách 1 dùng LEFT JOIN + IS NULL, Cách 2 dùng NOT EXISTS
-- ============================================================
-- Cách 1: LEFT JOIN kết hợp WHERE o.order_id IS NULL
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    c.created_at
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ============================================================
-- Q11 - TÌM DỮ LIỆU TRÙNG LẶP (DUPLICATE DATA CHECK)
-- Mục đích: Kiểm tra tính duy nhất, phát hiện các email hoặc số điện thoại bị trùng.
-- Kỹ thuật: GROUP BY + HAVING COUNT(*) > 1
-- ============================================================
SELECT 
    email,
    COUNT(*) AS occurrence_count
FROM customer
GROUP BY email
HAVING COUNT(*) > 1;


-- ============================================================
-- Q12 - PAGINATION (PHÂN TRANG SẢN PHẨM)
-- Mục đích: Phân trang danh sách sản phẩm phục vụ hiển thị trên giao diện web thương mại điện tử.
-- Kỹ thuật: LIMIT và OFFSET
-- ============================================================
-- Trang 1 (10 sản phẩm đầu tiên)
SELECT product_id, product_name, price, stock_quantity
FROM product
WHERE status = 'active'
ORDER BY product_id ASC
LIMIT 10 OFFSET 0;

-- Trang 2 (10 sản phẩm tiếp theo)
SELECT product_id, product_name, price, stock_quantity
FROM product
WHERE status = 'active'
ORDER BY product_id ASC
LIMIT 10 OFFSET 10;


-- ============================================================
-- Q13 - CTE (COMMON TABLE EXPRESSION - MySQL 8.0+)
-- Mục đích: Sử dụng CTE để tính tổng doanh thu từng khách hàng,
--          sau đó lọc ra danh sách những khách hàng có doanh thu vượt trên 20 triệu.
-- Kỹ thuật: WITH ... AS (...)
-- ============================================================
WITH customer_revenue_cte AS (
    SELECT 
        c.customer_id,
        c.full_name,
        c.email,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS revenue
    FROM customer c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status <> 'cancelled'
    GROUP BY c.customer_id, c.full_name, c.email
)
SELECT 
    customer_id,
    full_name,
    email,
    order_count,
    revenue
FROM customer_revenue_cte
WHERE revenue >= 20000000.00
ORDER BY revenue DESC;


-- ============================================================
-- Q14 - NESTED QUERY PHỨC TẠP
-- Mục đích: Tìm các sản phẩm có doanh thu bán ra cao hơn mức doanh thu trung bình
--          của các sản phẩm trong cùng danh mục (category) đó.
-- Kỹ thuật: Correlated Subquery, CTE, GROUP BY
-- ============================================================
WITH product_revenue_cte AS (
    SELECT 
        p.product_id,
        p.category_id,
        p.product_name,
        COALESCE(SUM(oi.subtotal), 0) AS product_revenue
    FROM product p
    LEFT JOIN order_item oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.category_id, p.product_name
)
SELECT 
    pr.product_id,
    pr.product_name,
    c.category_name,
    pr.product_revenue,
    ROUND(cat_avg.avg_category_rev, 0) AS category_avg_revenue
FROM product_revenue_cte pr
INNER JOIN category c ON pr.category_id = c.category_id
INNER JOIN (
    SELECT 
        category_id, 
        AVG(product_revenue) AS avg_category_rev
    FROM product_revenue_cte
    GROUP BY category_id
) cat_avg ON pr.category_id = cat_avg.category_id
WHERE pr.product_revenue > cat_avg.avg_category_rev
ORDER BY pr.product_revenue DESC;


-- ============================================================
-- Q15 - QUERY TỔNG HỢP (BÁO CÁO DOANH THU THEO THÁNG)
-- Mục đích: Tạo bảng báo cáo tình hình kinh doanh tổng thể theo tháng:
--          - Tổng số đơn đặt hàng
--          - Tổng số đơn đã thanh toán thành công
--          - Doanh thu thực tế (chỉ tính đơn đã hoàn tất thanh toán)
--          - Giá trị trung bình trên mỗi đơn hàng (AOV - Average Order Value)
-- Kỹ thuật: DATE_FORMAT, COUNT, SUM, ROUND, CASE WHEN, GROUP BY, ORDER BY
-- ============================================================
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS report_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN p.payment_status = 'completed' THEN o.order_id END) AS paid_orders,
    COALESCE(SUM(CASE WHEN p.payment_status = 'completed' THEN p.amount ELSE 0 END), 0) AS total_realized_revenue,
    ROUND(
        COALESCE(
            SUM(CASE WHEN p.payment_status = 'completed' THEN p.amount ELSE 0 END) / 
            NULLIF(COUNT(DISTINCT CASE WHEN p.payment_status = 'completed' THEN o.order_id END), 0), 
            0
        ), 0
    ) AS average_order_value
FROM orders o
LEFT JOIN payment p ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY report_month ASC;
