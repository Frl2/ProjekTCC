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

# 🛠️ TAHAP 1: JALANKAN DI LOKAL

## Prasyarat
Install terlebih dahulu:
1. **Node.js** v18+ → https://nodejs.org
2. **Docker Desktop** → https://www.docker.com/products/docker-desktop
3. **VS Code** → https://code.visualstudio.com
4. **Git** (opsional)

Cek versi di PowerShell:
```powershell
node --version
npm --version
docker --version
docker compose version
```

## Jalankan Project

```powershell
# 1. Masuk ke folder project
cd D:\Kuliah\Semester6\PrakTCC\TugasAkhir\fleettrack

# 2. Jalankan semua service sekaligus
docker compose up --build

# Tunggu sampai semua service jalan (bisa 3-5 menit pertama kali)
```

## Akses di Browser
```
Frontend   : http://localhost:3000
Auth API   : http://localhost:5001/api/health
Logistics  : http://localhost:5002/api/health
```

---

# ☁️ TAHAP 2: DEPLOYMENT KE GOOGLE CLOUD PLATFORM

## Prasyarat GCP
- Akun Google Cloud dengan billing aktif
- Install **Google Cloud CLI** → https://cloud.google.com/sdk/docs/install

---

## LANGKAH 1 — Setup GCP Project

```powershell
# Login ke Google Cloud
gcloud auth login

# Buat project (atau pakai yang sudah ada)
# Ganti PROJECT_ID dengan ID project kamu
gcloud config set project fleettrack-tcc-XXXXX

# Cek project aktif
gcloud config get-value project
```

---

## LANGKAH 2 — Aktifkan API yang Dibutuhkan

```powershell
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

---

## LANGKAH 3 — Buat Cloud SQL MySQL

Di **GCP Console → SQL → Create Instance → MySQL**:
```
Instance ID : fleettrack-mysql
Password    : [buat password, simpan!]
Region      : asia-southeast2 (Jakarta)
Database    : MySQL 8.0
Machine     : db-f1-micro (paling hemat)
```

Setelah instance jadi, buat 2 database:
```
Cloud SQL → fleettrack-mysql → Databases → Create database
- auth_db
- logistics_db
```

---

## LANGKAH 4 — Import Schema dan Seed Database

Buka **Cloud SQL Studio** (dari Console → Cloud SQL → fleettrack-mysql → Cloud SQL Studio)

Untuk **auth_db**:
1. Pilih database: `auth_db`, User: `root`
2. Copy isi `auth-service/database/auth_schema.sql` → paste → Run
3. Copy isi `auth-service/database/auth_seed.sql` → paste → Run

Untuk **logistics_db**:
1. Pilih database: `logistics_db`
2. Copy isi `logistics-service/database/logistics_schema.sql` → paste → Run
3. Copy isi `logistics-service/database/logistics_seed.sql` → paste → Run

---

## LANGKAH 5 — Buat Artifact Registry

```powershell
gcloud artifacts repositories create fleettrack-repo `
  --repository-format=docker `
  --location=asia-southeast2 `
  --description="FleetTrack Docker images"

# Auth Docker ke Artifact Registry
gcloud auth configure-docker asia-southeast2-docker.pkg.dev
```

---

## LANGKAH 6 — Build & Push Image Auth Service

```powershell
# Set variabel (ganti PROJECT_ID_KAMU)
$PROJECT_ID = "fleettrack-tcc-XXXXX"
$REGION = "asia-southeast2"
$REGISTRY = "$REGION-docker.pkg.dev/$PROJECT_ID/fleettrack-repo"

# Build & push auth-service
cd auth-service
docker build -t "$REGISTRY/auth-service:latest" .
docker push "$REGISTRY/auth-service:latest"
cd ..
```

---

## LANGKAH 7 — Build & Push Image Logistics Service

```powershell
cd logistics-service
docker build -t "$REGISTRY/logistics-service:latest" .
docker push "$REGISTRY/logistics-service:latest"
cd ..
```

---

## LANGKAH 8 — Deploy Auth Service ke Cloud Run

```powershell
$CLOUD_SQL_CONN = "$PROJECT_ID:$REGION:fleettrack-mysql"

gcloud run deploy fleettrack-auth-service `
  --image "$REGISTRY/auth-service:latest" `
  --region $REGION `
  --platform managed `
  --allow-unauthenticated `
  --add-cloudsql-instances $CLOUD_SQL_CONN `
  --set-env-vars "PORT=5001,DB_HOST=/cloudsql/$CLOUD_SQL_CONN,DB_USER=root,DB_PASSWORD=PASSWORD_ROOT_KAMU,DB_NAME=auth_db,JWT_SECRET=fleettrack_jwt_secret_key_2024,JWT_EXPIRES_IN=24h"
```

Simpan URL yang muncul, contoh:
```
https://fleettrack-auth-service-XXXXX.a.run.app
```

---

## LANGKAH 9 — Deploy Logistics Service ke Cloud Run

```powershell
gcloud run deploy fleettrack-logistics-service `
  --image "$REGISTRY/logistics-service:latest" `
  --region $REGION `
  --platform managed `
  --allow-unauthenticated `
  --add-cloudsql-instances $CLOUD_SQL_CONN `
  --set-env-vars "PORT=5002,DB_HOST=/cloudsql/$CLOUD_SQL_CONN,DB_USER=root,DB_PASSWORD=PASSWORD_ROOT_KAMU,DB_NAME=logistics_db,JWT_SECRET=fleettrack_jwt_secret_key_2024"
```

---

## LANGKAH 10 — Build & Deploy Frontend

Edit file `.env.production` di folder `frontend-service`:
```env
VITE_AUTH_API_URL=https://URL_AUTH_SERVICE_KAMU/api
VITE_LOGISTICS_API_URL=https://URL_LOGISTICS_SERVICE_KAMU/api
```

Build dan push:
```powershell
cd frontend-service
docker build -t "$REGISTRY/frontend-service:latest" .
docker push "$REGISTRY/frontend-service:latest"
cd ..
```

Deploy:
```powershell
$AUTH_URL = "https://fleettrack-auth-service-XXXXX.a.run.app/api"
$LOGISTICS_URL = "https://fleettrack-logistics-service-XXXXX.a.run.app/api"

gcloud run deploy fleettrack-frontend-service `
  --image "$REGISTRY/frontend-service:latest" `
  --region $REGION `
  --platform managed `
  --allow-unauthenticated `
  --set-env-vars "VITE_AUTH_API_URL=$AUTH_URL,VITE_LOGISTICS_API_URL=$LOGISTICS_URL"
```

---

## LANGKAH 11 — Test Aplikasi

### Test Health Check
```
https://fleettrack-auth-service-XXXXX.a.run.app/api/health
https://fleettrack-logistics-service-XXXXX.a.run.app/api/health
```

### Test Login di Postman
```
POST https://fleettrack-auth-service-XXXXX.a.run.app/api/auth/login
Content-Type: application/json

{
  "email": "admin@fleettrack.com",
  "password": "admin123"
}
```
Simpan token dari response.

### Test Vehicles
```
GET https://fleettrack-logistics-service-XXXXX.a.run.app/api/vehicles
Authorization: Bearer [TOKEN_DARI_LOGIN]
```

### Buka Aplikasi Frontend
```
https://fleettrack-frontend-service-XXXXX.a.run.app
```

---

## 🧹 LANGKAH 12 — Matikan Resource (Setelah Selesai)

Penting agar tidak kena biaya GCP berlebihan:

```powershell
# Hapus Cloud Run services
gcloud run services delete fleettrack-auth-service --region $REGION
gcloud run services delete fleettrack-logistics-service --region $REGION
gcloud run services delete fleettrack-frontend-service --region $REGION

# Hapus Cloud SQL instance
gcloud sql instances delete fleettrack-mysql
```

---

# 📸 SCREENSHOT UNTUK LAPORAN

1. Struktur folder project di VS Code
2. `docker compose up --build` berhasil
3. Halaman login FleetTrack
4. Dashboard
5. Halaman CRUD Armada (tambah, edit, hapus)
6. Halaman CRUD Driver
7. Halaman CRUD Shipment
8. Form update tracking lokasi
9. Detail pengiriman + riwayat tracking
10. Cloud SQL instance di GCP Console
11. Tabel `auth_db` di Cloud SQL Studio
12. Tabel `logistics_db` di Cloud SQL Studio
13. Artifact Registry berisi 3 image Docker
14. Cloud Run — fleettrack-auth-service (status Running)
15. Cloud Run — fleettrack-logistics-service (status Running)
16. Cloud Run — fleettrack-frontend-service (status Running)
17. Postman: POST login → dapat JWT token
18. Postman: GET vehicles dengan Bearer token

---

# 👥 PEMBAGIAN KERJA 4 ORANG

| Anggota | Tanggung Jawab |
|---------|----------------|
| Orang 1 — Frontend Dev | Login page, Dashboard, semua halaman CRUD, integrasi API |
| Orang 2 — Auth Backend | auth-service, JWT, user management, middleware |
| Orang 3 — Logistics Backend | logistics-service, CRUD armada/driver/rute/shipment, tracking |
| Orang 4 — Cloud + Docs | Docker, GCP, Cloud SQL, Cloud Run, Artifact Registry, laporan |

---

# 📅 TIMELINE 5 HARI

| Hari | Orang 1 | Orang 2 | Orang 3 | Orang 4 |
|------|---------|---------|---------|---------|
| Hari 1 | Setup Vite, layout, login | Setup auth-service, schema | Setup logistics-service, schema | Setup Docker, GCP project |
| Hari 2 | Dashboard, template tabel | Endpoint login, register, users | Endpoint vehicles, drivers, warehouses | Test lokal, import seed |
| Hari 3 | Integrasi API frontend | Middleware JWT & role | Endpoint shipments, tracking | Test endpoint Postman |
| Hari 4 | Rapikan UI | Deploy auth ke Cloud Run | Deploy logistics ke Cloud Run | Cloud SQL, Artifact Registry |
| Hari 5 | Screenshot frontend | Screenshot Postman auth | Screenshot Postman logistics | Susun laporan akhir |
