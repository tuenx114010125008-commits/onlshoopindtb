-- File: 03_insert_data.sql

USE online_shopping_db;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE payment;
TRUNCATE TABLE order_item;
TRUNCATE TABLE orders;
TRUNCATE TABLE inventory;
TRUNCATE TABLE product;
TRUNCATE TABLE category;
TRUNCATE TABLE customer;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO category (category_id, category_name, description, created_at) VALUES
(1, 'Điện thoại & Tablet', 'Các dòng điện thoại thông minh, máy tính bảng chính hãng', '2024-01-01 08:00:00'),
(2, 'Laptop & Máy tính', 'Máy tính xách tay văn phòng, đồ họa, gaming và linh kiện', '2024-01-01 08:00:00'),
(3, 'Phụ kiện công nghệ', 'Cáp sạc, pin dự phòng, củ sạc nhanh, bao da ốp lưng', '2024-01-02 09:00:00'),
(4, 'Thiết bị âm thanh', 'Tai nghe True Wireless, tai nghe chụp tai, loa bluetooth', '2024-01-02 09:30:00'),
(5, 'Đồng hồ thông minh', 'Smartwatch theo dõi sức khỏe, thể thao chuyên nghiệp', '2024-01-03 10:00:00'),
(6, 'Gia dụng thông minh', 'Robot hút bụi, nồi chiên không dầu, máy lọc không khí', '2024-01-03 10:30:00'),
(7, 'Thiết bị Gaming', 'Chuột gaming, bàn phím cơ, tay cầm chơi game console', '2024-01-04 11:00:00'),
(8, 'Máy ảnh & Quay phim', 'Máy ảnh mirrorless, action cam, gimbal chống rung', '2024-01-04 11:30:00'),
(9, 'Thiết bị mạng', 'Router Wi-Fi 6, Mesh Wi-Fi gia đình, bộ mở rộng sóng', '2024-01-05 13:00:00'),
(10, 'Phần mềm & Tiện ích', 'Hệ điều hành Windows, Office 365, phần mềm diệt virus', '2024-01-05 14:00:00');

INSERT INTO product (product_id, category_id, product_name, description, price, stock_quantity, status, created_at) VALUES
(1, 1, 'iPhone 15 Pro Max 256GB', 'Titan Tự Nhiên, Chip Apple A17 Pro mạnh mẽ', 29990000.00, 45, 'active', '2024-01-10 09:00:00'),
(2, 1, 'Samsung Galaxy S24 Ultra 512GB', 'Snapdragon 8 Gen 3 for Galaxy, Bút S-Pen tích hợp AI', 27500000.00, 30, 'active', '2024-01-10 09:30:00'),
(3, 1, 'Xiaomi 14 Ultra 512GB', 'Ống kính quang học Leica đỉnh cao, sạc 90W', 21990000.00, 15, 'active', '2024-01-11 10:00:00'),
(4, 2, 'MacBook Pro 14 inch M3 Pro', '18GB RAM, 512GB SSD, màn hình Liquid Retina XDR', 49990000.00, 20, 'active', '2024-01-12 11:00:00'),
(5, 2, 'Dell XPS 13 Plus 9320', 'Intel Core i7-1360P, 16GB RAM, 1TB SSD, 3.5K OLED Touch', 38500000.00, 12, 'active', '2024-01-12 11:30:00'),
(6, 2, 'ASUS ROG Zephyrus G16', 'Intel Core Ultra 9, RTX 4070 8GB, 32GB RAM, màn 2.5K 240Hz', 45000000.00, 8, 'active', '2024-01-13 14:00:00'),
(7, 4, 'Tai nghe chống ồn Sony WH-1000XM5', 'Chống ồn hàng đầu, thời lượng pin 30 giờ liên tục', 7990000.00, 50, 'active', '2024-01-14 15:00:00'),
(8, 4, 'Apple AirPods Pro 2 USB-C', 'Chíp H2, Adaptive Audio, khử tiếng ồn chủ động gấp 2 lần', 5690000.00, 80, 'active', '2024-01-14 15:30:00'),
(9, 4, 'Loa Bluetooth Marshall Stanmore III', 'Âm thanh phòng khách sống động phong cách vintage', 8990000.00, 25, 'active', '2024-01-15 16:00:00'),
(10, 3, 'Bàn phím cơ Logitech MX Mechanical', 'Tactile Quiet Switch, kết nối đa thiết bị, gõ êm ái', 3490000.00, 60, 'active', '2024-01-16 09:00:00'),
(11, 3, 'Chuột không dây Logitech MX Master 3S', 'Cảm biến 8K DPI Darkfield, con lăn điện từ MagSpeed cực êm', 2290000.00, 75, 'active', '2024-01-16 09:30:00'),
(12, 3, 'Củ sạc Anker GaNPrime 65W 3 cổng', 'Công nghệ sạc nhanh GaN III, 2 USB-C + 1 USB-A nhỏ gọn', 890000.00, 120, 'active', '2024-01-17 10:00:00'),
(13, 3, 'Cáp sạc Type-C Baseus Tungsten Gold 100W', 'Dây bọc dù siêu bền, hỗ trợ PD sạc nhanh Laptop và Mobile', 150000.00, 200, 'active', '2024-01-17 10:30:00'),
(14, 5, 'Apple Watch Ultra 2 GPS + Cellular 49mm', 'Vỏ titan chuẩn quân đội, lặn biển sâu 40m, pin 72h', 20490000.00, 18, 'active', '2024-01-18 11:00:00'),
(15, 5, 'Samsung Galaxy Watch 6 Classic 47mm', 'Viền xoay vật lý độc đáo, theo dõi giấc ngủ và ECG', 6990000.00, 22, 'active', '2024-01-18 11:30:00'),
(16, 6, 'Robot hút bụi lau nhà Roborock S8 Pro Ultra', 'Trạm sạc tự giặt giẻ, sấy khí nóng, lực hút 6000Pa', 24990000.00, 10, 'active', '2024-01-19 14:00:00'),
(17, 6, 'Nồi chiên không dầu Philips XXL HD9650', 'Công nghệ Twin TurboStar loại bỏ 90% dầu mỡ thừa', 4290000.00, 35, 'active', '2024-01-19 14:30:00'),
(18, 7, 'Bàn phím cơ Razer Huntsman V3 Pro Tenkeyless', 'Analog Optical Switch thế hệ 2, Rapid Trigger gaming', 4990000.00, 4, 'active', '2024-01-20 15:00:00'),
(19, 7, 'Tay cầm chơi game Xbox Wireless Controller', 'Hỗ trợ Bluetooth Xbox Series X/S, PC Windows, Android/iOS', 1490000.00, 3, 'active', '2024-01-20 15:30:00'),
(20, 9, 'Router Wi-Fi 6 Gaming ASUS RT-AX88U Pro', 'Tốc độ 6000Mbps, 2 cổng 2.5G WAN/LAN, RangeBoost Plus', 5990000.00, 2, 'active', '2024-01-21 16:00:00');

INSERT INTO inventory (inventory_id, product_id, quantity, updated_at) VALUES
(1, 1, 45, '2024-01-21 17:00:00'),
(2, 2, 30, '2024-01-21 17:00:00'),
(3, 3, 15, '2024-01-21 17:00:00'),
(4, 4, 20, '2024-01-21 17:00:00'),
(5, 5, 12, '2024-01-21 17:00:00'),
(6, 6, 8, '2024-01-21 17:00:00'),
(7, 7, 50, '2024-01-21 17:00:00'),
(8, 8, 80, '2024-01-21 17:00:00'),
(9, 9, 25, '2024-01-21 17:00:00'),
(10, 10, 60, '2024-01-21 17:00:00'),
(11, 11, 75, '2024-01-21 17:00:00'),
(12, 12, 120, '2024-01-21 17:00:00'),
(13, 13, 200, '2024-01-21 17:00:00'),
(14, 14, 18, '2024-01-21 17:00:00'),
(15, 15, 22, '2024-01-21 17:00:00'),
(16, 16, 10, '2024-01-21 17:00:00'),
(17, 17, 35, '2024-01-21 17:00:00'),
(18, 18, 4, '2024-01-21 17:00:00'),
(19, 19, 3, '2024-01-21 17:00:00'),
(20, 20, 2, '2024-01-21 17:00:00');

-- customer 18, 19, 20 không có đơn hàng
INSERT INTO customer (customer_id, full_name, email, phone, password_hash, created_at, status) VALUES
(1, 'Nguyễn Văn An', 'an.nguyen@gmail.com', '0901234567', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV1', '2024-01-05 08:30:00', 'active'),
(2, 'Trần Thị Bích', 'bich.tran@yahoo.com', '0912345678', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV2', '2024-01-06 09:15:00', 'active'),
(3, 'Lê Hoàng Cường', 'cuong.le@gmail.com', '0923456789', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV3', '2024-01-07 10:20:00', 'active'),
(4, 'Phạm Minh Dũng', 'dung.pham@outlook.com', '0934567890', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV4', '2024-01-08 11:00:00', 'active'),
(5, 'Hoàng Thị Em', 'em.hoang@gmail.com', '0945678901', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV5', '2024-01-09 14:10:00', 'active'),
(6, 'Vũ Đức Phúc', 'phuc.vu@gmail.com', '0956789012', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV6', '2024-01-10 15:40:00', 'active'),
(7, 'Đặng Thị Giang', 'giang.dang@gmail.com', '0967890123', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV7', '2024-01-11 08:50:00', 'active'),
(8, 'Bùi Quang Hải', 'hai.bui@gmail.com', '0978901234', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV8', '2024-01-12 16:30:00', 'active'),
(9, 'Đỗ Lan Hương', 'huong.do@hotmail.com', '0989012345', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9fV9', '2024-01-13 13:25:00', 'active'),
(10, 'Ngô Quốc Khánh', 'khanh.ngo@gmail.com', '0990123456', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f10', '2024-01-14 17:15:00', 'active'),
(11, 'Dương Thúy Linh', 'linh.duong@gmail.com', '0909876543', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f11', '2024-01-15 10:05:00', 'active'),
(12, 'Lý Minh Nam', 'nam.ly@gmail.com', '0918765432', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f12', '2024-01-16 11:45:00', 'active'),
(13, 'Mai Phương Oanh', 'oanh.mai@gmail.com', '0927654321', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f13', '2024-01-17 09:30:00', 'active'),
(14, 'Đoàn Quốc Quân', 'quan.doan@gmail.com', '0936543210', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f14', '2024-01-18 14:50:00', 'active'),
(15, 'Trịnh Thu Trang', 'trang.trinh@gmail.com', '0945432109', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f15', '2024-01-19 16:20:00', 'active'),
(16, 'Võ Tuấn Uy', 'uy.vo@gmail.com', '0954321098', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f16', '2024-01-20 18:00:00', 'active'),
(17, 'Phan Thanh Vân', 'van.phan@gmail.com', '0963210987', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f17', '2024-01-21 08:15:00', 'active'),
(18, 'Hồ Đăng Xuân', 'xuan.ho@gmail.com', '0972109876', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f18', '2024-01-22 09:00:00', 'active'),
(19, 'Chu Ngọc Yến', 'yen.chu@gmail.com', '0981098765', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f19', '2024-01-23 10:10:00', 'active'),
(20, 'Lâm Minh Trí', 'tri.lam@gmail.com', '0990987654', '$2b$12$eImiTXuWVxfM37uY4JANjOL1kU9f20', '2024-01-24 11:20:00', 'inactive');

-- KH 1 có 3 đơn, KH 2 và 3 mỗi người 2 đơn
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount, shipping_address) VALUES
(1, 1, '2024-02-01 10:00:00', 'delivered', 30880000.00, '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP.HCM'),
(2, 1, '2024-02-15 14:30:00', 'delivered', 5780000.00, '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP.HCM'),
(3, 2, '2024-02-10 11:15:00', 'delivered', 27500000.00, '456 Nguyễn Huệ, Quận 1, TP.HCM'),
(4, 3, '2024-02-12 16:45:00', 'delivered', 50140000.00, '789 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội'),
(5, 4, '2024-02-18 09:20:00', 'delivered', 38500000.00, '321 Cầu Giấy, Quận Cầu Giấy, Hà Nội'),
(6, 5, '2024-02-20 13:00:00', 'delivered', 7990000.00, '15 Lê Duẩn, Quận Hải Châu, TP. Đà Nẵng'),
(7, 6, '2024-02-22 15:30:00', 'delivered', 45000000.00, '88 Hùng Vương, TP. Huế, Thừa Thiên Huế'),
(8, 7, '2024-02-25 17:10:00', 'delivered', 5690000.00, '102 Nguyễn Văn Cừ, Quận Ninh Kiều, Cần Thơ'),
(9, 8, '2024-03-01 10:45:00', 'delivered', 8990000.00, '67 Quang Trung, TP. Nha Trang, Khánh Hòa'),
(10, 9, '2024-03-05 11:30:00', 'delivered', 5780000.00, '250 Bạch Đằng, Quận Bình Thạnh, TP.HCM'),
(11, 10, '2024-03-08 14:00:00', 'shipped', 20490000.00, '12 Thùy Vân, TP. Vũng Tàu, Bà Rịa - Vũng Tàu'),
(12, 11, '2024-03-10 09:15:00', 'shipped', 24990000.00, '45 Trần Phú, TP. Đà Lạt, Lâm Đồng'),
(13, 12, '2024-03-12 16:00:00', 'processing', 4290000.00, '78 Nguyễn Trãi, Quận Thanh Xuân, Hà Nội'),
(14, 13, '2024-03-15 10:20:00', 'processing', 6990000.00, '99 Lê Duẩn, TP. Vinh, Nghệ An'),
(15, 1, '2024-03-18 11:40:00', 'processing', 2290000.00, '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP.HCM'),
(16, 2, '2024-03-20 15:10:00', 'pending', 3490000.00, '456 Nguyễn Huệ, Quận 1, TP.HCM'),
(17, 3, '2024-03-22 16:30:00', 'pending', 5990000.00, '789 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội'),
(18, 5, '2024-03-23 09:50:00', 'pending', 1490000.00, '15 Lê Duẩn, Quận Hải Châu, TP. Đà Nẵng'),
(19, 14, '2024-03-24 14:15:00', 'cancelled', 4990000.00, '18 Nguyễn Chí Thanh, Quận Đống Đa, Hà Nội'),
(20, 15, '2024-03-25 17:00:00', 'pending', 21990000.00, '60 Hai Bà Trưng, Quận 3, TP.HCM');

INSERT INTO order_item (order_item_id, order_id, product_id, quantity, unit_price, subtotal) VALUES
-- Order 1: iPhone 15 Pro Max + Củ sạc Anker = 30,880,000
(1, 1, 1, 1, 29990000.00, 29990000.00),
(2, 1, 12, 1, 890000.00, 890000.00),
-- Order 2: Củ sạc Anker + 2 Cáp Baseus + 2 Chuột MX Master = 5,780,000
(3, 2, 12, 1, 890000.00, 890000.00),
(4, 2, 13, 2, 150000.00, 300000.00),
(5, 2, 11, 2, 2295000.00, 4590000.00),
-- Order 3: Samsung S24 Ultra = 27,500,000
(6, 3, 2, 1, 27500000.00, 27500000.00),
-- Order 4: MacBook Pro M3 Pro + Cáp Baseus = 50,140,000
(7, 4, 4, 1, 49990000.00, 49990000.00),
(8, 4, 13, 1, 150000.00, 150000.00),
(9, 5, 5, 1, 38500000.00, 38500000.00),
(10, 6, 7, 1, 7990000.00, 7990000.00),
(11, 7, 6, 1, 45000000.00, 45000000.00),
(12, 8, 8, 1, 5690000.00, 5690000.00),
(13, 9, 9, 1, 8990000.00, 8990000.00),
(14, 10, 10, 1, 3490000.00, 3490000.00),
(15, 10, 11, 1, 2290000.00, 2290000.00),
(16, 11, 14, 1, 20490000.00, 20490000.00),
(17, 12, 16, 1, 24990000.00, 24990000.00),
(18, 13, 17, 1, 4290000.00, 4290000.00),
(19, 14, 15, 1, 6990000.00, 6990000.00),
(20, 15, 11, 1, 2290000.00, 2290000.00),
(21, 16, 10, 1, 3490000.00, 3490000.00),
(22, 17, 20, 1, 5990000.00, 5990000.00),
(23, 18, 19, 1, 1490000.00, 1490000.00),
(24, 19, 18, 1, 4990000.00, 4990000.00),
(25, 20, 3, 1, 21990000.00, 21990000.00);

INSERT INTO payment (payment_id, order_id, payment_method, payment_status, amount, paid_at, transaction_code) VALUES
(1, 1, 'Credit Card', 'completed', 30880000.00, '2024-02-01 10:05:00', 'TXN-20240201-0001'),
(2, 2, 'E-Wallet', 'completed', 5780000.00, '2024-02-15 14:32:00', 'TXN-20240215-0002'),
(3, 3, 'Bank Transfer', 'completed', 27500000.00, '2024-02-10 11:20:00', 'TXN-20240210-0003'),
(4, 4, 'Credit Card', 'completed', 50140000.00, '2024-02-12 16:50:00', 'TXN-20240212-0004'),
(5, 5, 'Bank Transfer', 'completed', 38500000.00, '2024-02-18 09:25:00', 'TXN-20240218-0005'),
(6, 6, 'E-Wallet', 'completed', 7990000.00, '2024-02-20 13:05:00', 'TXN-20240220-0006'),
(7, 7, 'Credit Card', 'completed', 45000000.00, '2024-02-22 15:35:00', 'TXN-20240222-0007'),
(8, 8, 'COD', 'completed', 5690000.00, '2024-02-27 10:00:00', 'TXN-20240227-0008'),
(9, 9, 'Credit Card', 'completed', 8990000.00, '2024-03-01 10:50:00', 'TXN-20240301-0009'),
(10, 10, 'E-Wallet', 'completed', 5780000.00, '2024-03-05 11:35:00', 'TXN-20240305-0010'),
(11, 11, 'Bank Transfer', 'completed', 20490000.00, '2024-03-08 14:05:00', 'TXN-20240308-0011'),
(12, 12, 'Credit Card', 'completed', 24990000.00, '2024-03-10 09:20:00', 'TXN-20240310-0012'),
(13, 13, 'COD', 'pending', 4290000.00, NULL, 'TXN-20240312-0013'),
(14, 14, 'E-Wallet', 'completed', 6990000.00, '2024-03-15 10:25:00', 'TXN-20240315-0014'),
(15, 15, 'Credit Card', 'completed', 2290000.00, '2024-03-18 11:45:00', 'TXN-20240318-0015'),
(16, 16, 'Bank Transfer', 'pending', 3490000.00, NULL, 'TXN-20240320-0016'),
(17, 17, 'Credit Card', 'pending', 5990000.00, NULL, 'TXN-20240322-0017'),
(18, 18, 'COD', 'pending', 1490000.00, NULL, 'TXN-20240323-0018'),
(19, 19, 'E-Wallet', 'refunded', 4990000.00, '2024-03-24 14:20:00', 'TXN-20240324-0019'),
(20, 20, 'Bank Transfer', 'pending', 21990000.00, NULL, 'TXN-20240325-0020');
