USE auth_db;

INSERT IGNORE INTO roles (name, description) VALUES
('admin', 'Administrator dengan akses penuh'),
('operator', 'Operator yang dapat mengelola pengiriman'),
('driver', 'Sopir armada');

INSERT IGNORE INTO users (id, name, email, password) VALUES
(1, 'Administrator', 'admin@fleettrack.com', '$2a$10$EKKGVSV5SYKa9zZsKIv8vOXGy4zrXP5RgcCYscjFSPvRb8QjLJpKC'),
(2, 'Operator TCC', 'operator@fleettrack.com', '$2a$10$EKKGVSV5SYKa9zZsKIv8vOXGy4zrXP5RgcCYscjFSPvRb8QjLJpKC');

INSERT IGNORE INTO user_roles (user_id, role_id) VALUES (1, 1);
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES (2, 2);