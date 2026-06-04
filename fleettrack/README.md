# 🚚 FleetTrack — Sistem Tracking Armada Logistik TCC

Sistem manajemen dan tracking armada logistik berbasis **microservices** menggunakan:
- **Frontend**: React.js + Vite
- **Auth Service**: Node.js + Express + MySQL
- **Logistics Service**: Node.js + Express + MySQL
- **Database**: MySQL 8 (lokal: Docker, cloud: Google Cloud SQL)
- **Deployment**: Google Cloud Run + Artifact Registry

---

## 📁 STRUKTUR FOLDER

```
fleettrack/
├── docker-compose.yml           ← Jalankan lokal
├── auth-service/
│   ├── Dockerfile
│   ├── package.json
│   ├── database/
│   │   ├── auth_schema.sql      ← Struktur tabel
│   │   └── auth_seed.sql        ← Data awal
│   └── src/
│       ├── index.js
│       ├── config/database.js
│       ├── middleware/auth.js
│       ├── controllers/authController.js
│       └── routes/authRoutes.js
├── logistics-service/
│   ├── Dockerfile
│   ├── package.json
│   ├── database/
│   │   ├── logistics_schema.sql
│   │   └── logistics_seed.sql
│   └── src/
│       ├── index.js
│       ├── config/database.js
│       ├── middleware/auth.js
│       ├── controllers/
│       │   ├── logisticsController.js
│       │   └── shipmentController.js
│       └── routes/logisticsRoutes.js
├── mobile-service/              ← Aplikasi Flutter (Mobile)
│   ├── Dockerfile
│   ├── .env                     ← Config API
│   └── lib/
└── frontend-service/
    ├── Dockerfile
    ├── nginx.conf
    ├── vite.config.js
    ├── index.html
    └── src/
        ├── App.jsx
        ├── main.jsx
        ├── index.css
        ├── context/AuthContext.jsx
        ├── services/api.js
        ├── components/Layout.jsx
        └── pages/
            ├── LoginPage.jsx
            ├── Dashboard.jsx
            ├── VehiclesPage.jsx
            ├── DriversPage.jsx
            ├── WarehousesPage.jsx
            ├── RoutesPage.jsx
            ├── ShipmentsPage.jsx
            └── TrackingPage.jsx
```

---

## 🔑 LOGIN DEFAULT

```
Email    : admin@fleettrack.com
Password : admin123
```

---

## 📋 API ENDPOINTS

### Auth Service (PORT 5001)
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | /api/health | Health check |
| POST | /api/auth/register | Daftar user |
| POST | /api/auth/login | Login, dapat JWT token |
| GET | /api/auth/me | Info user saat ini |
| POST | /api/auth/logout | Logout |
| GET | /api/users | Daftar semua user (admin) |
| PUT | /api/users/:id | Update user |
| DELETE | /api/users/:id | Hapus user |

### Logistics Service (PORT 5002)
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | /api/health | Health check |
| GET | /api/dashboard/stats | Statistik dashboard |
| GET | /api/vehicles | Daftar kendaraan |
| POST | /api/vehicles | Tambah kendaraan |
| PUT | /api/vehicles/:id | Update kendaraan |
| DELETE | /api/vehicles/:id | Hapus kendaraan |
| GET | /api/drivers | Daftar driver |
| POST | /api/drivers | Tambah driver |
| PUT | /api/drivers/:id | Update driver |
| DELETE | /api/drivers/:id | Hapus driver |
| GET | /api/warehouses | Daftar gudang |
| POST | /api/warehouses | Tambah gudang |
| GET | /api/routes | Daftar rute |
| POST | /api/routes | Tambah rute |
| GET | /api/shipments | Daftar pengiriman |
| GET | /api/shipments/:id | Detail + tracking log |
| POST | /api/shipments | Buat pengiriman |
| PUT | /api/shipments/:id/status | Update status tracking |
| GET | /api/shipments/track/:no | Lacak tanpa login |

---

## Akses di Browser
```
Frontend   : http://localhost:3000
Mobile Web : http://localhost:8080 (Jika dijalankan lokal)
Auth API   : http://localhost:5001/api/health
Logistics  : http://localhost:5002/api/health
```
---
