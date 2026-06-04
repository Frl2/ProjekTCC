import axios from 'axios';

const AUTH_URL = import.meta.env.VITE_AUTH_API_URL || 'http://localhost:5001/api';
const LOGISTICS_URL = import.meta.env.VITE_LOGISTICS_API_URL || 'http://localhost:5002/api';

const getToken = () => localStorage.getItem('fleettrack_token');

const authAPI = axios.create({ baseURL: AUTH_URL });
const logisticsAPI = axios.create({ baseURL: LOGISTICS_URL });

[authAPI, logisticsAPI].forEach(api => {
  api.interceptors.request.use(config => {
    const token = getToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  });
  api.interceptors.response.use(
    res => res,
    err => {
      if (err.response?.status === 401) {
        localStorage.removeItem('fleettrack_token');
        localStorage.removeItem('fleettrack_user');
        window.location.href = '/login';
      }
      return Promise.reject(err);
    }
  );
});

export { authAPI, logisticsAPI };