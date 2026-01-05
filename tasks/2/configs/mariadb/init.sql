-- ============================================
-- ShopStream Database Initialization
-- ============================================
-- This script initializes the database schema
-- for all microservices.
-- ============================================
-- Create database if not exists
CREATE DATABASE IF NOT EXISTS shopstream CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shopstream;
-- ============================================
-- Users Table (Auth Service)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_active (is_active)
) ENGINE = InnoDB;
-- ============================================
-- Refresh Tokens Table (Auth Service)
-- ============================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token_hash),
    INDEX idx_user (user_id),
    INDEX idx_expires (expires_at)
) ENGINE = InnoDB;
-- ============================================
-- Categories Table (Product Service)
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    parent_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE
    SET NULL,
        INDEX idx_slug (slug),
        INDEX idx_parent (parent_id)
) ENGINE = InnoDB;
-- ============================================
-- Products Table (Product Service)
-- ============================================
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    category_id INT NULL,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE
    SET NULL,
        INDEX idx_slug (slug),
        INDEX idx_category (category_id),
        INDEX idx_active (is_active),
        INDEX idx_price (price),
        FULLTEXT idx_search (name, description)
) ENGINE = InnoDB;
-- ============================================
-- Orders Table (Order Service)
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    status ENUM(
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled'
    ) DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_address TEXT,
    payment_method VARCHAR(50),
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE = InnoDB;
-- ============================================
-- Order Items Table (Order Service)
-- ============================================
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE = InnoDB;
-- ============================================
-- Order Status History (Order Service)
-- ============================================
CREATE TABLE IF NOT EXISTS order_status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by INT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE
    SET NULL,
        INDEX idx_order (order_id),
        INDEX idx_created (created_at)
) ENGINE = InnoDB;
-- ============================================
-- Insert Default Data
-- ============================================
-- Default Categories
INSERT IGNORE INTO categories (id, name, slug, description)
VALUES (
        1,
        'Electronics',
        'electronics',
        'Electronic devices and gadgets'
    ),
    (2, 'Clothing', 'clothing', 'Fashion and apparel'),
    (3, 'Books', 'books', 'Books and literature'),
    (
        4,
        'Home & Garden',
        'home-garden',
        'Home improvement and garden supplies'
    ),
    (
        5,
        'Sports',
        'sports',
        'Sports equipment and accessories'
    );
-- Sample Products
INSERT IGNORE INTO products (
        id,
        name,
        slug,
        description,
        price,
        stock,
        category_id,
        is_active
    )
VALUES (
        1,
        'Wireless Headphones',
        'wireless-headphones',
        'High-quality wireless headphones with noise cancellation',
        199.99,
        100,
        1,
        TRUE
    ),
    (
        2,
        'Smart Watch Pro',
        'smart-watch-pro',
        'Advanced smartwatch with health monitoring',
        349.99,
        50,
        1,
        TRUE
    ),
    (
        3,
        'Mechanical Keyboard',
        'mechanical-keyboard',
        'RGB mechanical keyboard with Cherry MX switches',
        149.99,
        75,
        1,
        TRUE
    ),
    (
        4,
        'Cotton T-Shirt',
        'cotton-t-shirt',
        'Premium cotton t-shirt, available in multiple colors',
        29.99,
        200,
        2,
        TRUE
    ),
    (
        5,
        'Running Shoes',
        'running-shoes',
        'Lightweight running shoes with cushioned sole',
        89.99,
        120,
        5,
        TRUE
    ),
    (
        6,
        'Docker Deep Dive',
        'docker-deep-dive',
        'Comprehensive guide to Docker and containers',
        49.99,
        500,
        3,
        TRUE
    ),
    (
        7,
        'Yoga Mat',
        'yoga-mat',
        'Non-slip yoga mat with carrying strap',
        34.99,
        80,
        5,
        TRUE
    ),
    (
        8,
        'LED Desk Lamp',
        'led-desk-lamp',
        'Adjustable LED desk lamp with USB charging port',
        59.99,
        60,
        4,
        TRUE
    );
-- Admin User (password: admin123)
INSERT IGNORE INTO users (
        id,
        name,
        email,
        password_hash,
        is_active,
        is_admin
    )
VALUES (
        1,
        'Admin User',
        'admin@shopstream.io',
        'pbkdf2:sha256:260000$salt$hash',
        TRUE,
        TRUE
    );
-- ============================================
-- Stored Procedures
-- ============================================
DELIMITER // -- Update product stock after order
CREATE PROCEDURE IF NOT EXISTS UpdateProductStock(IN p_product_id INT, IN p_quantity INT) BEGIN
UPDATE products
SET stock = stock - p_quantity,
    updated_at = CURRENT_TIMESTAMP
WHERE id = p_product_id
    AND stock >= p_quantity;
IF ROW_COUNT() = 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Insufficient stock';
END IF;
END // -- Get order summary
CREATE PROCEDURE IF NOT EXISTS GetOrderSummary(IN p_user_id INT) BEGIN
SELECT COUNT(*) as total_orders,
    COALESCE(SUM(total_amount), 0) as total_spent,
    COALESCE(AVG(total_amount), 0) as avg_order_value
FROM orders
WHERE user_id = p_user_id;
END // DELIMITER;
-- ============================================
-- Views
-- ============================================
CREATE OR REPLACE VIEW v_order_details AS
SELECT o.id AS order_id,
    o.user_id,
    u.name AS customer_name,
    u.email AS customer_email,
    o.status,
    o.total_amount,
    o.payment_status,
    o.created_at,
    COUNT(oi.id) AS item_count
FROM orders o
    JOIN users u ON o.user_id = u.id
    LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;
CREATE OR REPLACE VIEW v_product_sales AS
SELECT p.id AS product_id,
    p.name AS product_name,
    p.price,
    p.stock,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    COALESCE(SUM(oi.total_price), 0) AS total_revenue
FROM products p
    LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id;
-- ============================================
-- Grants
-- ============================================
-- Create application user (use the password from secrets)
-- This should match the db_password secret
-- GRANT ALL PRIVILEGES ON shopstream.* TO 'appuser'@'%' IDENTIFIED BY 'password_from_secret';
-- FLUSH PRIVILEGES;
SELECT 'Database initialization complete!' AS status;