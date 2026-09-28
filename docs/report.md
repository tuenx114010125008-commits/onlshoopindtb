# BÁO CÁO BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
# ĐỀ TÀI: HỆ THỐNG QUẢN LÝ BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)

---

## THÔNG TIN CHUNG
- **Học viên:** [Điền Họ và Tên]
- **Mã số học viên:** [Điền Mã số học viên]
- **Lớp:** [Điền Tên Lớp]
- **Giảng viên hướng dẫn:** [Điền Tên Giảng viên]
- **Hệ quản trị CSDL:** MySQL 8.0+ (InnoDB Engine)
- **Repository GitHub:** [Điền URL GitHub Repository]
- **Video Demo:** [Điền URL Video Demo]

---

## 1. MỤC TIÊU VÀ PHẠM VI DỰ ÁN

### 1.1. Mục tiêu
- Xây dựng một cơ sở dữ liệu quan hệ hoàn chỉnh, chuẩn hóa đến dạng chuẩn 3 (3NF) phục vụ cho nền tảng thương mại điện tử / bán hàng trực tuyến.
- Quản lý toàn diện các thực thể nghiệp vụ: khách hàng, danh mục sản phẩm, sản phẩm kinh doanh, tồn kho độc lập, đơn đặt hàng, chi tiết các mặt hàng trong đơn, và giao dịch thanh toán.
- Thiết kế hệ thống ràng buộc toàn vẹn dữ liệu chặt chẽ (PK, FK, UNIQUE, CHECK, NOT NULL, DEFAULT).
- Xây dựng tập hợp 15 câu truy vấn SQL từ cơ bản đến phức tạp (JOIN, Aggregations, Subquery, Window Function, CTE, Case When).
- Cài đặt các cơ chế tối ưu hóa và nâng cao: Indexing, View, Stored Procedure/Function, Trigger, Transaction, Audit Log và Soft Delete trên hệ quản trị CSDL MySQL 8.0+.

### 1.2. Phạm vi hệ thống
Hệ thống giải quyết các bài toán nghiệp vụ thương mại điện tử cốt lõi:
1. **Khách hàng (Customer):** Đăng ký tài khoản, cập nhật thông tin cá nhân, theo dõi lịch sử mua sắm.
2. **Danh mục (Category):** Tổ chức, phân nhóm sản phẩm theo nhiều cấp độ hàng hóa.
3. **Sản phẩm (Product):** Quản lý tên sản phẩm, giá bán niêm yết, tình trạng kinh doanh, ngày tạo và cập nhật.
4. **Tồn kho (Inventory):** Quản lý số lượng hàng thực tế trong kho, cảnh báo hết hàng hoặc tồn kho thấp (tách rời quan hệ 1:1 với Product nhằm tăng khả năng mở rộng đa kho trong tương lai).
5. **Đơn hàng (Orders):** Tiếp nhận đơn từ khách, theo dõi vòng đời đơn hàng (`pending` -> `processing` -> `shipped` -> `delivered` -> `cancelled`).
6. **Chi tiết đơn hàng (Order_Item):** Lưu thông tin các mặt hàng thuộc đơn hàng kèm số lượng mua và đơn giá chốt tại thời điểm mua (bảng trung gian giải quyết quan hệ N:N).
7. **Thanh toán (Payment):** Ghi nhận phương thức thanh toán (`Credit Card`, `Bank Transfer`, `COD`, `E-Wallet`), mã giao dịch và trạng thái thanh toán.

---

## 2. PHÂN TÍCH YÊU CẦU & THỰC THỂ DỮ LIỆU

| Tên Bảng | Vai Trò & Mục Đích Nghiệp Vụ | Các Thuộc Tính Chính | Quan Hệ |
| :--- | :--- | :--- | :--- |
| **customer** | Quản lý tài khoản khách hàng | `customer_id` (PK, AUTO_INCREMENT), `full_name`, `email` (UQ), `phone` (UQ), `password_hash`, `status`, `deleted_at` | 1 : N với `orders` |
| **category** | Phân loại sản phẩm | `category_id` (PK, AUTO_INCREMENT), `category_name` (UQ), `description` | 1 : N với `product` |
| **product** | Thông tin sản phẩm bày bán | `product_id` (PK, AUTO_INCREMENT), `category_id` (FK), `product_name`, `price`, `stock_quantity`, `status` | N : 1 với `category`, 1 : 1 với `inventory`, 1 : N với `order_item` |
| **inventory** | Quản lý kho thực tế | `inventory_id` (PK, AUTO_INCREMENT), `product_id` (FK, UQ), `quantity`, `updated_at` | 1 : 1 với `product` |
| **orders** | Quản lý đơn hàng | `order_id` (PK, AUTO_INCREMENT), `customer_id` (FK), `order_date`, `status`, `total_amount`, `shipping_address` | N : 1 với `customer`, 1 : N với `order_item`, 1 : 1 với `payment` |
| **order_item** | Chi tiết giỏ hàng/đơn hàng | `order_item_id` (PK, AUTO_INCREMENT), `order_id` (FK), `product_id` (FK), `quantity`, `unit_price`, `subtotal` | N : 1 với `orders`, N : 1 với `product` |
| **payment** | Giao dịch thanh toán | `payment_id` (PK, AUTO_INCREMENT), `order_id` (FK, UQ), `payment_method`, `payment_status`, `amount`, `transaction_code` (UQ) | 1 : 1 với `orders` |

---

## 3. THIẾT KẾ ERD (ENTITY RELATIONSHIP DIAGRAM)

### 3.1. Sơ đồ thực thể quan hệ
*(Sơ đồ chi tiết được lưu trữ dưới định dạng ảnh nét cao tại `erd/online_shopping_erd.png` và file vector `erd/online_shopping_erd.pdf`)*

```
[CUSTOMER] (1) ------- (N) [ORDERS] (1) ------- (1) [PAYMENT]
                             |
                             | (1)
                             |
                            (N)
                       [ORDER_ITEM]
                            (N)
                             |
                             | (1)
[CATEGORY] (1) ------- (N) [PRODUCT] (1) ------- (1) [INVENTORY]
```

### 3.2. Phân tích các mối quan hệ:
1. **Category (1) - Product (N):** Một danh mục chứa nhiều sản phẩm; mỗi sản phẩm bắt buộc trực thuộc một danh mục cụ thể.
2. **Product (1) - Inventory (1):** Mỗi sản phẩm có đúng một bản ghi theo dõi tồn kho tương ứng (ràng buộc `UNIQUE(product_id)` trên bảng `inventory`).
3. **Customer (1) - Orders (N):** Một khách hàng có thể đặt nhiều đơn hàng trong suốt vòng đời; mỗi đơn hàng chỉ thuộc về một khách hàng duy nhất.
4. **Orders (N) - Product (N) thông qua Order_Item:** Một đơn hàng có thể chứa nhiều sản phẩm, và một sản phẩm có thể xuất hiện trong nhiều đơn hàng khác nhau. Bảng `order_item` đóng vai trò là bảng kết hợp (junction table), bổ sung các thuộc tính lịch sử như `unit_price` và `quantity`.
5. **Orders (1) - Payment (1):** Mỗi đơn hàng được gắn kết với một giao dịch thanh toán duy nhất (`UNIQUE(order_id)` trên bảng `payment`).

---

## 4. QUÁ TRÌNH CHUẨN HÓA DỮ LIỆU (NORMALIZATION)

### 4.1. Dạng chuẩn 1 (First Normal Form - 1NF)
- **Định nghĩa:** Mỗi trường trong bảng phải chứa giá trị nguyên tử (atomic), không chứa tập hợp giá trị hoặc danh sách phân cách dấu phẩy.
- **Áp dụng:** 
  - Đơn hàng không lưu chuỗi `"iPhone 15, Sạc Anker, Ốp lưng"` vào một cột của bảng `orders`.
  - Tách rời các mặt hàng thành từng dòng độc lập trong bảng `order_item`.
  - Mỗi ô dữ liệu đều là giá trị đơn nguyên.

### 4.2. Dạng chuẩn 2 (Second Normal Form - 2NF)
- **Định nghĩa:** Đã đạt 1NF và mọi thuộc tính không khóa phải phụ thuộc hoàn toàn vào toàn bộ khóa chính (Full Functional Dependency), không phụ thuộc vào một phần khóa chính nếu khóa là khóa ghép.
- **Áp dụng:**
  - Trong bảng `order_item`, sử dụng khóa thay thế `order_item_id` (Surrogate Key) kết hợp ràng buộc `UNIQUE(order_id, product_id)`.
  - Không lưu tên sản phẩm (`product_name`) hay mô tả sản phẩm trong `order_item` vì chúng phụ thuộc vào `product_id`, không phụ thuộc vào `order_id`. Khi cần tên sản phẩm, thực hiện JOIN sang bảng `product`.
  - Không lưu họ tên hay số điện thoại của khách hàng trong bảng `orders` mà lưu tại bảng `customer`.

### 4.3. Dạng chuẩn 3 (Third Normal Form - 3NF)
- **Định nghĩa:** Đã đạt 2NF và không có thuộc tính không khóa nào phụ thuộc bắc cầu (Transitive Dependency) vào khóa chính: `X -> Y -> Z`.
- **Áp dụng:**
  - Không lưu tên danh mục (`category_name`) trong bảng `product` vì `product_id -> category_id -> category_name`. Tên danh mục được tách hoàn toàn sang bảng `category`.
  - Không lưu thông tin thanh toán (`payment_method`, `transaction_code`) trong bảng `orders` mà quản lý độc lập tại bảng `payment`.

---

## 5. CÀI ĐẶT DATABASE & RÀNG BUỘC (CONSTRAINTS)

### 5.1. Ràng buộc toàn vẹn trên MySQL
- **PRIMARY KEY:** Đặt trên toàn bộ 7 bảng với kiểu dữ liệu `INT AUTO_INCREMENT`.
- **FOREIGN KEY:** Thiết lập trên Engine InnoDB có cơ chế tham chiếu rõ ràng (`ON UPDATE CASCADE`, `ON DELETE RESTRICT` hoặc `ON DELETE CASCADE` phù hợp với vòng đời dữ liệu).
- **UNIQUE:** `customer.email`, `customer.phone`, `category.category_name`, `inventory.product_id`, `payment.order_id`, `payment.transaction_code`, `order_item(order_id, product_id)`.
- **CHECK:** MySQL 8.0+ hỗ trợ và thực thi nghiêm ngặt: đảm bảo `price >= 0`, `stock_quantity >= 0`, `quantity > 0`, `subtotal >= 0`, `total_amount >= 0`, trạng thái đơn hàng và trạng thái thanh toán chỉ nằm trong tập giá trị hợp lệ.
- **DEFAULT:** Gán mặc định thời gian `CURRENT_TIMESTAMP`, trạng thái ban đầu `pending`, `active`.

### 5.2. Chỉ mục (Indexes)
- `idx_orders_customer_id`: Tối ưu hóa truy vấn xem lịch sử đơn hàng của khách và phép JOIN.
- `idx_product_category_id`: Tối ưu hóa duyệt danh sách sản phẩm theo danh mục.
- Các index mở rộng: `idx_orders_order_date`, `idx_product_price`, `idx_orders_status`, `idx_order_item_product_id`.

### 5.3. View
- `v_order_summary`: Tổng hợp nhanh toàn bộ đơn hàng kèm thông tin khách hàng, số điện thoại và trạng thái thanh toán.
- `v_customer_spending_summary`: Thống kê xếp hạng chi tiêu và phân hạng khách hàng.
- `v_product_inventory_status`: Báo cáo tình hình tồn kho và cảnh báo nhập hàng.

### 5.4. Stored Procedure & Function
- `sp_create_order`: Thủ tục thực hiện quy trình tạo đơn hàng an toàn, kiểm tra tồn kho, cập nhật trừ kho và khởi tạo giao dịch thanh toán trong một transaction với cơ chế `SIGNAL SQLSTATE '45000'`.
- `sp_cancel_order`: Thủ tục hủy đơn hàng, dùng Cursor duyệt và tự động hoàn lại số lượng tồn kho cho các sản phẩm trong đơn, cập nhật trạng thái thanh toán thành `refunded`.
- `fn_get_customer_total_spent`: Function tính tổng chi tiêu thực tế của khách hàng.

### 5.5. Triggers
- `trg_calc_order_item_subtotal_insert` & `update`: Tự động tính `subtotal = quantity * unit_price` trước khi lưu vào `order_item`.
- `trg_update_order_total_insert`, `update`, `delete`: Tự động tính toán lại `orders.total_amount` khi thêm/sửa/xóa sản phẩm trong `order_item`.
- `updated_at`: Sử dụng `DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`.

---

## 6. DANH SÁCH 15 CÂU TRUY VẤN SQL ĐIỂN HÌNH

Tất cả câu truy vấn được lưu đầy đủ trong file [queries/queries.sql](file:///queries/queries.sql):
- **Q01 (Basic Select):** Lọc 10 sản phẩm có giá bán cao nhất đang kinh doanh.
- **Q02 (Inner Join):** Lấy danh sách sản phẩm kèm tên danh mục tương ứng.
- **Q03 (Left Join):** Hiển thị toàn bộ khách hàng và số đơn đã đặt (kể cả khách chưa từng mua hàng).
- **Q04 (Group By + Count):** Đếm số lượng sản phẩm và tổng tồn kho theo từng danh mục.
- **Q05 (Group By + Sum):** Tính tổng doanh thu tích lũy theo từng khách hàng.
- **Q06 (Aggregates):** Thống kê giá bán trung bình, giá rẻ nhất và đắt nhất trong hệ thống.
- **Q07 (Subquery):** Tìm các sản phẩm có giá bán vượt qua mức giá trung bình của toàn bộ cửa hàng.
- **Q08 (Window Function):** Sử dụng `DENSE_RANK() OVER (...)` xếp hạng sản phẩm theo doanh số trên MySQL 8.0+.
- **Q09 (Case When):** Phân hạng khách hàng thành VIP, Regular, Normal và New Lead.
- **Q10 (Non-existent Data):** Tìm khách hàng chưa phát sinh đơn hàng bằng `LEFT JOIN ... IS NULL` và `NOT EXISTS`.
- **Q11 (Duplicate Data):** Kiểm tra các email bị trùng lặp bằng `GROUP BY + HAVING COUNT(*) > 1`.
- **Q12 (Pagination):** Phân trang dữ liệu sản phẩm hiển thị với `LIMIT` và `OFFSET`.
- **Q13 (CTE):** Dùng `WITH ... AS (...)` tính toán và lọc các khách hàng đem lại doanh thu cao.
- **Q14 (Nested Query):** Tìm các sản phẩm có doanh thu cao hơn doanh thu trung bình của các sản phẩm trong cùng danh mục.
- **Q15 (Composite Query):** Lập bảng báo cáo tài chính doanh thu, số đơn đã thanh toán và AOV theo từng tháng bằng `DATE_FORMAT`.

---

## 7. TỐI ƯU HÓA TRUY VẤN VỚI EXPLAIN ANALYZE

### 7.1. Truy vấn kiểm thử trên MySQL 8.0+
```sql
EXPLAIN ANALYZE
SELECT o.order_id, c.full_name, p.product_name, oi.subtotal
FROM orders o
INNER JOIN customer c ON o.customer_id = c.customer_id
INNER JOIN order_item oi ON o.order_id = oi.order_id
INNER JOIN product p ON oi.product_id = p.product_id
WHERE o.customer_id = 1;
```

### 7.2. So sánh kết quả
- **Khi chưa có Index trên `orders(customer_id)`:**
  - Kế hoạch thực thi: MySQL thực hiện `Table scan on orders` (quét tuần tự toàn bộ bảng).
  - Chi phí (Cost): Tăng tuyến tính theo số lượng bản ghi đơn hàng trong hệ thống.
- **Khi đã đánh Index `idx_orders_customer_id`:**
  - Kế hoạch thực thi: Optimizer chuyển sang `Index lookup on orders using idx_orders_customer_id`.
  - Bộ lập lịch chỉ truy xuất trực tiếp các con trỏ dòng thỏa mãn điều kiện `customer_id = 1`, giảm thiểu chi phí đọc đĩa cứng và tăng tốc độ phản hồi đáng kể.

---

## 8. CÁC TÍNH NĂNG MỞ RỘNG (BONUS FEATURES)

1. **Transaction Management:** Quản lý giao dịch ACID (`START TRANSACTION; ... COMMIT; / ROLLBACK;`) khi khách hàng tạo đơn hàng, đảm bảo tính nguyên tử hoàn hảo.
2. **Audit Logging:** Xây dựng bảng `audit_log` với kiểu `JSON` và trigger tự động lưu vết các hành vi biến động dữ liệu dùng `JSON_OBJECT()`.
3. **Soft Delete (Xóa mềm):** Bổ sung cột `deleted_at DATETIME NULL` và thủ tục `sp_soft_delete_customer`, bảo toàn toàn vẹn dữ liệu lịch sử đơn hàng.

---

## 9. KHÓ KHĂN GẶP PHẢI VÀ GIẢI PHÁP

1. **Khó khăn về thứ tự thực thi khóa ngoại khi nạp dữ liệu:**
   - *Giải pháp:* Sử dụng `SET FOREIGN_KEY_CHECKS = 0;` trước khi truncate/insert dữ liệu mẫu và bật lại `SET FOREIGN_KEY_CHECKS = 1;`.
2. **Xử lý bất đồng bộ giữa số lượng tồn kho và đơn hàng:**
   - *Giải pháp:* Viết Stored Procedure `sp_create_order` và `sp_cancel_order` sử dụng Transaction và Cursor đảm bảo số lượng tồn kho luôn được hoàn trả đúng khi hủy đơn.

---

## 10. BÀI HỌC KINH NGHIỆM (LESSONS LEARNED)
- Nắm vững quy trình thiết kế CSDL quan hệ trên hệ quản trị CSDL MySQL (InnoDB Engine).
- Hiểu sâu về cách thức hoạt động của các loại Constraint và cơ chế Indexing trong MySQL.
- Rèn luyện kỹ năng viết Stored Procedure, Triggers và các câu lệnh SQL nâng cao (CTE, Window Functions) trên MySQL 8.0+.
- Ứng dụng quy trình quản lý mã nguồn chuẩn mực trên GitHub.
