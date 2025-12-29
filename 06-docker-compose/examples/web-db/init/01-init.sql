-- ===========================================
-- Database Initialization Script
-- ===========================================
-- This script runs automatically when the 
-- MariaDB container starts for the first time.
-- ===========================================
-- Create a sample table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Insert sample data
INSERT INTO users (username, email)
VALUES ('admin', 'admin@example.ir'),
    ('user1', 'user1@example.ir'),
    ('user2', 'user2@example.ir');
-- Create a posts table
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- Insert sample posts
INSERT INTO posts (user_id, title, content)
VALUES (
        1,
        'Welcome to Docker',
        'This is a sample post about Docker.'
    ),
    (
        2,
        'Docker Compose',
        'Learn how to use Docker Compose for multi-container apps.'
    );
-- Grant permissions
GRANT ALL PRIVILEGES ON *.* TO 'appuser' @'%';
FLUSH PRIVILEGES;