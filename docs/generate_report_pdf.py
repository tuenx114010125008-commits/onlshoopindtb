import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.patches as patches

pdf_path = "docs/report.pdf"

with PdfPages(pdf_path) as pdf:
    # ---------------- PAGE 1: COVER & OVERVIEW ----------------
    fig, ax = plt.subplots(figsize=(8.27, 11.69), dpi=150) # A4 format
    ax.axis('off')
    fig.patch.set_facecolor('#FFFFFF')

    # Border frame
    frame = patches.Rectangle((0.04, 0.04), 0.92, 0.92, fill=False, edgecolor='#1E3A8A', linewidth=2.5, transform=ax.transAxes)
    ax.add_patch(frame)
    inner_frame = patches.Rectangle((0.048, 0.048), 0.904, 0.904, fill=False, edgecolor='#94A3B8', linewidth=0.8, transform=ax.transAxes)
    ax.add_patch(inner_frame)

    # University / Course Header
    ax.text(0.5, 0.91, "BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL", fontsize=15, fontweight='bold', color='#1E3A8A', ha='center', va='center', transform=ax.transAxes)
    ax.text(0.5, 0.88, "HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU MYSQL (INNODB)", fontsize=11, color='#475569', ha='center', va='center', transform=ax.transAxes)
    
    # Title Box
    title_box = patches.FancyBboxPatch((0.1, 0.70), 0.8, 0.13, boxstyle="round,pad=0.02", facecolor='#F1F5F9', edgecolor='#CBD5E1', transform=ax.transAxes)
    ax.add_patch(title_box)
    ax.text(0.5, 0.78, "ĐỀ TÀI:", fontsize=12, fontweight='bold', color='#64748B', ha='center', transform=ax.transAxes)
    ax.text(0.5, 0.73, "HỆ THỐNG QUẢN LÝ BÁN HÀNG ONLINE", fontsize=16, fontweight='bold', color='#0F172A', ha='center', transform=ax.transAxes)

    # Student Info Box
    info_box = patches.FancyBboxPatch((0.15, 0.44), 0.7, 0.20, boxstyle="round,pad=0.02", facecolor='#FFFFFF', edgecolor='#E2E8F0', transform=ax.transAxes)
    ax.add_patch(info_box)
    ax.text(0.20, 0.60, "Họ và tên học viên:", fontsize=11, fontweight='bold', color='#334155', transform=ax.transAxes)
    ax.text(0.55, 0.60, "[Họ và Tên]", fontsize=11, color='#0F172A', transform=ax.transAxes)
    ax.text(0.20, 0.55, "Mã số học viên:", fontsize=11, fontweight='bold', color='#334155', transform=ax.transAxes)
    ax.text(0.55, 0.55, "[Mã Số Học Viên]", fontsize=11, color='#0F172A', transform=ax.transAxes)
    ax.text(0.20, 0.50, "Lớp đào tạo:", fontsize=11, fontweight='bold', color='#334155', transform=ax.transAxes)
    ax.text(0.55, 0.50, "[Lớp / Khóa Học]", fontsize=11, color='#0F172A', transform=ax.transAxes)
    ax.text(0.20, 0.45, "Hệ quản trị CSDL:", fontsize=11, fontweight='bold', color='#334155', transform=ax.transAxes)
    ax.text(0.55, 0.45, "MySQL 8.0+", fontsize=11, color='#0F172A', transform=ax.transAxes)

    # Section 1 Summary
    ax.text(0.1, 0.35, "1. MỤC TIÊU VÀ PHẠM VI HỆ THỐNG", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    summary_text = (
        "• Mục tiêu: Xây dựng cơ sở dữ liệu bán hàng trực tuyến toàn diện, chuẩn hóa 3NF.\n"
        "• Quản lý các thực thể: Khách hàng, Danh mục, Sản phẩm, Tồn kho, Đơn hàng, Thanh toán.\n"
        "• Áp dụng kỹ thuật CSDL: Ràng buộc toàn vẹn, B-Tree Indexes, Views, Function, Trigger, ACID Transactions.\n"
        "• Cung cấp 15 câu truy vấn SQL nghiệp vụ từ cơ bản đến phức tạp (JOIN, Subquery, Window Function, CTE)."
    )
    ax.text(0.1, 0.23, summary_text, fontsize=9.5, color='#334155', linespacing=1.6, transform=ax.transAxes)

    ax.text(0.5, 0.08, "Báo cáo đề tài cá nhân | Năm học 2024 - 2026", fontsize=9, color='#94A3B8', ha='center', transform=ax.transAxes)
    pdf.savefig(fig)
    plt.close()

    # ---------------- PAGE 2: ENTITIES & NORMALIZATION ----------------
    fig, ax = plt.subplots(figsize=(8.27, 11.69), dpi=150)
    ax.axis('off')
    
    ax.text(0.08, 0.94, "2. PHÂN TÍCH YÊU CẦU & 7 BẢNG THỰC THỂ CỐT LÕI", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    
    tables_desc = (
        "1. customer: Lưu thông tin tài khoản khách hàng (customer_id, full_name, email, phone, status, deleted_at).\n"
        "2. category: Quản lý danh mục phân loại hàng hóa (category_id, category_name, description).\n"
        "3. product: Thông tin sản phẩm niêm yết (product_id, category_id, product_name, price, stock_quantity).\n"
        "4. inventory: Quản lý tồn kho thực tế, quan hệ 1:1 với product (inventory_id, product_id, quantity, updated_at).\n"
        "5. orders: Quản lý đơn hàng đặt mua từ khách hàng (order_id, customer_id, order_date, status, total_amount).\n"
        "6. order_item: Chi tiết từng sản phẩm trong đơn, bảng trung gian giải quyết quan hệ N:N giữa orders và product.\n"
        "7. payment: Quản lý giao dịch thanh toán đơn hàng (payment_id, order_id, method, status, amount, txn_code)."
    )
    ax.text(0.08, 0.78, tables_desc, fontsize=9, color='#334155', linespacing=1.5, transform=ax.transAxes)

    ax.text(0.08, 0.72, "3. QUÁ TRÌNH CHUẨN HÓA DỮ LIỆU ĐẾN 3NF", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    norm_text = (
        "• Dạng chuẩn 1 (1NF): Mọi ô dữ liệu đều chứa giá trị nguyên tử (Atomic values).\n"
        "  Không lưu danh sách nhiều sản phẩm dạng mảng/chuỗi phân tách trong bảng orders. Các mặt hàng được tách rời\n"
        "  thành từng dòng độc lập trong bảng order_item.\n\n"
        "• Dạng chuẩn 2 (2NF): Đã đạt 1NF và mọi thuộc tính không khóa phụ thuộc hàm đầy đủ vào khóa chính.\n"
        "  Bảng order_item sử dụng Surrogate PK 'order_item_id' kết hợp UNIQUE(order_id, product_id). Thông tin sản phẩm\n"
        "  (tên, giá niêm yết) được lưu tại bảng product chứ không lặp lại trong order_item. Thông tin khách hàng chỉ lưu tại customer.\n\n"
        "• Dạng chuẩn 3 (3NF): Đã đạt 2NF và không có thuộc tính không khóa nào phụ thuộc bắc cầu (Transitive Dependency).\n"
        "  - category_name thuộc bảng category, không lưu trong product (tránh product_id -> category_id -> category_name).\n"
        "  - Thông tin thanh toán (payment_method, transaction_code) được tách riêng sang bảng payment (orders -> payment)."
    )
    ax.text(0.08, 0.44, norm_text, fontsize=9, color='#334155', linespacing=1.45, transform=ax.transAxes)

    ax.text(0.08, 0.38, "4. SƠ ĐỒ THỰC THỂ QUAN HỆ (ERD)", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    erd_text = (
        "Sơ đồ quan hệ tổng quát:\n"
        "   CUSTOMER (1) ----- (N) ORDERS (1) ----- (1) PAYMENT\n"
        "                            |\n"
        "                           (1)\n"
        "                            |\n"
        "                           (N)\n"
        "                       ORDER_ITEM\n"
        "                           (N)\n"
        "                            |\n"
        "                           (1)\n"
        "   CATEGORY (1) ----- (N) PRODUCT (1) ----- (1) INVENTORY\n\n"
        "Tập tin đồ họa chi tiết được xuất tại: erd/online_shopping_erd.png và erd/online_shopping_erd.pdf\n"
        "Tệp cấu hình DBML tương thích trực tiếp dbdiagram.io: erd/schema.dbml"
    )
    ax.text(0.08, 0.16, erd_text, fontsize=9, color='#334155', linespacing=1.4, transform=ax.transAxes)

    ax.text(0.5, 0.05, "- Trang 2 -", fontsize=9, color='#94A3B8', ha='center', transform=ax.transAxes)
    pdf.savefig(fig)
    plt.close()

    # ---------------- PAGE 3: SQL INSTALLATION & QUERIES ----------------
    fig, ax = plt.subplots(figsize=(8.27, 11.69), dpi=150)
    ax.axis('off')

    ax.text(0.08, 0.94, "5. CÀI ĐẶT CSDL, INDEX, VIEW & PROCEDURES", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    db_setup = (
        "• Primary Key & Foreign Key: Thiết lập trên toàn bộ 7 bảng với ON DELETE RESTRICT / CASCADE phù hợp.\n"
        "• Ràng buộc toàn vẹn (Check Constraints): price >= 0, stock_quantity >= 0, quantity > 0, status hợp lệ.\n"
        "• Indexing: idx_orders_customer_id, idx_product_category_id, idx_orders_order_date, idx_product_price.\n"
        "• Views: v_order_summary (tổng hợp đơn & thanh toán), v_customer_spending_summary, v_product_inventory_status.\n"
        "• Functions & Procedures: fn_create_order (tạo đơn & trừ kho an toàn), sp_cancel_order (hủy đơn & hoàn kho).\n"
        "• Triggers: trg_calc_order_item_subtotal (tự động tính subtotal), trg_update_order_total_amount."
    )
    ax.text(0.08, 0.77, db_setup, fontsize=9, color='#334155', linespacing=1.45, transform=ax.transAxes)

    ax.text(0.08, 0.71, "6. TẬP HỢP 15 CÂU TRUY VẤN SQL ĐIỂN HÌNH (queries/queries.sql)", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    queries_summary = (
        "• Q01 (Basic Select): Lọc 10 sản phẩm đắt nhất đang hoạt động (WHERE + ORDER BY + LIMIT).\n"
        "• Q02 (Inner Join): Ghép nối sản phẩm với tên danh mục tương ứng.\n"
        "• Q03 (Left Join): Hiển thị toàn bộ khách hàng và tổng số đơn (kể cả khách chưa từng đặt hàng).\n"
        "• Q04 (Group By + Count): Đếm số lượng chủng loại sản phẩm và tổng tồn kho theo từng danh mục.\n"
        "• Q05 (Group By + Sum): Tính tổng doanh thu tích lũy thu được theo từng khách hàng.\n"
        "• Q06 (Aggregates): Thống kê giá bán trung bình (AVG), giá thấp nhất (MIN) và cao nhất (MAX).\n"
        "• Q07 (Subquery): Tìm các sản phẩm có giá bán cao hơn giá trung bình của toàn bộ cửa hàng.\n"
        "• Q08 (Window Function): DENSE_RANK() OVER (ORDER BY revenue DESC) xếp hạng sản phẩm theo doanh số.\n"
        "• Q09 (Case When): Phân hạng khách hàng thành VIP, Regular, Normal và New Lead dựa vào mức chi tiêu.\n"
        "• Q10 (Non-existent Data): Tìm khách hàng chưa phát sinh đơn hàng (LEFT JOIN ... IS NULL & NOT EXISTS).\n"
        "• Q11 (Duplicate Check): Phát hiện email hoặc số điện thoại bị trùng lặp bằng HAVING COUNT(*) > 1.\n"
        "• Q12 (Pagination): Phân trang sản phẩm phục vụ hiển thị ứng dụng Web (LIMIT và OFFSET).\n"
        "• Q13 (CTE): Ứng dụng WITH customer_revenue_cte AS (...) lọc khách hàng đem lại doanh thu cao.\n"
        "• Q14 (Nested Query): Tìm sản phẩm có doanh thu cao hơn doanh thu trung bình của cùng danh mục.\n"
        "• Q15 (Composite Report): Tạo báo cáo kinh doanh tổng hợp: đơn hàng, doanh thu thực tế, AOV theo tháng."
    )
    ax.text(0.08, 0.28, queries_summary, fontsize=8.5, color='#334155', linespacing=1.4, transform=ax.transAxes)

    ax.text(0.08, 0.22, "7. TỐI ƯU HÓA TRUY VẤN VỚI EXPLAIN ANALYZE", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    opt_text = (
        "• Trước khi đánh Index: MySQL sử dụng Table scan on orders, đọc tuần tự toàn bộ đĩa cứng.\n"
        "• Sau khi tạo idx_orders_customer_id: Chuyển sang Index lookup (ref), giảm 70-90% Cost & Time."
    )
    ax.text(0.08, 0.13, opt_text, fontsize=9, color='#334155', linespacing=1.45, transform=ax.transAxes)

    ax.text(0.5, 0.05, "- Trang 3 -", fontsize=9, color='#94A3B8', ha='center', transform=ax.transAxes)
    pdf.savefig(fig)
    plt.close()

    # ---------------- PAGE 4: BONUS & CONCLUSION ----------------
    fig, ax = plt.subplots(figsize=(8.27, 11.69), dpi=150)
    ax.axis('off')

    ax.text(0.08, 0.94, "8. CÁC TÍNH NĂNG NÂNG CAO (BONUS FEATURES)", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    bonus_text = (
        "1. Quản lý giao dịch Transaction: Đảm bảo tính toàn vẹn ACID khi tạo đơn (trừ kho, tạo hóa đơn).\n"
        "   Nếu xảy ra lỗi tồn kho không đủ, khối EXCEPTION sẽ tự động ROLLBACK hoàn toàn trạng thái.\n\n"
        "2. Hệ thống Audit Log: Tạo bảng audit_log và trigger tự động lưu vết các hành vi INSERT, UPDATE, DELETE\n"
        "   dưới định dạng JSONB chứa thông tin dữ liệu cũ (old_value) và mới (new_value).\n\n"
        "3. Xóa mềm (Soft Delete): Bổ sung trường deleted_at TIMESTAMP. Khi xóa, chỉ gán cờ thời gian thay vì xóa hẳn,\n"
        "   bảo vệ toàn vẹn lịch sử đơn hàng và tham chiếu khóa ngoại."
    )
    ax.text(0.08, 0.74, bonus_text, fontsize=9, color='#334155', linespacing=1.5, transform=ax.transAxes)

    ax.text(0.08, 0.68, "9. BÀI HỌC KINH NGHIỆM & KẾT LUẬN", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    lessons_text = (
        "• Nắm vững các bước chuẩn hóa cơ sở dữ liệu từ bài toán thực tế đến mô hình quan hệ 3NF.\n"
        "• Hiểu rõ vai trò của Constraints, Foreign Keys trong việc bảo vệ dữ liệu khỏi lỗi logic.\n"
        "• Thành thạo các kỹ thuật viết SQL phân tích số liệu kinh doanh: CTE, Window Functions, Group By.\n"
        "• Hiểu cách phân tích Execution Plan thông qua EXPLAIN ANALYZE và vai trò của B-Tree Index."
    )
    ax.text(0.08, 0.50, lessons_text, fontsize=9, color='#334155', linespacing=1.5, transform=ax.transAxes)

    ax.text(0.08, 0.44, "10. LIÊN KẾT NỘP BÀI VÀ THAM KHẢO", fontsize=12, fontweight='bold', color='#1E3A8A', transform=ax.transAxes)
    links_text = (
        "• GitHub Repository: [Điền link GitHub của học viên]\n"
        "• Video Demo (>= 2 phút): [Điền link YouTube / Google Drive của học viên]\n"
        "• ERD Online (dbdiagram.io): Dán mã nguồn từ file erd/schema.dbml"
    )
    ax.text(0.08, 0.32, links_text, fontsize=9.5, color='#334155', linespacing=1.6, transform=ax.transAxes)

    # Sign-off box
    sign_box = patches.FancyBboxPatch((0.50, 0.12), 0.42, 0.14, boxstyle="round,pad=0.02", facecolor='#F8FAFC', edgecolor='#CBD5E1', transform=ax.transAxes)
    ax.add_patch(sign_box)
    ax.text(0.71, 0.22, "Người thực hiện báo cáo", fontsize=10, fontweight='bold', color='#1E3A8A', ha='center', transform=ax.transAxes)
    ax.text(0.71, 0.15, "(Ký và ghi rõ họ tên)", fontsize=9, color='#64748B', style='italic', ha='center', transform=ax.transAxes)

    ax.text(0.5, 0.05, "- Trang 4 -", fontsize=9, color='#94A3B8', ha='center', transform=ax.transAxes)
    pdf.savefig(fig)
    plt.close()

print("Report PDF generated successfully!")
