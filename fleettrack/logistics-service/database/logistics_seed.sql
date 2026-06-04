-- logistics_seed.sql
USE logistics_db;

INSERT INTO warehouses (name, city, address, latitude, longitude) VALUES
('Gudang Jakarta Pusat', 'Jakarta', 'Jl. Sudirman No. 1, Jakarta Pusat', -6.2088, 106.8456),
('Gudang Surabaya', 'Surabaya', 'Jl. Raya Darmo No. 10, Surabaya', -7.2575, 112.7521),
('Gudang Semarang', 'Semarang', 'Jl. Pemuda No. 5, Semarang', -6.9666, 110.4166),
('Gudang Yogyakarta', 'Yogyakarta', 'Jl. Malioboro No. 20, Yogyakarta', -7.7956, 110.3695),
('Gudang Bandung', 'Bandung', 'Jl. Asia Afrika No. 8, Bandung', -6.9175, 107.6191);

INSERT INTO routes (origin_warehouse_id, destination_warehouse_id, distance_km, estimated_hours) VALUES
(1, 2, 785.0, 12),
(1, 3, 445.0, 7),
(1, 4, 560.0, 8),
(1, 5, 150.0, 3),
(2, 3, 345.0, 5),
(3, 4, 115.0, 2);

INSERT INTO vehicles (license_plate, type, brand, model, year, capacity_kg, status) VALUES
('B 1234 ABC', 'Truk Besar', 'Hino', 'Dutro 130', 2020, 5000, 'available'),
('B 5678 DEF', 'Truk Sedang', 'Mitsubishi', 'Colt Diesel', 2019, 3000, 'available'),
('B 9012 GHI', 'Pick Up', 'Toyota', 'Hilux', 2021, 1000, 'available'),
('D 3456 JKL', 'Truk Besar', 'Isuzu', 'Giga', 2022, 8000, 'available');

INSERT INTO drivers (name, phone, license_number, license_expiry, status) VALUES
('Budi Santoso', '081234567890', 'SIM-B1-001', '2026-12-31', 'available'),
('Agus Prasetyo', '082345678901', 'SIM-B1-002', '2025-06-30', 'available'),
('Slamet Riyadi', '083456789012', 'SIM-B2-003', '2027-03-15', 'available');
