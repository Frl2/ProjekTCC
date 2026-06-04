const { pool } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

// GET /api/shipments
exports.getShipments = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT s.*, r.distance_km, r.estimated_hours,
        wo.name as origin_name, wo.city as origin_city,
        wd.name as dest_name, wd.city as dest_city,
        v.license_plate, v.type as vehicle_type,
        d.name as driver_name, d.phone as driver_phone
       FROM shipments s
       JOIN routes r ON s.route_id = r.id
       JOIN warehouses wo ON r.origin_warehouse_id = wo.id
       JOIN warehouses wd ON r.destination_warehouse_id = wd.id
       LEFT JOIN vehicles v ON s.vehicle_id = v.id
       LEFT JOIN drivers d ON s.driver_id = d.id
       ORDER BY s.created_at DESC`
    );
    res.json({ success: true, data: rows });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// GET /api/shipments/:id
exports.getShipment = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT s.*, r.distance_km, r.estimated_hours,
        wo.name as origin_name, wo.city as origin_city,
        wd.name as dest_name, wd.city as dest_city,
        v.license_plate, v.type as vehicle_type,
        d.name as driver_name, d.phone as driver_phone
       FROM shipments s
       JOIN routes r ON s.route_id = r.id
       JOIN warehouses wo ON r.origin_warehouse_id = wo.id
       JOIN warehouses wd ON r.destination_warehouse_id = wd.id
       LEFT JOIN vehicles v ON s.vehicle_id = v.id
       LEFT JOIN drivers d ON s.driver_id = d.id
       WHERE s.id = ?`, [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'Pengiriman tidak ditemukan' });

    const [logs] = await pool.execute(
      'SELECT * FROM tracking_logs WHERE shipment_id = ? ORDER BY created_at ASC', [req.params.id]
    );

    res.json({ success: true, data: { ...rows[0], tracking_logs: logs } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// POST /api/shipments
exports.createShipment = async (req, res) => {
  try {
    const { route_id, vehicle_id, driver_id, sender_name, receiver_name, receiver_phone, receiver_address, weight_kg, description, scheduled_date } = req.body;
    const tracking_number = 'FT-' + Date.now().toString().slice(-8) + '-' + uuidv4().slice(0, 4).toUpperCase();

    const [result] = await pool.execute(
      'INSERT INTO shipments (tracking_number, route_id, vehicle_id, driver_id, sender_name, receiver_name, receiver_phone, receiver_address, weight_kg, description, scheduled_date) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [tracking_number, route_id, vehicle_id, driver_id, sender_name, receiver_name, receiver_phone, receiver_address, weight_kg, description, scheduled_date]
    );

    await pool.execute(
      'INSERT INTO tracking_logs (shipment_id, status, notes) VALUES (?, ?, ?)',
      [result.insertId, 'PENDING', 'Pengiriman dibuat']
    );

    res.status(201).json({ success: true, message: 'Pengiriman berhasil dibuat', data: { id: result.insertId, tracking_number } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// PUT /api/shipments/:id/status
exports.updateStatus = async (req, res) => {
  try {
    const { status, location, latitude, longitude, notes } = req.body;
    const validStatuses = ['PENDING','PICKED_UP','ON_DELIVERY','ARRIVED_AT_WAREHOUSE','DELIVERED','CANCELLED'];
    if (!validStatuses.includes(status))
      return res.status(400).json({ success: false, message: 'Status tidak valid' });

    await pool.execute('UPDATE shipments SET status=?, updated_at=NOW() WHERE id=?', [status, req.params.id]);
    await pool.execute(
      'INSERT INTO tracking_logs (shipment_id, status, location, latitude, longitude, notes) VALUES (?,?,?,?,?,?)',
      [req.params.id, status, location, latitude, longitude, notes]
    );

    if (status === 'ON_DELIVERY') {
      const [s] = await pool.execute('SELECT vehicle_id, driver_id FROM shipments WHERE id=?', [req.params.id]);
      if (s.length > 0) {
        if (s[0].vehicle_id) await pool.execute("UPDATE vehicles SET status='on_trip' WHERE id=?", [s[0].vehicle_id]);
        if (s[0].driver_id) await pool.execute("UPDATE drivers SET status='on_trip' WHERE id=?", [s[0].driver_id]);
      }
    }

    if (status === 'DELIVERED' || status === 'CANCELLED') {
      const [s] = await pool.execute('SELECT vehicle_id, driver_id FROM shipments WHERE id=?', [req.params.id]);
      if (s.length > 0) {
        if (s[0].vehicle_id) await pool.execute("UPDATE vehicles SET status='available' WHERE id=?", [s[0].vehicle_id]);
        if (s[0].driver_id) await pool.execute("UPDATE drivers SET status='available' WHERE id=?", [s[0].driver_id]);
      }
    }

    res.json({ success: true, message: 'Status pengiriman berhasil diupdate' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// GET /api/shipments/track/:tracking_number
exports.trackByNumber = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT s.*, wo.name as origin_name, wo.city as origin_city, wd.name as dest_name, wd.city as dest_city
       FROM shipments s JOIN routes r ON s.route_id = r.id
       JOIN warehouses wo ON r.origin_warehouse_id = wo.id
       JOIN warehouses wd ON r.destination_warehouse_id = wd.id
       WHERE s.tracking_number = ?`, [req.params.tracking_number]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'Nomor resi tidak ditemukan' });

    const [logs] = await pool.execute(
      'SELECT * FROM tracking_logs WHERE shipment_id = ? ORDER BY created_at ASC', [rows[0].id]
    );

    res.json({ success: true, data: { ...rows[0], tracking_logs: logs } });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

// Dashboard stats
exports.getDashboardStats = async (req, res) => {
  try {
    const [[vCount]] = await pool.execute('SELECT COUNT(*) as total FROM vehicles WHERE status != "inactive"');
    const [[dCount]] = await pool.execute('SELECT COUNT(*) as total FROM drivers WHERE status != "inactive"');
    const [[sCount]] = await pool.execute('SELECT COUNT(*) as total FROM shipments');
    const [[activeShip]] = await pool.execute("SELECT COUNT(*) as total FROM shipments WHERE status IN ('PICKED_UP','ON_DELIVERY')");
    const [[deliveredToday]] = await pool.execute("SELECT COUNT(*) as total FROM shipments WHERE status='DELIVERED' AND DATE(updated_at)=CURDATE()");

    res.json({
      success: true,
      data: {
        total_vehicles: vCount.total,
        total_drivers: dCount.total,
        total_shipments: sCount.total,
        active_shipments: activeShip.total,
        delivered_today: deliveredToday.total
      }
    });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
