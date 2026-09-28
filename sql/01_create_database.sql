-- ============================================================
-- BÀI TẬP CÁ NHÂN: DATABASE DESIGN & SQL
-- ĐỀ TÀI: HỆ THỐNG BÁN HÀNG ONLINE (ONLINE SHOPPING SYSTEM)
-- FILE: 01_create_database.sql
-- HỆ THỐNG: MySQL 8.0+ (InnoDB Engine)
-- MỤC ĐÍCH: Khởi tạo database MySQL cho hệ thống bán hàng
-- ============================================================

-- 1. Xóa database nếu đã tồn tại trước đó
DROP DATABASE IF EXISTS online_shopping_db;

-- 2. Tạo database mới với bảng mã utf8mb4 hỗ trợ đầy đủ tiếng Việt và emoji
CREATE DATABASE online_shopping_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 3. Chọn database vừa tạo để bắt đầu làm việc
USE online_shopping_db;

SELECT 'Database online_shopping_db đã được tạo thành công trên MySQL!' AS Status;
