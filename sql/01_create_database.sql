-- File: 01_create_database.sql

DROP DATABASE IF EXISTS online_shopping_db;

CREATE DATABASE online_shopping_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE online_shopping_db;

SELECT 'Database online_shopping_db đã được tạo thành công trên MySQL!' AS Status;
