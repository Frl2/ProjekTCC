# ==========================================================
# SCRIPT SETUP DATABASE CLOUD SQL - FLEETTRACK (V2 - FRESH)
# ==========================================================
# Script ini akan membuat instance database yang benar-benar baru.

$PROJECT_ID = gcloud config get-value project
$REGION = "asia-southeast2"
$INSTANCE_NAME = "fleettrack-db-v2" # Nama baru untuk menghindari konflik
$DB_USER = "fleettrack_user"
$DB_PASSWORD = "fleettrack123"

Write-Host "--- Memulai Konfigurasi Cloud SQL Baru ($INSTANCE_NAME) ---" -ForegroundColor Cyan

# 1. Aktifkan API
Write-Host "[1/6] Mengaktifkan Google Cloud APIs..." -ForegroundColor Yellow
gcloud services enable sqladmin.googleapis.com run.googleapis.com --quiet

# 2. Membuat Instance Baru
Write-Host "[2/6] Membuat Instance Cloud SQL Baru: $INSTANCE_NAME di $REGION..." -ForegroundColor Yellow
Write-Host "Proses ini memakan waktu sekitar 5-10 menit. Harap bersabar..." -ForegroundColor Gray

# Coba hapus jika sudah ada (opsional, tapi kita gunakan nama baru saja agar aman)
gcloud sql instances create $INSTANCE_NAME `
    --database-version=MYSQL_8_0 `
    --tier=db-f1-micro `
    --region=$REGION `
    --root-password=$DB_PASSWORD `
    --storage-type=HDD `
    --storage-size=10GB `
    --quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "Gagal membuat instance atau instance sudah ada. Mencoba mengambil detail..." -ForegroundColor Cyan
}

# Ambil Connection Name
Write-Host "Mengambil detail instance..." -ForegroundColor Yellow
$instanceDetail = gcloud sql instances describe $INSTANCE_NAME --format="json" | ConvertFrom-Json
$CLOUD_SQL_CONN = $instanceDetail.connectionName
$ACTUAL_REGION = $instanceDetail.region

Write-Host "Connection Name: $CLOUD_SQL_CONN" -ForegroundColor Green
Write-Host "Region: $ACTUAL_REGION" -ForegroundColor Green

# 3. Membuat Database
Write-Host "[3/6] Membuat Database (auth_db & logistics_db)..." -ForegroundColor Yellow
gcloud sql databases create auth_db --instance=$INSTANCE_NAME --quiet
gcloud sql databases create logistics_db --instance=$INSTANCE_NAME --quiet

# 4. Membuat User
Write-Host "[4/6] Membuat User Database ($DB_USER)..." -ForegroundColor Yellow
gcloud sql users create $DB_USER --instance=$INSTANCE_NAME --password=$DB_PASSWORD --quiet

# 5. Izin IAM
Write-Host "[5/6] Mengatur Izin IAM untuk Service Account..." -ForegroundColor Yellow
$PROJECT_NUMBER = gcloud projects list --filter="project_id=$PROJECT_ID" --format="value(project_number)"
$SA_EMAIL = "$PROJECT_NUMBER-compute@developer.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/cloudsql.client" --quiet

# 6. Update Cloud Run
Write-Host "[6/6] Menghubungkan Cloud Run ke Instance Baru..." -ForegroundColor Yellow
$DB_HOST = "/cloudsql/$CLOUD_SQL_CONN"

$SERVICES = @("fleettrack-auth-service", "fleettrack-logistics-service")

foreach ($svc in $SERVICES) {
    Write-Host "Updating service: $svc di region $ACTUAL_REGION..." -ForegroundColor Gray
    $DB_NAME = if ($svc -like "*auth*") { "auth_db" } else { "logistics_db" }
    
    gcloud run services update $svc `
        --region $ACTUAL_REGION `
        --add-cloudsql-instances $CLOUD_SQL_CONN `
        --update-env-vars "DB_HOST=$DB_HOST,DB_USER=$DB_USER,DB_PASSWORD=$DB_PASSWORD,DB_NAME=$DB_NAME" --quiet
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "INSTALASI DATABASE BARU SELESAI!" -ForegroundColor Green
Write-Host "Instance Name: $INSTANCE_NAME"
Write-Host "Connection Name: $CLOUD_SQL_CONN"
Write-Host "Region: $ACTUAL_REGION"
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Silakan tunggu 1 menit, lalu jalankan .\register-admin.ps1"
