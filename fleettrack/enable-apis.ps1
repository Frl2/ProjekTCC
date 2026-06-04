Write-Host "--- Mengaktifkan Google Cloud APIs ---" -ForegroundColor Cyan

# Daftar API yang dibutuhkan
$APIS = @(
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
)

foreach ($api in $APIS) {
    Write-Host "Mengaktifkan $api..." -ForegroundColor Yellow
    gcloud services enable $api
}

Write-Host "--- SEMUA API BERHASIL DIAKTIFKAN ---" -ForegroundColor Green
Write-Host "Sekarang silakan coba buka kembali Cloud SQL Studio di GCP Console." -ForegroundColor White
