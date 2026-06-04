import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const navItems = [
  { to: '/dashboard', icon: '📊', label: 'Dashboard' },
  { to: '/vehicles', icon: '🚛', label: 'Armada' },
  { to: '/drivers', icon: '👤', label: 'Driver' },
  { to: '/warehouses', icon: '🏭', label: 'Gudang' },
  { to: '/routes', icon: '🗺️', label: 'Rute' },
  { to: '/shipments', icon: '📦', label: 'Pengiriman' },
];

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => { logout(); navigate('/login'); };

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <aside style={{ width: 240, background: '#1e293b', color: 'white', display: 'flex', flexDirection: 'column', position: 'fixed', top: 0, left: 0, height: '100vh', zIndex: 100 }}>
        <div style={{ padding: '24px 20px', borderBottom: '1px solid #334155' }}>
          <div style={{ fontSize: 22, fontWeight: 700 }}>🚚 FleetTrack</div>
          <div style={{ fontSize: 12, color: '#94a3b8', marginTop: 4 }}>Sistem Tracking Armada</div>
        </div>
        <nav style={{ flex: 1, padding: '16px 0' }}>
          {navItems.map(item => (
            <NavLink
              key={item.to}
              to={item.to}
              style={({ isActive }) => ({
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '12px 20px', fontSize: 14, fontWeight: 500,
                color: isActive ? 'white' : '#94a3b8',
                background: isActive ? '#1a56db' : 'transparent',
                transition: 'all 0.2s', borderRadius: '0 6px 6px 0', marginRight: 8
              })}
            >
              <span>{item.icon}</span> {item.label}
            </NavLink>
          ))}
        </nav>
        <div style={{ padding: '16px 20px', borderTop: '1px solid #334155' }}>
          <div style={{ fontSize: 13, color: '#94a3b8', marginBottom: 4 }}>{user?.name}</div>
          <div style={{ fontSize: 11, color: '#64748b', marginBottom: 12 }}>{user?.email}</div>
          <button onClick={handleLogout} className="btn btn-outline" style={{ width: '100%', color: '#94a3b8', borderColor: '#334155', fontSize: 13 }}>
            🚪 Logout
          </button>
        </div>
      </aside>
      <main style={{ marginLeft: 240, flex: 1, padding: 24, minHeight: '100vh' }}>
        <Outlet />
      </main>
    </div>
  );
}
