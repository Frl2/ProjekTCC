import { useState, useEffect } from 'react';
import { logisticsAPI } from '../services/api';

const statusBadge = (s) => {
  const m = { available: 'badge-success', on_trip: 'badge-info', maintenance: 'badge-warning', inactive: 'badge-gray' };
  return <span className={`badge ${m[s] || 'badge-gray'}`}>{s}</span>;
};

const EMPTY = { license_plate: '', type: '', brand: '', model: '', year: '', capacity_kg: '', status: 'available' };

export default function VehiclesPage() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [form, setForm] = useState(EMPTY);
  const [editing, setEditing] = useState(null);
  const [error, setError] = useState('');

  const load = () => logisticsAPI.get('/vehicles').then(r => setData(r.data.data)).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const openAdd = () => { setForm(EMPTY); setEditing(null); setError(''); setModal(true); };
  const openEdit = (v) => { setForm(v); setEditing(v.id); setError(''); setModal(true); };

  const handleSubmit = async (e) => {
    e.preventDefault(); setError('');
    try {
      if (editing) await logisticsAPI.put(`/vehicles/${editing}`, form);
      else await logisticsAPI.post('/vehicles', form);
      setModal(false); load();
    } catch (err) { setError(err.response?.data?.message || 'Gagal menyimpan'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Hapus kendaraan ini?')) return;
    try { await logisticsAPI.delete(`/vehicles/${id}`); load(); }
    catch (err) { alert(err.response?.data?.message || 'Gagal menghapus'); }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">🚛 Manajemen Armada</h1>
        <button className="btn btn-primary" onClick={openAdd}>+ Tambah Armada</button>
      </div>
      <div className="card">
        {loading ? <div className="loading">Memuat...</div> : (
          <table>
            <thead><tr><th>No. Polisi</th><th>Tipe</th><th>Merek/Model</th><th>Tahun</th><th>Kapasitas (kg)</th><th>Status</th><th>Aksi</th></tr></thead>
            <tbody>
              {data.length === 0 ? <tr><td colSpan={7} className="empty-state">Belum ada data armada</td></tr>
                : data.map(v => (
                  <tr key={v.id}>
                    <td><strong>{v.license_plate}</strong></td>
                    <td>{v.type}</td>
                    <td>{v.brand} {v.model}</td>
                    <td>{v.year}</td>
                    <td>{v.capacity_kg?.toLocaleString()}</td>
                    <td>{statusBadge(v.status)}</td>
                    <td>
                      <button className="btn btn-outline btn-sm" onClick={() => openEdit(v)} style={{ marginRight: 6 }}>✏️</button>
                      <button className="btn btn-danger btn-sm" onClick={() => handleDelete(v.id)}>🗑️</button>
                    </td>
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
              <h3 className="modal-title">{editing ? 'Edit' : 'Tambah'} Armada</h3>
              <button className="modal-close" onClick={() => setModal(false)}>×</button>
            </div>
            {error && <div className="alert alert-error">{error}</div>}
            <form onSubmit={handleSubmit}>
              {[['license_plate','Nomor Polisi'],['type','Tipe Kendaraan'],['brand','Merek'],['model','Model'],['year','Tahun'],['capacity_kg','Kapasitas (kg)']].map(([k, l]) => (
                <div className="form-group" key={k}>
                  <label>{l}</label>
                  <input className="form-control" value={form[k] || ''} onChange={e => setForm({ ...form, [k]: e.target.value })} required={['license_plate','type'].includes(k)} />
                </div>
              ))}
              <div className="form-group">
                <label>Status</label>
                <select className="form-control" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                  {['available','on_trip','maintenance','inactive'].map(s => <option key={s} value={s}>{s}</option>)}
                </select>
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end', marginTop: 8 }}>
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
