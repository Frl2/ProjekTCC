$PROJECT_ID = "e-42-498310"
$REGION = "asia-southeast2"
$DB_USER = "fleettrack_user"
$DB_PASSWORD = "fleettrack123"
$CLOUD_SQL_CONN = "e-42-498310:asia-southeast2:fleettrack-mysql"
$DB_HOST_CLOUDRUN = "/cloudsql/$CLOUD_SQL_CONN"

Write-Host "--- 1. Membuat User Database Baru (fleettrack_user) ---" -ForegroundColor Cyan
# Buat user baru di Cloud SQL
gcloud sql users create $DB_USER --instance=fleettrack-mysql --password=$DB_PASSWORD

Write-Host "--- 2. Mengupdate Izin IAM ---" -ForegroundColor Cyan
$PROJECT_NUMBER = gcloud projects list --filter="project_id=$PROJECT_ID" --format="value(project_number)"
$SA_EMAIL = "$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/cloudsql.client"

Write-Host "--- 3. Mengupdate Environment Variables Service ---" -ForegroundColor Cyan
gcloud run services update fleettrack-auth-service `
  --region $REGION `
  --add-cloudsql-instances $CLOUD_SQL_CONN `
  --update-env-vars "DB_HOST=$DB_HOST_CLOUDRUN,DB_USER=$DB_USER,DB_PASSWORD=$DB_PASSWORD,DB_NAME=auth_db"

gcloud run services update fleettrack-logistics-service `
  --region $REGION `
  --add-cloudsql-instances $CLOUD_SQL_CONN `
  --update-env-vars "DB_HOST=$DB_HOST_CLOUDRUN,DB_USER=$DB_USER,DB_PASSWORD=$DB_PASSWORD,DB_NAME=logistics_db"

Write-Host "--- PERBAIKAN SELESAI ---" -ForegroundColor Green
Write-Host "Silakan jalankan ulang .\register-admin.ps1" -ForegroundColor White
