# Script Deployment untuk Mobile Service (Flutter Web)
Write-Host "--- Memulai Build Mobile Service di Cloud Build ---" -ForegroundColor Cyan
cd mobile-service

$PROJECT_ID = "e-42-498310"
$REGION = "asia-southeast2"
$REPO = "fleettrack-repo"

# Jalankan Cloud Build untuk build image Docker
gcloud builds submit --tag "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/mobile-service:latest" .

Write-Host "--- Mendeploy Mobile Service ke Cloud Run ---" -ForegroundColor Cyan

gcloud run deploy fleettrack-mobile-service `
  --image "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/mobile-service:latest" `
  --region $REGION `
  --platform managed `
  --allow-unauthenticated `
  --port 8080

Write-Host "--- SELESAI ---" -ForegroundColor Green
cd ..
