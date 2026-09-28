# Hệ Thống Quản Lý Bán Hàng Online (Online Shopping Database)

> **Dự án CSDL môn học:** Database Design & SQL  
> **Hệ quản trị CSDL:** MySQL 8.0+ (InnoDB Engine)  
> **Chuẩn hóa:** Đạt chuẩn dạng 3 (3NF)  

---

## 1. Giới thiệu (Introduction)
Dự án thiết kế và triển khai cơ sở dữ liệu quan hệ cho một hệ thống bán hàng trực tuyến (E-commerce / Online Shopping Management System). CSDL cho phép quản lý thông tin khách hàng, danh mục sản phẩm, sản phẩm kinh doanh, kho hàng tồn thực tế, đơn đặt hàng, chi tiết sản phẩm trong đơn, và giao dịch thanh toán.

Hệ thống được thiết kế tối ưu trên nền tảng **MySQL 8.0+ (InnoDB Engine)**, đảm bảo tính toàn vẹn ACID thông qua các ràng buộc khóa chính tự tăng (`AUTO_INCREMENT`), khóa ngoại (`FOREIGN KEY`), kiểm tra miền giá trị (`CHECK constraints`), chỉ mục (`B-Tree Indexes`), thủ tục lưu trữ (`Stored Procedures / Functions`), và các cơ chế tự động hóa qua `Triggers`.

---

## 2. Công nghệ sử dụng (Technologies)
- **Hệ quản trị CSDL chính:** MySQL Server (v8.0+) với Storage Engine InnoDB
- **Bảng mã & Đối chiếu:** `utf8mb4` và `utf8mb4_unicode_ci` (hỗ trợ tiếng Việt và ký tự đặc biệt)
- **Công cụ truy vấn & quản trị:** MySQL Workbench / DBeaver / phpMyAdmin / mysql client
- **Công cụ thiết kế sơ đồ:** dbdiagram.io (DBML) & Matplotlib Python
- **Quản lý mã nguồn:** Git & GitHub

---

## 3. Cấu trúc cơ sở dữ liệu (Database Structure)
Hệ thống gồm **7 bảng thực thể cốt lõi** đạt chuẩn 3NF:

| Tên bảng | Vai trò nghiệp vụ | Quan hệ chính |
| :--- | :--- | :--- |
| `customer` | Quản lý tài khoản khách hàng, thông tin liên hệ và trạng thái | `1 : N` với `orders` |
| `category` | Phân loại danh mục hàng hóa | `1 : N` với `product` |
| `product` | Thông tin sản phẩm, đơn giá niêm yết, tồn kho hiển thị | `N : 1` với `category`, `1 : 1` với `inventory`, `1 : N` với `order_item` |
| `inventory` | Quản lý số lượng tồn kho thực tế độc lập | `1 : 1` với `product` |
| `orders` | Quản lý đơn hàng, địa chỉ giao hàng, tổng tiền và trạng thái | `N : 1` với `customer`, `1 : N` với `order_item`, `1 : 1` với `payment` |
| `order_item` | Chi tiết từng sản phẩm trong đơn (giải quyết quan hệ nhiều - nhiều) | `N : 1` với `orders`, `N : 1` với `product` |
| `payment` | Quản lý phương thức và tình trạng thanh toán đơn hàng | `1 : 1` với `orders` |

---

## 4. Sơ đồ thực thể quan hệ (ERD)
Sơ đồ quan hệ ERD chi tiết được lưu trữ tại:
- **Ảnh độ phân giải cao:** [erd/online_shopping_erd.png](file:///erd/online_shopping_erd.png)
- **Tệp vector PDF:** [erd/online_shopping_erd.pdf](file:///erd/online_shopping_erd.pdf)
- **Mã nguồn DBML (sử dụng trên dbdiagram.io):** [erd/schema.dbml](file:///erd/schema.dbml)

```
CUSTOMER (1) <==== N ====> (N) ORDERS (1) <==== 1 ====> (1) PAYMENT
                                  |
                                  | (1)
                                  v
                             ORDER_ITEM
                                  ^
                                  | (N)
CATEGORY (1) <==== N ====> (N) PRODUCT (1) <==== 1 ====> (1) INVENTORY
```

---

## 5. Hướng dẫn cài đặt & Thực thi (Installation)
Thực thi các tệp SQL theo đúng thứ tự trong thư mục `sql/` bằng MySQL Workbench, DBeaver hoặc dòng lệnh `mysql`:

```bash
# Cách 1: Chạy bằng terminal mysql
mysql -u root -p < sql/01_create_database.sql
mysql -u root -p online_shopping_db < sql/02_create_tables.sql
mysql -u root -p online_shopping_db < sql/03_insert_data.sql
mysql -u root -p online_shopping_db < sql/04_constraints.sql
mysql -u root -p online_shopping_db < sql/05_indexes.sql
mysql -u root -p online_shopping_db < sql/06_views.sql
mysql -u root -p online_shopping_db < sql/07_functions_procedures.sql
mysql -u root -p online_shopping_db < sql/08_triggers.sql
mysql -u root -p online_shopping_db < sql/09_bonus.sql
```

Hoặc trong cửa sổ dòng lệnh MySQL:
```sql
SOURCE sql/01_create_database.sql;
SOURCE sql/02_create_tables.sql;
SOURCE sql/03_insert_data.sql;
SOURCE sql/04_constraints.sql;
SOURCE sql/05_indexes.sql;
SOURCE sql/06_views.sql;
SOURCE sql/07_functions_procedures.sql;
SOURCE sql/08_triggers.sql;
SOURCE sql/09_bonus.sql;
```

---

## 6. Các câu truy vấn mẫu tiêu biểu (Sample Queries)
Toàn bộ **15 câu truy vấn** từ cơ bản đến phức tạp được tổng hợp tại [queries/queries.sql](file:///queries/queries.sql):

- **Q01 (Select + Limit):** Tìm 10 sản phẩm đắt nhất đang kinh doanh.
- **Q02 (Inner Join):** Hiển thị danh sách sản phẩm cùng tên danh mục.
- **Q03 (Left Join):** Thống kê số đơn của mọi khách hàng (kể cả khách chưa có đơn).
- **Q04 (Group By + Count):** Đếm số lượng chủng loại sản phẩm và tổng tồn kho theo danh mục.
- **Q05 (Group By + Sum):** Tính tổng doanh thu tích lũy thu được theo từng khách hàng.
- **Q06 (Aggregates):** Thống kê giá trung bình, nhỏ nhất và lớn nhất của các sản phẩm.
- **Q07 (Subquery):** Tìm các sản phẩm có giá vượt giá trung bình toàn hệ thống.
- **Q08 (Window Function):** Xếp hạng sản phẩm bán chạy theo doanh thu (`DENSE_RANK() OVER (...)` trên MySQL 8.0+).
- **Q09 (Case When):** Phân hạng khách hàng thành VIP, Regular, Normal và New Lead.
- **Q10 (Non-existent Data):** Tìm khách hàng chưa phát sinh đơn (`LEFT JOIN ... IS NULL` & `NOT EXISTS`).
- **Q11 (Duplicate Data):** Kiểm tra trùng lặp email với `HAVING COUNT(*) > 1`.
- **Q12 (Pagination):** Phân trang dữ liệu sản phẩm hiển thị trên giao diện web (`LIMIT` & `OFFSET`).
- **Q13 (CTE):** Dùng `WITH ... AS (...)` tính toán và lọc nhóm khách hàng có giá trị cao.
- **Q14 (Nested Query):** Tìm sản phẩm có doanh thu vượt mức trung bình của nhóm danh mục đó.
- **Q15 (Composite Query):** Báo cáo tình hình kinh doanh tổng thể: đơn hàng, doanh thu thực và AOV theo tháng dùng `DATE_FORMAT`.

---

## 7. Các tính năng cốt lõi (Features)
- **Toàn vẹn dữ liệu (Constraints):** PK tự tăng `INT AUTO_INCREMENT`, FK (`CASCADE`, `RESTRICT`) trên Engine InnoDB, UNIQUE (`email`, `phone`, `category_name`, `product_id` tồn kho), CHECK (`price >= 0`, `quantity > 0`, `status IN (...)`).
- **Chỉ mục tăng tốc (B-Tree Indexes):**
  - `idx_orders_customer_id`: Tối ưu tìm kiếm lịch sử đơn hàng của khách.
  - `idx_product_category_id`: Tối ưu duyệt danh mục sản phẩm.
  - `idx_orders_order_date`: Tối ưu lọc đơn theo khoảng thời gian.
  - `idx_product_price`: Tối ưu sắp xếp theo giá.
- **Lớp hiển thị tổng hợp (Views):**
  - `v_order_summary`: Tổng hợp nhanh đơn hàng kèm thông tin khách hàng và thanh toán.
  - `v_customer_spending_summary`: Thống kê tổng chi tiêu và phân hạng khách hàng.
  - `v_product_inventory_status`: Báo cáo tồn kho và cảnh báo cần nhập thêm hàng.
- **Thủ tục & Hàm nghiệp vụ (Procedures & Functions):**
  - `sp_create_order`: Tạo đơn hàng an toàn, kiểm tra tồn kho, trừ tồn kho và khởi tạo thanh toán với Transaction & `SIGNAL SQLSTATE`.
  - `sp_cancel_order`: Hủy đơn hàng và dùng con trỏ Cursor tự động hoàn trả số lượng tồn kho.
  - `fn_get_customer_total_spent`: Function tính tổng chi tiêu thực tế của khách hàng.
- **Triggers tự động hóa:**
  - `trg_calc_order_item_subtotal_insert` & `update`: Tự động tính `subtotal = quantity * unit_price`.
  - `trg_update_order_total_insert`, `update`, `delete`: Tự động cập nhật lại tổng tiền đơn hàng khi giỏ hàng thay đổi.
  - `updated_at`: Tự động gán thời gian qua `ON UPDATE CURRENT_TIMESTAMP`.

---

## 8. Tính năng mở rộng nâng cao (Bonus)
1. **Tối ưu hóa với EXPLAIN ANALYZE:** Phân tích cây kế hoạch thực thi Execution Plan trên MySQL 8.0+ so sánh trước và sau khi đánh index (chuyển từ `Table scan` sang `Index lookup`, giảm đáng kể thời gian truy vấn).
2. **Transaction Management:** Quản lý giao dịch ACID khi đặt hàng nhiều bước (`START TRANSACTION; ... COMMIT; / ROLLBACK;`).
3. **Audit Logging:** Bảng `audit_log` với kiểu `JSON` và trigger ghi vết biến động dữ liệu dùng hàm `JSON_OBJECT()`.
4. **Soft Delete (Xóa mềm):** Quản lý trạng thái xóa thông qua cờ `deleted_at DATETIME NULL` và thủ tục `sp_soft_delete_customer`, bảo toàn toàn vẹn dữ liệu lịch sử.

---

## 9. Cấu trúc thư mục dự án (Repository Structure)
```
onlshoopindtb/
│
├── README.md                           # Tài liệu tổng quan dự án
├── online_shopping_database_plan.txt   # Bản kế hoạch thiết kế ban đầu
│
├── erd/                                # Sơ đồ thực thể quan hệ
│   ├── online_shopping_erd.png         # Ảnh sơ đồ ERD độ phân giải cao
│   ├── online_shopping_erd.pdf         # Tệp PDF vector sơ đồ ERD
│   ├── schema.dbml                     # Mã nguồn thiết kế trên dbdiagram.io (MySQL)
│   └── generate_erd.py                 # Script tự động sinh ảnh ERD
│
├── sql/                                # Tập lệnh khởi tạo CSDL MySQL 8.0+
│   ├── 01_create_database.sql          # Khởi tạo CSDL utf8mb4
│   ├── 02_create_tables.sql            # Tạo 7 bảng thực thể chuẩn 3NF (InnoDB)
│   ├── 03_insert_data.sql              # Nạp dữ liệu mẫu chuẩn (20 records/bảng)
│   ├── 04_constraints.sql              # Ràng buộc toàn vẹn PK, FK, UQ, CHECK
│   ├── 05_indexes.sql                  # Tạo các chỉ mục B-Tree tối ưu hóa
│   ├── 06_views.sql                    # Tạo các View tổng hợp số liệu
│   ├── 07_functions_procedures.sql     # Stored Procedures & Functions nghiệp vụ
│   ├── 08_triggers.sql                 # Triggers tự động hóa
│   └── 09_bonus.sql                    # EXPLAIN ANALYZE, Transaction, Audit Log, Soft Delete
│
├── queries/                            # Truy vấn phân tích dữ liệu
│   ├── queries.sql                     # Trọn bộ 15 câu query Q01 - Q15 (cú pháp MySQL)
│   └── query_results/                  # Thư mục lưu ảnh chụp màn hình kết quả
│       └── README.md
│
├── docs/                               # Tài liệu và báo cáo
│   ├── report.md                       # Nội dung chi tiết báo cáo 5-10 trang (MySQL)
│   ├── report.pdf                      # Báo cáo học viên định dạng PDF hoàn chỉnh
│   └── generate_report_pdf.py          # Script sinh tệp PDF báo cáo
│
└── demo/                               # Thuyết minh và video demo
    └── demo_link.txt                   # Đường dẫn video demo & kịch bản thuyết minh (MySQL)
```

---

## 10. Thông tin tác giả (Author)
- **Họ và tên:** [Điền Họ và Tên của bạn]
- **Mã số học viên:** [Điền Mã số học viên của bạn]
- **Lớp đào tạo:** [Điền Tên Lớp của bạn]
- **Khóa học:** Database Design & Development with MySQL
