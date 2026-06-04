const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET || 'fleettrack_jwt_secret_key_2024';
const JWT_EXPIRES = process.env.JWT_EXPIRES_IN || '24h';

// POST /api/auth/register
exports.register = async (req, res) => {
  try {
    const { name, email, password, role = 'operator' } = req.body;
    if (!name || !email || !password)
      return res.status(400).json({ success: false, message: 'Semua field wajib diisi' });

    const [existing] = await pool.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0)
      return res.status(400).json({ success: false, message: 'Email sudah terdaftar' });

    const hashed = await bcrypt.hash(password, 10);
    const [result] = await pool.execute(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, hashed]
    );

    const [roles] = await pool.execute('SELECT id FROM roles WHERE name = ?', [role]);
    if (roles.length > 0) {
      await pool.execute('INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)', [result.insertId, roles[0].id]);
    }

    res.status(201).json({ success: true, message: 'User berhasil didaftarkan', data: { id: result.insertId, name, email } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /api/auth/login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ success: false, message: 'Email dan password wajib diisi' });

    const [users] = await pool.execute(
      'SELECT u.*, GROUP_CONCAT(r.name) as roles FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id WHERE u.email = ? GROUP BY u.id',
      [email]
    );

    if (users.length === 0)
      return res.status(401).json({ success: false, message: 'Email atau password salah' });

    const user = users[0];
    if (!user.is_active)
      return res.status(401).json({ success: false, message: 'Akun tidak aktif' });

    const match = await bcrypt.compare(password, user.password);
    if (!match)
      return res.status(401).json({ success: false, message: 'Email atau password salah' });

    const roles = user.roles ? user.roles.split(',') : [];
    const token = jwt.sign({ id: user.id, name: user.name, email: user.email, roles }, JWT_SECRET, { expiresIn: JWT_EXPIRES });

    await pool.execute(
      'INSERT INTO audit_logs (user_id, action, description, ip_address) VALUES (?, ?, ?, ?)',
      [user.id, 'LOGIN', 'User login berhasil', req.ip]
    );

    res.json({ success: true, message: 'Login berhasil', data: { token, user: { id: user.id, name: user.name, email: user.email, roles } } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /api/auth/me
exports.me = async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT u.id, u.name, u.email, u.is_active, u.created_at, GROUP_CONCAT(r.name) as roles FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id WHERE u.id = ? GROUP BY u.id',
      [req.user.id]
    );
    if (users.length === 0)
      return res.status(404).json({ success: false, message: 'User tidak ditemukan' });

    const user = users[0];
    user.roles = user.roles ? user.roles.split(',') : [];
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /api/auth/logout
exports.logout = async (req, res) => {
  try {
    await pool.execute(
      'INSERT INTO audit_logs (user_id, action, description) VALUES (?, ?, ?)',
      [req.user.id, 'LOGOUT', 'User logout']
    );
    res.json({ success: true, message: 'Logout berhasil' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /api/users
exports.getUsers = async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT u.id, u.name, u.email, u.is_active, u.created_at, GROUP_CONCAT(r.name) as roles FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id GROUP BY u.id ORDER BY u.created_at DESC'
    );
    users.forEach(u => { u.roles = u.roles ? u.roles.split(',') : []; });
    res.json({ success: true, data: users });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// PUT /api/users/:id
exports.updateUser = async (req, res) => {
  try {
    const { name, is_active } = req.body;
    await pool.execute('UPDATE users SET name = ?, is_active = ?, updated_at = NOW() WHERE id = ?', [name, is_active, req.params.id]);
    res.json({ success: true, message: 'User berhasil diupdate' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// DELETE /api/users/:id
exports.deleteUser = async (req, res) => {
  try {
    await pool.execute('DELETE FROM users WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'User berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
