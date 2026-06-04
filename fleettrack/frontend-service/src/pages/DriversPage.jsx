import { useState, useEffect } from 'react';
import { logisticsAPI } from '../services/api';

const statusBadge = (s) => {
  const m = { available: 'badge-success', on_trip: 'badge-info', off: 'badge-warning', inactive: 'badge-gray' };
  return <span className={`badge ${m[s] || 'badge-gray'}`}>{s}</span>;
};

const EMPTY = { name: '', phone: '', license_number: '', license_expiry: '', status: 'available' };

export default function DriversPage() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [form, setForm] = useState(EMPTY);
  const [editing, setEditing] = useState(null);
  const [error, setError] = useState('');

  const load = () => logisticsAPI.get('/drivers').then(r => setData(r.data.data)).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const openAdd = () => { setForm(EMPTY); setEditing(null); setError(''); setModal(true); };
  const openEdit = (d) => { setForm({ ...d, license_expiry: d.license_expiry?.split('T')[0] }); setEditing(d.id); setError(''); setModal(true); };

  const handleSubmit = async (e) => {
    e.preventDefault(); setError('');
    try {
      if (editing) await logisticsAPI.put(`/drivers/${editing}`, form);
      else await logisticsAPI.post('/drivers', form);
      setModal(false); load();
    } catch (err) { setError(err.response?.data?.message || 'Gagal menyimpan'); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Hapus driver ini?')) return;
    try { await logisticsAPI.delete(`/drivers/${id}`); load(); }
    catch (err) { alert(err.response?.data?.message || 'Gagal menghapus'); }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">👤 Manajemen Driver</h1>
        <button className="btn btn-primary" onClick={openAdd}>+ Tambah Driver</button>
      </div>
      <div className="card">
        {loading ? <div className="loading">Memuat...</div> : (
          <table>
            <thead><tr><th>Nama</th><th>Telepon</th><th>No. SIM</th><th>Berlaku Sampai</th><th>Status</th><th>Aksi</th></tr></thead>
            <tbody>
              {data.length === 0 ? <tr><td colSpan={6} className="empty-state">Belum ada data driver</td></tr>
                : data.map(d => (
                  <tr key={d.id}>
                    <td><strong>{d.name}</strong></td>
                    <td>{d.phone}</td>
                    <td>{d.license_number}</td>
                    <td>{d.license_expiry ? new Date(d.license_expiry).toLocaleDateString('id-ID') : '-'}</td>
                    <td>{statusBadge(d.status)}</td>
                    <td>
                      <button className="btn btn-outline btn-sm" onClick={() => openEdit(d)} style={{ marginRight: 6 }}>✏️</button>
                      <button className="btn btn-danger btn-sm" onClick={() => handleDelete(d.id)}>🗑️</button>
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
              <h3 className="modal-title">{editing ? 'Edit' : 'Tambah'} Driver</h3>
              <button className="modal-close" onClick={() => setModal(false)}>×</button>
            </div>
            {error && <div className="alert alert-error">{error}</div>}
            <form onSubmit={handleSubmit}>
              {[['name','Nama Lengkap'],['phone','Nomor Telepon'],['license_number','Nomor SIM']].map(([k, l]) => (
                <div className="form-group" key={k}>
                  <label>{l}</label>
                  <input className="form-control" value={form[k] || ''} onChange={e => setForm({ ...form, [k]: e.target.value })} required={k === 'name'} />
                </div>
              ))}
              <div className="form-group">
                <label>Berlaku Sampai</label>
                <input className="form-control" type="date" value={form.license_expiry || ''} onChange={e => setForm({ ...form, license_expiry: e.target.value })} />
              </div>
              <div className="form-group">
                <label>Status</label>
                <select className="form-control" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                  {['available','on_trip','off','inactive'].map(s => <option key={s} value={s}>{s}</option>)}
                </select>
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
