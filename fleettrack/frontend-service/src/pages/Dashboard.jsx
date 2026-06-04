import { useState, useEffect } from 'react';
import { logisticsAPI } from '../services/api';
import { Link } from 'react-router-dom';

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [shipments, setShipments] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      logisticsAPI.get('/dashboard/stats'),
      logisticsAPI.get('/shipments')
    ]).then(([statsRes, shipRes]) => {
      setStats(statsRes.data.data);
      setShipments(shipRes.data.data.slice(0, 5));
    }).finally(() => setLoading(false));
  }, []);

  const statusBadge = (status) => {
    const map = {
      PENDING: 'badge-warning', PICKED_UP: 'badge-info', ON_DELIVERY: 'badge-info',
      ARRIVED_AT_WAREHOUSE: 'badge-info', DELIVERED: 'badge-success', CANCELLED: 'badge-danger'
    };
    return <span className={`badge ${map[status] || 'badge-gray'}`}>{status?.replace(/_/g, ' ')}</span>;
  };

  if (loading) return <div className="loading">⏳ Memuat dashboard...</div>;

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">📊 Dashboard</h1>
        <Link to="/shipments" className="btn btn-primary">+ Buat Pengiriman</Link>
      </div>

      <div className="stats-grid">
        {[
          { label: 'Total Armada', value: stats?.total_vehicles || 0, icon: '🚛', color: '#1a56db' },
          { label: 'Total Driver', value: stats?.total_drivers || 0, icon: '👤', color: '#0e9f6e' },
          { label: 'Total Pengiriman', value: stats?.total_shipments || 0, icon: '📦', color: '#ff5a1f' },
          { label: 'Pengiriman Aktif', value: stats?.active_shipments || 0, icon: '🛣️', color: '#7c3aed' },
          { label: 'Terkirim Hari Ini', value: stats?.delivered_today || 0, icon: '✅', color: '#059669' },
        ].map((s, i) => (
          <div key={i} className="stat-card">
            <div>
              <div className="stat-value" style={{ color: s.color }}>{s.value}</div>
              <div className="stat-label">{s.label}</div>
            </div>
            <div className="stat-icon">{s.icon}</div>
          </div>
        ))}
      </div>

      <div className="card">
        <div className="page-header" style={{ marginBottom: 16 }}>
          <h2 style={{ fontSize: 18, fontWeight: 600 }}>📋 Pengiriman Terbaru</h2>
          <Link to="/shipments" className="btn btn-outline btn-sm">Lihat Semua</Link>
        </div>
        <table>
          <thead>
            <tr>
              <th>No. Resi</th><th>Pengirim</th><th>Penerima</th>
              <th>Rute</th><th>Status</th><th>Tanggal</th>
            </tr>
          </thead>
          <tbody>
            {shipments.length === 0 ? (
              <tr><td colSpan={6} className="empty-state">Belum ada pengiriman</td></tr>
            ) : shipments.map(s => (
              <tr key={s.id}>
                <td><code style={{ fontSize: 12, background: '#f3f4f6', padding: '2px 6px', borderRadius: 4 }}>{s.tracking_number}</code></td>
                <td>{s.sender_name}</td>
                <td>{s.receiver_name}</td>
                <td style={{ fontSize: 12 }}>{s.origin_city} → {s.dest_city}</td>
                <td>{statusBadge(s.status)}</td>
                <td style={{ fontSize: 12, color: '#6b7280' }}>{new Date(s.created_at).toLocaleDateString('id-ID')}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
