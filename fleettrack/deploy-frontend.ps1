# Script Hardcoded untuk menghindari error variabel
Write-Host "--- Memulai Build Frontend di Cloud Build ---" -ForegroundColor Cyan
cd frontend-service

# Langsung pakai teks asli agar tidak ada error parsing variabel
gcloud builds submit --tag asia-southeast2-docker.pkg.dev/e-42-498310/fleettrack-repo/frontend-service:latest .

Write-Host "--- Mendeploy Frontend ke Cloud Run (Port 8080) ---" -ForegroundColor Cyan
$AUTH_API = "https://fleettrack-auth-service-njyegk5lcq-et.a.run.app/api"
$LOG_API = "https://fleettrack-logistics-service-njyegk5lcq-et.a.run.app/api"

gcloud run deploy fleettrack-frontend-service `
  --image asia-southeast2-docker.pkg.dev/e-42-498310/fleettrack-repo/frontend-service:latest `
  --region asia-southeast2 `
  --platform managed `
  --allow-unauthenticated `
  --port 8080 `
  --set-env-vars "VITE_AUTH_API_URL=$AUTH_API,VITE_LOGISTICS_API_URL=$LOG_API"

Write-Host "--- SELESAI ---" -ForegroundColor Green
cd ..
