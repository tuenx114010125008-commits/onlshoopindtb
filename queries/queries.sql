-- File: queries/queries.sql

USE online_shopping_db;

-- Q01: 10 sản phẩm đắt nhất đang active
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


-- Q02: Sản phẩm kèm tên danh mục
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


-- Q03: Tất cả khách hàng và số đơn đã đặt (kể cả chưa có đơn)
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


-- Q04: Số sản phẩm và tổng tồn kho theo danh mục
SELECT 
    c.category_id,
    c.category_name,
    COUNT(p.product_id) AS total_products,
    COALESCE(SUM(p.stock_quantity), 0) AS total_inventory_units
FROM category c
LEFT JOIN product p ON c.category_id = p.category_id AND p.deleted_at IS NULL
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC, c.category_name ASC;


-- Q05: Tổng doanh thu theo khách hàng (bỏ qua đơn đã hủy)
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


-- Q06: Giá TB, thấp nhất, cao nhất của sản phẩm active
SELECT 
    ROUND(AVG(price), 0) AS average_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    COUNT(*) AS total_active_products
FROM product
WHERE status = 'active' AND deleted_at IS NULL;


-- Q07: Sản phẩm có giá cao hơn trung bình toàn cửa hàng
SELECT 
    product_id,
    product_name,
    price,
    (SELECT ROUND(AVG(price), 0) FROM product WHERE deleted_at IS NULL) AS overall_avg_price
FROM product
WHERE price > (SELECT AVG(price) FROM product WHERE deleted_at IS NULL)
  AND deleted_at IS NULL
ORDER BY price DESC;


-- Q08: Xếp hạng sản phẩm theo doanh thu
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


-- Q09: Phân loại khách hàng theo tổng chi tiêu (VIP / Regular / Normal / New)
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


-- Q10: Khách hàng chưa từng đặt đơn
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    c.created_at
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Q11: Kiểm tra email trùng
SELECT 
    email,
    COUNT(*) AS occurrence_count
FROM customer
GROUP BY email
HAVING COUNT(*) > 1;


-- Q12: Phân trang sản phẩm (trang 1 và trang 2)
SELECT product_id, product_name, price, stock_quantity
FROM product
WHERE status = 'active'
ORDER BY product_id ASC
LIMIT 10 OFFSET 0;

SELECT product_id, product_name, price, stock_quantity
FROM product
WHERE status = 'active'
ORDER BY product_id ASC
LIMIT 10 OFFSET 10;


-- Q13: CTE - khách hàng có doanh thu trên 20 triệu
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
SELECT customer_id, full_name, email, order_count, revenue
FROM customer_revenue_cte
WHERE revenue >= 20000000.00
ORDER BY revenue DESC;


-- Q14: Sản phẩm có doanh thu cao hơn mức TB trong cùng danh mục
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
    SELECT category_id, AVG(product_revenue) AS avg_category_rev
    FROM product_revenue_cte
    GROUP BY category_id
) cat_avg ON pr.category_id = cat_avg.category_id
WHERE pr.product_revenue > cat_avg.avg_category_rev
ORDER BY pr.product_revenue DESC;


-- Q15: Báo cáo doanh thu theo tháng (tổng đơn, đơn đã thanh toán, doanh thu thực, AOV)
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
