const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

const isCloudSQL = process.env.DB_HOST && process.env.DB_HOST.startsWith('/cloudsql');

const poolConfig = {
  host: isCloudSQL ? undefined : (process.env.DB_HOST || 'localhost'),
  socketPath: isCloudSQL ? process.env.DB_HOST : undefined,
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root123',
  waitForConnections: true,
  connectionLimit: 10,
  multipleStatements: false
};

const pool = mysql.createPool({ ...poolConfig, database: process.env.DB_NAME || 'auth_db' });

async function runSQL(conn, sql) {
  const statements = sql
    .split(';')
    .map(s => s.trim())
    .filter(s => s.length > 0 && !s.toUpperCase().startsWith('USE ') && !s.toUpperCase().startsWith('CREATE DATABASE'));
  for (const stmt of statements) {
    try { await conn.query(stmt); } catch (e) { /* skip duplicate */ }
  }
}

async function initDB() {
  let conn;
  try {
    conn = await mysql.createConnection(poolConfig);
    await conn.query('CREATE DATABASE IF NOT EXISTS auth_db');
    await conn.query('USE auth_db');

    const schemaPath = path.join(__dirname, '../../database/auth_schema.sql');
    const seedPath = path.join(__dirname, '../../database/auth_seed.sql');

    if (fs.existsSync(schemaPath)) {
      const sql = fs.readFileSync(schemaPath, 'utf8');
      await runSQL(conn, sql);
    }
    if (fs.existsSync(seedPath)) {
      const sql = fs.readFileSync(seedPath, 'utf8');
      await runSQL(conn, sql);
    }
    console.log('✅ Database auth_db initialized');
  } catch (err) {
    console.error('DB init error:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

module.exports = { pool, initDB };