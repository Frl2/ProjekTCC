import { useState, useEffect } from 'react';
import { logisticsAPI } from '../services/api';

const EMPTY_W = { name: '', city: '', address: '', latitude: '', longitude: '' };

export function WarehousesPage() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [form, setForm] = useState(EMPTY_W);
  const [editing, setEditing] = useState(null);
  const [error, setError] = useState('');

  const load = () => logisticsAPI.get('/warehouses').then(r => setData(r.data.data)).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const handleSubmit = async (e) => {
    e.preventDefault(); setError('');
    try {
      if (editing) await logisticsAPI.put(`/warehouses/${editing}`, form);
      else await logisticsAPI.post('/warehouses', form);
      setModal(false); load();
    } catch (err) { setError(err.response?.data?.message || 'Gagal menyimpan'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Hapus gudang ini?')) return;
    try { await logisticsAPI.delete(`/warehouses/${id}`); load(); }
    catch (err) { alert(err.response?.data?.message || 'Gagal menghapus'); }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">🏭 Manajemen Gudang</h1>
        <button className="btn btn-primary" onClick={() => { setForm(EMPTY_W); setEditing(null); setError(''); setModal(true); }}>+ Tambah Gudang</button>
      </div>
      <div className="card">
        {loading ? <div className="loading">Memuat...</div> : (
          <table>
            <thead><tr><th>Nama Gudang</th><th>Kota</th><th>Alamat</th><th>Koordinat</th><th>Aksi</th></tr></thead>
            <tbody>
              {data.length === 0 ? <tr><td colSpan={5} className="empty-state">Belum ada gudang</td></tr>
                : data.map(w => (
                  <tr key={w.id}>
                    <td><strong>{w.name}</strong></td>
                    <td>{w.city}</td>
                    <td style={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{w.address}</td>
                    <td style={{ fontSize: 12, color: '#6b7280' }}>{w.latitude}, {w.longitude}</td>
                    <td>
                      <button className="btn btn-outline btn-sm" style={{ marginRight: 6 }} onClick={() => { setForm(w); setEditing(w.id); setError(''); setModal(true); }}>✏️</button>
                      <button className="btn btn-danger btn-sm" onClick={() => handleDelete(w.id)}>🗑️</button>
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
              <h3 className="modal-title">{editing ? 'Edit' : 'Tambah'} Gudang</h3>
              <button className="modal-close" onClick={() => setModal(false)}>×</button>
            </div>
            {error && <div className="alert alert-error">{error}</div>}
            <form onSubmit={handleSubmit}>
              {[['name','Nama Gudang'],['city','Kota'],['address','Alamat'],['latitude','Latitude'],['longitude','Longitude']].map(([k, l]) => (
                <div className="form-group" key={k}>
                  <label>{l}</label>
                  <input className="form-control" value={form[k] || ''} onChange={e => setForm({ ...form, [k]: e.target.value })} required={['name','city'].includes(k)} />
                </div>
              ))}
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

export default WarehousesPage;
