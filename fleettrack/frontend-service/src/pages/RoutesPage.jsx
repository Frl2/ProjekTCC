import { useState, useEffect } from 'react';
import { logisticsAPI } from '../services/api';

export default function RoutesPage() {
  const [routes, setRoutes] = useState([]);
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [form, setForm] = useState({ origin_warehouse_id: '', destination_warehouse_id: '', distance_km: '', estimated_hours: '' });
  const [error, setError] = useState('');

  const load = () => Promise.all([
    logisticsAPI.get('/routes'),
    logisticsAPI.get('/warehouses')
  ]).then(([r, w]) => {
    setRoutes(r.data.data);
    setWarehouses(w.data.data);
  }).finally(() => setLoading(false));

  useEffect(() => { load(); }, []);

  const handleSubmit = async (e) => {
    e.preventDefault(); setError('');
    try {
      await logisticsAPI.post('/routes', form);
      setModal(false); load();
    } catch (err) { setError(err.response?.data?.message || 'Gagal menyimpan'); }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">🗺️ Manajemen Rute</h1>
        <button className="btn btn-primary" onClick={() => { setForm({ origin_warehouse_id: '', destination_warehouse_id: '', distance_km: '', estimated_hours: '' }); setError(''); setModal(true); }}>+ Tambah Rute</button>
      </div>
      <div className="card">
        {loading ? <div className="loading">Memuat...</div> : (
          <table>
            <thead><tr><th>Asal</th><th>Tujuan</th><th>Jarak (km)</th><th>Estimasi Waktu</th></tr></thead>
            <tbody>
              {routes.length === 0 ? <tr><td colSpan={4} className="empty-state">Belum ada rute</td></tr>
                : routes.map(r => (
                  <tr key={r.id}>
                    <td>🏭 <strong>{r.origin_name}</strong><br /><small style={{ color: '#6b7280' }}>{r.origin_city}</small></td>
                    <td>📍 <strong>{r.destination_name}</strong><br /><small style={{ color: '#6b7280' }}>{r.destination_city}</small></td>
                    <td>{r.distance_km} km</td>
                    <td>~{r.estimated_hours} jam</td>
                  </tr>
                ))}
            </tbody>
          </table>
        )}
      </div>
      {modal && (
        <div className="modal-overlay" onClick={() => setModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Tambah Rute</h3>
              <button className="modal-close" onClick={() => setModal(false)}>×</button>
            </div>
            {error && <div className="alert alert-error">{error}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label>Gudang Asal</label>
                <select className="form-control" value={form.origin_warehouse_id} onChange={e => setForm({ ...form, origin_warehouse_id: e.target.value })} required>
                  <option value="">-- Pilih Gudang Asal --</option>
                  {warehouses.map(w => <option key={w.id} value={w.id}>{w.name} ({w.city})</option>)}
                </select>
              </div>
              <div className="form-group">
                <label>Gudang Tujuan</label>
                <select className="form-control" value={form.destination_warehouse_id} onChange={e => setForm({ ...form, destination_warehouse_id: e.target.value })} required>
                  <option value="">-- Pilih Gudang Tujuan --</option>
                  {warehouses.map(w => <option key={w.id} value={w.id}>{w.name} ({w.city})</option>)}
                </select>
              </div>
              <div className="form-group">
                <label>Jarak (km)</label>
                <input className="form-control" type="number" value={form.distance_km} onChange={e => setForm({ ...form, distance_km: e.target.value })} required />
              </div>
              <div className="form-group">
                <label>Estimasi Waktu (jam)</label>
                <input className="form-control" type="number" value={form.estimated_hours} onChange={e => setForm({ ...form, estimated_hours: e.target.value })} required />
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-outline" onClick={() => setModal(false)}>Batal</button>
                <button type="submit" className="btn btn-primary">Simpan</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
