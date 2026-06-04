import { createContext, useContext, useState, useEffect } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const stored = localStorage.getItem('fleettrack_user');
    const token = localStorage.getItem('fleettrack_token');
    if (stored && token) setUser(JSON.parse(stored));
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    const res = await authAPI.post('/auth/login', { email, password });
    const { token, user } = res.data.data;
    localStorage.setItem('fleettrack_token', token);
    localStorage.setItem('fleettrack_user', JSON.stringify(user));
    setUser(user);
    return user;
  };

  const logout = () => {
    authAPI.post('/auth/logout').catch(() => {});
    localStorage.removeItem('fleettrack_token');
    localStorage.removeItem('fleettrack_user');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
