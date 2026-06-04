$PROJECT_ID = "e-42-498310"
$REGION = "asia-southeast2"
$REPO = "fleettrack-repo"
$DB_PASSWORD = "admin123"
$CLOUD_SQL_CONN = "e-42-498310:us-central1:fleettrack-mysql"

# PENTING: Untuk Cloud Run, DB_HOST harus diarahkan ke Unix Socket
$DB_HOST_CLOUDRUN = "/cloudsql/$CLOUD_SQL_CONN"

# Siapkan teks environment
$AUTH_ENV = "DB_HOST=$DB_HOST_CLOUDRUN,DB_USER=root,DB_PASSWORD=$DB_PASSWORD,DB_NAME=auth_db,JWT_SECRET=fleettrack_jwt_secret_key_2024,JWT_EXPIRES_IN=24h"
$LOG_ENV = "DB_HOST=$DB_HOST_CLOUDRUN,DB_USER=root,DB_PASSWORD=$DB_PASSWORD,DB_NAME=logistics_db,JWT_SECRET=fleettrack_jwt_secret_key_2024"

Write-Host "--- 1. Mendeploy Auth Service ---" -ForegroundColor Cyan
cd auth-service
gcloud builds submit --tag "asia-southeast2-docker.pkg.dev/$PROJECT_ID/$REPO/auth-service:latest" .
gcloud run deploy fleettrack-auth-service --image "asia-southeast2-docker.pkg.dev/$PROJECT_ID/$REPO/auth-service:latest" --region $REGION --platform managed --allow-unauthenticated --add-cloudsql-instances $CLOUD_SQL_CONN --set-env-vars $AUTH_ENV
cd ..

Write-Host "--- 2. Mendeploy Logistics Service ---" -ForegroundColor Cyan
cd logistics-service
gcloud builds submit --tag "asia-southeast2-docker.pkg.dev/$PROJECT_ID/$REPO/logistics-service:latest" .
gcloud run deploy fleettrack-logistics-service --image "asia-southeast2-docker.pkg.dev/$PROJECT_ID/$REPO/logistics-service:latest" --region $REGION --platform managed --allow-unauthenticated --add-cloudsql-instances $CLOUD_SQL_CONN --set-env-vars $LOG_ENV
cd ..

Write-Host "--- SEMUA BERHASIL DIDEPLOY ULANG ---" -ForegroundColor Green
