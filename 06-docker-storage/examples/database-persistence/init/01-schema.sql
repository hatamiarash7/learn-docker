-- ============================================
-- Database Initialization Script
-- ============================================
-- This script runs automatically when the
-- database container is first created.
-- ============================================
-- Create tables
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
-- Insert sample data
INSERT INTO users (username, email)
VALUES ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com'),
    ('charlie', 'charlie@example.com');
INSERT INTO posts (user_id, title, content, published)
VALUES (
        1,
        'Getting Started with Docker',
        'Docker is a containerization platform...',
        TRUE
    ),
    (
        1,
        'Docker Volumes Explained',
        'Volumes are the preferred way to persist data...',
        TRUE
    ),
    (
        2,
        'My First Container',
        'Today I learned about containers...',
        FALSE
    ),
    (
        3,
        'Database Persistence',
        'How to persist database data using volumes...',
        TRUE
    );
-- Create a view for published posts
CREATE VIEW published_posts AS
SELECT p.id,
    p.title,
    p.content,
    u.username AS author,
    p.created_at
FROM posts p
    JOIN users u ON p.user_id = u.id
WHERE p.published = TRUE;