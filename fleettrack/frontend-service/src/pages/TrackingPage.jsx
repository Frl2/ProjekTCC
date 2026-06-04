import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { logisticsAPI } from '../services/api';

const statusBadge = (s) => {
  const m = { PENDING: 'badge-warning', PICKED_UP: 'badge-info', ON_DELIVERY: 'badge-info',
    ARRIVED_AT_WAREHOUSE: 'badge-info', DELIVERED: 'badge-success', CANCELLED: 'badge-danger' };
  return <span className={`badge ${m[s] || 'badge-gray'}`}>{s?.replace(/_/g,' ')}</span>;
};

export default function TrackingPage() {
  const { tracking_number } = useParams();
  const [query, setQuery] = useState(tracking_number || '');
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleTrack = async (e) => {
    e?.preventDefault();
    if (!query.trim()) return;
    setLoading(true); setError(''); setResult(null);
    try {
      const res = await logisticsAPI.get(`/shipments/track/${query.trim()}`);
      setResult(res.data.data);
    } catch {
      setError('Nomor resi tidak ditemukan. Periksa kembali nomor resi Anda.');
    } finally { setLoading(false); }
  };

  useEffect(() => { if (tracking_number) handleTrack(); }, []);

  return (
    <div style={{ minHeight: '100vh', background: '#f0f2f5', padding: '40px 20px' }}>
      <div style={{ maxWidth: 700, margin: '0 auto' }}>
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <div style={{ fontSize: 48, marginBottom: 8 }}>🚚</div>
          <h1 style={{ fontSize: 28, fontWeight: 700, color: '#1e293b' }}>FleetTrack</h1>
          <p style={{ color: '#6b7280' }}>Lacak status pengiriman Anda</p>
        </div>

        <div className="card" style={{ marginBottom: 24 }}>
          <form onSubmit={handleTrack} style={{ display: 'flex', gap: 12 }}>
            <input
              className="form-control"
              value={query}
              onChange={e => setQuery(e.target.value)}
              placeholder="Masukkan nomor resi (contoh: FT-12345678-ABCD)"
              style={{ flex: 1 }}
            />
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Mencari...' : '🔍 Lacak'}
            </button>
          </form>
        </div>

        {error && <div className="alert alert-error">{error}</div>}

        {result && (
          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20, flexWrap: 'wrap', gap: 12 }}>
              <div>
                <h2 style={{ fontSize: 18, fontWeight: 700, marginBottom: 4 }}>Detail Pengiriman</h2>
                <code style={{ background: '#f3f4f6', padding: '4px 10px', borderRadius: 6, fontSize: 14 }}>{result.tracking_number}</code>
              </div>
              <div style={{ fontSize: 20 }}>{statusBadge(result.status)}</div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24, padding: 16, background: '#f8fafc', borderRadius: 8 }}>
              {[
                ['📍 Asal', `${result.origin_name} (${result.origin_city})`],
                ['🏁 Tujuan', `${result.dest_name} (${result.dest_city})`],
                ['📤 Pengirim', result.sender_name],
                ['📥 Penerima', result.receiver_name],
                ['📞 Telepon Penerima', result.receiver_phone],
                ['⚖️ Berat', result.weight_kg ? `${result.weight_kg} kg` : '-'],
              ].map(([label, value]) => (
                <div key={label}>
                  <div style={{ fontSize: 12, color: '#6b7280' }}>{label}</div>
                  <div style={{ fontWeight: 500, fontSize: 14 }}>{value || '-'}</div>
                </div>
              ))}
            </div>

            <h3 style={{ fontSize: 15, fontWeight: 600, marginBottom: 16, color: '#374151' }}>📋 Riwayat Perjalanan</h3>
            <div style={{ borderLeft: '3px solid #1a56db', paddingLeft: 20 }}>
              {result.tracking_logs?.map((log, i) => (
                <div key={i} style={{ marginBottom: 16, position: 'relative' }}>
                  <div style={{ position: 'absolute', left: -26, top: 2, width: 12, height: 12, background: i === result.tracking_logs.length - 1 ? '#1a56db' : '#94a3b8', borderRadius: '50%', border: '2px solid white' }} />
                  <div style={{ fontWeight: 600, color: '#1e293b', fontSize: 14 }}>{log.status?.replace(/_/g,' ')}</div>
                  {log.location && <div style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>📍 {log.location}</div>}
                  {log.notes && <div style={{ fontSize: 13, color: '#6b7280' }}>{log.notes}</div>}
                  <div style={{ fontSize: 12, color: '#9ca3af', marginTop: 2 }}>{new Date(log.created_at).toLocaleString('id-ID')}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        <div style={{ textAlign: 'center', marginTop: 24 }}>
          <a href="/login" style={{ color: '#1a56db', fontSize: 13 }}>Masuk ke sistem admin →</a>
        </div>
      </div>
    </div>
  );
}
