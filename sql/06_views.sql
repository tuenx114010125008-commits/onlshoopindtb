-- File: 06_views.sql

USE online_shopping_db;

-- tổng quan đơn hàng kèm thông tin khách hàng và thanh toán
CREATE OR REPLACE VIEW v_order_summary AS
SELECT 
    o.order_id,
    c.full_name AS customer_name,
    c.email AS customer_email,
    c.phone AS customer_phone,
    o.order_date,
    o.status AS order_status,
    o.total_amount,
    o.shipping_address,
    COALESCE(p.payment_status, 'unpaid') AS payment_status,
    COALESCE(p.payment_method, 'none') AS payment_method,
    p.transaction_code,
    p.paid_at
FROM orders o
INNER JOIN customer c ON o.customer_id = c.customer_id
LEFT JOIN payment p ON o.order_id = p.order_id;


-- tổng chi tiêu và hạng khách hàng
CREATE OR REPLACE VIEW v_customer_spending_summary AS
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
    CASE 
        WHEN COALESCE(SUM(o.total_amount), 0.00) >= 30000000.00 THEN 'VIP'
        WHEN COALESCE(SUM(o.total_amount), 0.00) >= 10000000.00 THEN 'Gold'
        WHEN COALESCE(SUM(o.total_amount), 0.00) > 0.00 THEN 'Silver'
        ELSE 'Potential'
    END AS customer_tier
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status <> 'cancelled'
GROUP BY c.customer_id, c.full_name, c.email, c.phone;


-- tình hình tồn kho theo sản phẩm
CREATE OR REPLACE VIEW v_product_inventory_status AS
SELECT 
    p.product_id,
    p.product_name,
    cat.category_name,
    p.price,
    p.stock_quantity AS product_stock,
    COALESCE(i.quantity, 0) AS inventory_stock,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    CASE 
        WHEN COALESCE(i.quantity, 0) = 0 THEN 'Hết hàng (Out of Stock)'
        WHEN COALESCE(i.quantity, 0) <= 5 THEN 'Sắp hết hàng (Low Stock)'
        ELSE 'Còn hàng (In Stock)'
    END AS inventory_status
FROM product p
INNER JOIN category cat ON p.category_id = cat.category_id
LEFT JOIN inventory i ON p.product_id = i.product_id
LEFT JOIN order_item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, cat.category_name, p.price, p.stock_quantity, i.quantity;
