import { useState, useEffect } from 'react';
import { logisticsAPI } from '../services/api';

const STATUSES = ['PENDING','PICKED_UP','ON_DELIVERY','ARRIVED_AT_WAREHOUSE','DELIVERED','CANCELLED'];

const statusBadge = (s) => {
  const m = { PENDING: 'badge-warning', PICKED_UP: 'badge-info', ON_DELIVERY: 'badge-info',
    ARRIVED_AT_WAREHOUSE: 'badge-info', DELIVERED: 'badge-success', CANCELLED: 'badge-danger' };
  return <span className={`badge ${m[s] || 'badge-gray'}`}>{s?.replace(/_/g,' ')}</span>;
};

const EMPTY = { route_id: '', vehicle_id: '', driver_id: '', sender_name: '', receiver_name: '', receiver_phone: '', receiver_address: '', weight_kg: '', description: '', scheduled_date: '' };

export default function ShipmentsPage() {
  const [data, setData] = useState([]);
  const [routes, setRoutes] = useState([]);
  const [vehicles, setVehicles] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(false);
  const [detailModal, setDetailModal] = useState(null);
  const [statusModal, setStatusModal] = useState(null);
  const [form, setForm] = useState(EMPTY);
  const [statusForm, setStatusForm] = useState({ status: '', location: '', notes: '' });
  const [error, setError] = useState('');

  const load = async () => {
    setLoading(true);
    const [s, r, v, d] = await Promise.all([
      logisticsAPI.get('/shipments'), logisticsAPI.get('/routes'),
      logisticsAPI.get('/vehicles'), logisticsAPI.get('/drivers')
    ]);
    setData(s.data.data); setRoutes(r.data.data);
    setVehicles(v.data.data); setDrivers(d.data.data);
    setLoading(false);
  };
  useEffect(() => { load(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault(); setError('');
    try {
      await logisticsAPI.post('/shipments', form);
      setModal(false); load();
    } catch (err) { setError(err.response?.data?.message || 'Gagal membuat pengiriman'); }
  };

  const openDetail = async (id) => {
    const res = await logisticsAPI.get(`/shipments/${id}`);
    setDetailModal(res.data.data);
  };

  const handleStatusUpdate = async (e) => {
    e.preventDefault(); setError('');
    try {
      await logisticsAPI.put(`/shipments/${statusModal.id}/status`, statusForm);
      setStatusModal(null); load();
    } catch (err) { setError(err.response?.data?.message || 'Gagal update status'); }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">📦 Manajemen Pengiriman</h1>
        <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setError(''); setModal(true); }}>+ Buat Pengiriman</button>
      </div>
      <div className="card">
        {loading ? <div className="loading">Memuat...</div> : (
          <table>
            <thead><tr><th>No. Resi</th><th>Pengirim</th><th>Penerima</th><th>Rute</th><th>Driver</th><th>Status</th><th>Aksi</th></tr></thead>
            <tbody>
              {data.length === 0 ? <tr><td colSpan={7} className="empty-state">Belum ada pengiriman</td></tr>
                : data.map(s => (
                  <tr key={s.id}>
                    <td><code style={{ fontSize: 11, background: '#f3f4f6', padding: '2px 5px', borderRadius: 3 }}>{s.tracking_number}</code></td>
                    <td>{s.sender_name}</td>
                    <td>{s.receiver_name}</td>
                    <td style={{ fontSize: 12 }}>{s.origin_city} → {s.dest_city}</td>
                    <td style={{ fontSize: 12 }}>{s.driver_name || '-'}</td>
                    <td>{statusBadge(s.status)}</td>
                    <td style={{ whiteSpace: 'nowrap' }}>
                      <button className="btn btn-outline btn-sm" style={{ marginRight: 4 }} onClick={() => openDetail(s.id)}>👁️</button>
                      <button className="btn btn-success btn-sm" style={{ marginRight: 4 }} onClick={() => { setStatusModal(s); setStatusForm({ status: s.status, location: '', notes: '' }); setError(''); }}>📍</button>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Create Modal */}
      {modal && (
        <div className="modal-overlay" onClick={() => setModal(false)}>
          <div className="modal" style={{ maxWidth: 600 }} onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Buat Pengiriman Baru</h3>
              <button className="modal-close" onClick={() => setModal(false)}>×</button>
            </div>
            {error && <div className="alert alert-error">{error}</div>}
            <form onSubmit={handleCreate}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                <div className="form-group">
                  <label>Rute</label>
                  <select className="form-control" value={form.route_id} onChange={e => setForm({ ...form, route_id: e.target.value })} required>
                    <option value="">-- Pilih Rute --</option>
                    {routes.map(r => <option key={r.id} value={r.id}>{r.origin_city} → {r.destination_city}</option>)}
                  </select>
                </div>
                <div className="form-group">
                  <label>Kendaraan</label>
                  <select className="form-control" value={form.vehicle_id} onChange={e => setForm({ ...form, vehicle_id: e.target.value })}>
                    <option value="">-- Pilih Kendaraan --</option>
                    {vehicles.filter(v => v.status === 'available').map(v => <option key={v.id} value={v.id}>{v.license_plate} - {v.type}</option>)}
                  </select>
                </div>
                <div className="form-group">
                  <label>Driver</label>
                  <select className="form-control" value={form.driver_id} onChange={e => setForm({ ...form, driver_id: e.target.value })}>
                    <option value="">-- Pilih Driver --</option>
                    {drivers.filter(d => d.status === 'available').map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                  </select>
                </div>
                <div className="form-group">
                  <label>Tanggal Jadwal</label>
                  <input className="form-control" type="date" value={form.scheduled_date} onChange={e => setForm({ ...form, scheduled_date: e.target.value })} />
                </div>
                {[['sender_name','Nama Pengirim'],['receiver_name','Nama Penerima'],['receiver_phone','Telepon Penerima'],['weight_kg','Berat (kg)']].map(([k, l]) => (
                  <div className="form-group" key={k}>
                    <label>{l}</label>
                    <input className="form-control" value={form[k]} onChange={e => setForm({ ...form, [k]: e.target.value })} required={['sender_name','receiver_name'].includes(k)} />
                  </div>
                ))}
              </div>
              <div className="form-group">
                <label>Alamat Penerima</label>
                <input className="form-control" value={form.receiver_address} onChange={e => setForm({ ...form, receiver_address: e.target.value })} />
              </div>
              <div className="form-group">
                <label>Deskripsi Barang</label>
                <textarea className="form-control" value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} rows={2} />
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-outline" onClick={() => setModal(false)}>Batal</button>
                <button type="submit" className="btn btn-primary">Buat Pengiriman</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Detail Modal */}
      {detailModal && (
        <div className="modal-overlay" onClick={() => setDetailModal(null)}>
          <div className="modal" style={{ maxWidth: 600 }} onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Detail Pengiriman</h3>
              <button className="modal-close" onClick={() => setDetailModal(null)}>×</button>
            </div>
            <div style={{ marginBottom: 16 }}>
              <p><strong>No. Resi:</strong> <code>{detailModal.tracking_number}</code></p>
              <p><strong>Status:</strong> {statusBadge(detailModal.status)}</p>
              <p><strong>Rute:</strong> {detailModal.origin_city} → {detailModal.dest_city}</p>
              <p><strong>Driver:</strong> {detailModal.driver_name || '-'}</p>
              <p><strong>Kendaraan:</strong> {detailModal.license_plate || '-'}</p>
            </div>
            <h4 style={{ marginBottom: 12, fontSize: 14, color: '#6b7280' }}>RIWAYAT TRACKING</h4>
            <div style={{ borderLeft: '2px solid #e5e7eb', paddingLeft: 16 }}>
              {detailModal.tracking_logs?.map((log, i) => (
                <div key={i} style={{ marginBottom: 12, position: 'relative' }}>
                  <div style={{ position: 'absolute', left: -22, top: 4, width: 10, height: 10, background: '#1a56db', borderRadius: '50%' }} />
                  <div style={{ fontWeight: 600, fontSize: 13 }}>{log.status?.replace(/_/g, ' ')}</div>
                  {log.location && <div style={{ fontSize: 12, color: '#6b7280' }}>📍 {log.location}</div>}
                  {log.notes && <div style={{ fontSize: 12, color: '#6b7280' }}>{log.notes}</div>}
                  <div style={{ fontSize: 11, color: '#9ca3af' }}>{new Date(log.created_at).toLocaleString('id-ID')}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Status Update Modal */}
      {statusModal && (
        <div className="modal-overlay" onClick={() => setStatusModal(null)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Update Status Pengiriman</h3>
              <button className="modal-close" onClick={() => setStatusModal(null)}>×</button>
            </div>
            <p style={{ fontSize: 13, color: '#6b7280', marginBottom: 16 }}>Resi: <code>{statusModal.tracking_number}</code></p>
            {error && <div className="alert alert-error">{error}</div>}
            <form onSubmit={handleStatusUpdate}>
              <div className="form-group">
                <label>Status Baru</label>
                <select className="form-control" value={statusForm.status} onChange={e => setStatusForm({ ...statusForm, status: e.target.value })} required>
                  <option value="">-- Pilih Status --</option>
                  {STATUSES.map(s => <option key={s} value={s}>{s.replace(/_/g, ' ')}</option>)}
                </select>
              </div>
              <div className="form-group">
                <label>Lokasi Saat Ini</label>
                <input className="form-control" value={statusForm.location} onChange={e => setStatusForm({ ...statusForm, location: e.target.value })} placeholder="Contoh: Tol Cipularang KM 100" />
              </div>
              <div className="form-group">
                <label>Catatan</label>
                <textarea className="form-control" value={statusForm.notes} onChange={e => setStatusForm({ ...statusForm, notes: e.target.value })} rows={2} />
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-outline" onClick={() => setStatusModal(null)}>Batal</button>
                <button type="submit" className="btn btn-primary">Update Status</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
