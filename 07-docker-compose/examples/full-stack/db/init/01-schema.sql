-- ===========================================
-- Database Initialization
-- ===========================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- Sample data
INSERT INTO users (username, email)
VALUES ('admin', 'admin@example.ir'),
    ('reporter', 'reporter@example.ir'),
    ('user', 'user@example.ir');
INSERT INTO posts (user_id, title, content)
VALUES (
        1,
        'Welcome to Docker',
        'Learn Docker with this comprehensive course.'
    ),
    (
        2,
        'Docker Compose',
        'Orchestrate multi-container applications easily.'
    ),
    (
        3,
        'Best Practices',
        'Follow these tips for production deployments.'
    );