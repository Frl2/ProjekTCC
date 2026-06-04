-- ==========================================
-- SCRIPT INISIALISASI DATABASE FLEETTRACK
-- ==========================================

-- 1. SETUP DATABASE AUTH
CREATE DATABASE IF NOT EXISTS auth_db;
USE auth_db;

-- Tabel Roles
CREATE TABLE IF NOT EXISTS roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Users
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel User Roles
CREATE TABLE IF NOT EXISTS user_roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_role (user_id, role_id)
);

-- Tabel Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(100) NOT NULL,
  description TEXT,
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Data Awal Auth (Password: admin123)
INSERT IGNORE INTO roles (id, name, description) VALUES 
(1, 'admin', 'Administrator dengan akses penuh'),
(2, 'operator', 'Operator yang dapat mengelola pengiriman'),
(3, 'driver', 'Sopir armada');

INSERT IGNORE INTO users (id, name, email, password) VALUES 
(1, 'Administrator', 'admin@fleettrack.com', '$2a$10$EKKGVSV5SYKa9zZsKIv8vOXGy4zrXP5RgcCYscjFSPvRb8QjLJpKC');

INSERT IGNORE INTO user_roles (user_id, role_id) VALUES (1, 1);


-- 2. SETUP DATABASE LOGISTICS
CREATE DATABASE IF NOT EXISTS logistics_db;
USE logistics_db;

-- Tabel Kendaraan
CREATE TABLE IF NOT EXISTS vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  license_plate VARCHAR(20) NOT NULL UNIQUE,
  type VARCHAR(50) NOT NULL,
  brand VARCHAR(50),
  model VARCHAR(50),
  year INT,
  capacity_kg DECIMAL(10,2),
  status ENUM('available','on_trip','maintenance','inactive') DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Driver
CREATE TABLE IF NOT EXISTS drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  license_number VARCHAR(50) UNIQUE,
  license_expiry DATE,
  status ENUM('available','on_trip','off','inactive') DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Gudang
CREATE TABLE IF NOT EXISTS warehouses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  address TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Rute
CREATE TABLE IF NOT EXISTS routes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  origin_warehouse_id INT NOT NULL,
  destination_warehouse_id INT NOT NULL,
  distance_km DECIMAL(10,2),
  estimated_hours INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (origin_warehouse_id) REFERENCES warehouses(id),
  FOREIGN KEY (destination_warehouse_id) REFERENCES warehouses(id)
);

-- Tabel Pengiriman
CREATE TABLE IF NOT EXISTS shipments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tracking_number VARCHAR(50) NOT NULL UNIQUE,
  route_id INT NOT NULL,
  vehicle_id INT,
  driver_id INT,
  sender_name VARCHAR(100),
  receiver_name VARCHAR(100),
  receiver_phone VARCHAR(20),
  receiver_address TEXT,
  weight_kg DECIMAL(10,2),
  status ENUM('PENDING','PICKED_UP','ON_DELIVERY','ARRIVED_AT_WAREHOUSE','DELIVERED','CANCELLED') DEFAULT 'PENDING',
  scheduled_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- Tabel Tracking
CREATE TABLE IF NOT EXISTS tracking_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  shipment_id INT NOT NULL,
  status VARCHAR(50) NOT NULL,
  location VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
);

-- Data Awal Logistics
INSERT IGNORE INTO warehouses (name, city, address) VALUES 
('Gudang Jakarta Pusat', 'Jakarta', 'Jl. Sudirman No. 1'),
('Gudang Surabaya', 'Surabaya', 'Jl. Raya Darmo No. 10');

INSERT IGNORE INTO vehicles (license_plate, type, brand, status) VALUES 
('B 1234 ABC', 'Truk Besar', 'Hino', 'available'),
('B 5678 DEF', 'Truk Sedang', 'Mitsubishi', 'available');

INSERT IGNORE INTO drivers (name, phone, status) VALUES 
('Budi Santoso', '081234567890', 'available'),
('Agus Prasetyo', '082345678901', 'available');
