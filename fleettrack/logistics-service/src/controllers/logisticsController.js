const { pool } = require('../config/database');

// ========== VEHICLES ==========
exports.getVehicles = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM vehicles ORDER BY created_at DESC');
    res.json({ success: true, data: rows });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getVehicle = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM vehicles WHERE id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ success: false, message: 'Kendaraan tidak ditemukan' });
    res.json({ success: true, data: rows[0] });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.createVehicle = async (req, res) => {
  try {
    const { license_plate, type, brand, model, year, capacity_kg, status } = req.body;
    const v_year = year === '' ? null : year;
    const v_cap = capacity_kg === '' ? null : capacity_kg;
    const [result] = await pool.execute(
      'INSERT INTO vehicles (license_plate, type, brand, model, year, capacity_kg, status) VALUES (?,?,?,?,?,?,?)',
      [license_plate, type, brand, model, v_year, v_cap, status || 'available']
    );
    res.status(201).json({ success: true, message: 'Kendaraan berhasil ditambahkan', data: { id: result.insertId } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateVehicle = async (req, res) => {
  try {
    const { license_plate, type, brand, model, year, capacity_kg, status } = req.body;
    const v_year = year === '' ? null : year;
    const v_cap = capacity_kg === '' ? null : capacity_kg;
    await pool.execute(
      'UPDATE vehicles SET license_plate=?, type=?, brand=?, model=?, year=?, capacity_kg=?, status=?, updated_at=NOW() WHERE id=?',
      [license_plate, type, brand, model, v_year, v_cap, status, req.params.id]
    );
    res.json({ success: true, message: 'Kendaraan berhasil diupdate' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.deleteVehicle = async (req, res) => {
  try {
    await pool.execute('DELETE FROM vehicles WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Kendaraan berhasil dihapus' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// ========== DRIVERS ==========
exports.getDrivers = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM drivers ORDER BY created_at DESC');
    res.json({ success: true, data: rows });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getDriver = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM drivers WHERE id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ success: false, message: 'Driver tidak ditemukan' });
    res.json({ success: true, data: rows[0] });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.createDriver = async (req, res) => {
  try {
    const { name, phone, license_number, license_expiry, status } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO drivers (name, phone, license_number, license_expiry, status) VALUES (?,?,?,?,?)',
      [name, phone, license_number, license_expiry, status || 'available']
    );
    res.status(201).json({ success: true, message: 'Driver berhasil ditambahkan', data: { id: result.insertId } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateDriver = async (req, res) => {
  try {
    const { name, phone, license_number, license_expiry, status } = req.body;
    await pool.execute(
      'UPDATE drivers SET name=?, phone=?, license_number=?, license_expiry=?, status=?, updated_at=NOW() WHERE id=?',
      [name, phone, license_number, license_expiry, status, req.params.id]
    );
    res.json({ success: true, message: 'Driver berhasil diupdate' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.deleteDriver = async (req, res) => {
  try {
    await pool.execute('DELETE FROM drivers WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Driver berhasil dihapus' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// ========== WAREHOUSES ==========
exports.getWarehouses = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM warehouses ORDER BY name');
    res.json({ success: true, data: rows });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.createWarehouse = async (req, res) => {
  try {
    const { name, city, address, latitude, longitude } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO warehouses (name, city, address, latitude, longitude) VALUES (?,?,?,?,?)',
      [name, city, address, latitude, longitude]
    );
    res.status(201).json({ success: true, message: 'Gudang berhasil ditambahkan', data: { id: result.insertId } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateWarehouse = async (req, res) => {
  try {
    const { name, city, address, latitude, longitude } = req.body;
    await pool.execute(
      'UPDATE warehouses SET name=?, city=?, address=?, latitude=?, longitude=? WHERE id=?',
      [name, city, address, latitude, longitude, req.params.id]
    );
    res.json({ success: true, message: 'Gudang berhasil diupdate' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.deleteWarehouse = async (req, res) => {
  try {
    await pool.execute('DELETE FROM warehouses WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Gudang berhasil dihapus' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// ========== ROUTES ==========
exports.getRoutes = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT r.*, wo.name as origin_name, wo.city as origin_city, wd.name as destination_name, wd.city as destination_city FROM routes r JOIN warehouses wo ON r.origin_warehouse_id = wo.id JOIN warehouses wd ON r.destination_warehouse_id = wd.id'
    );
    res.json({ success: true, data: rows });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.createRoute = async (req, res) => {
  try {
    const { origin_warehouse_id, destination_warehouse_id, distance_km, estimated_hours } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO routes (origin_warehouse_id, destination_warehouse_id, distance_km, estimated_hours) VALUES (?,?,?,?)',
      [origin_warehouse_id, destination_warehouse_id, distance_km, estimated_hours]
    );
    res.status(201).json({ success: true, message: 'Rute berhasil ditambahkan', data: { id: result.insertId } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
