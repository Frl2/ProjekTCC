$AUTH_SERVICE_URL = "https://fleettrack-auth-service-985858089421.asia-southeast2.run.app"
$REGISTER_URL = "$AUTH_SERVICE_URL/api/auth/register"

$userData = @{
    name = "Administrator"
    email = "admin@fleettrack.com"
    password = "admin123"
    role = "admin"
} | ConvertTo-Json

Write-Host "--- Mencoba mendaftarkan user Admin ke: $REGISTER_URL ---" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $REGISTER_URL -Method Post -Body $userData -ContentType "application/json"
    Write-Host "BERHASIL!" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "GAGAL!" -ForegroundColor Red
    $errorMessage = $_.Exception.Message
    Write-Host "Error: $errorMessage"
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Host "Detail: $body"
    }
}

Write-Host "`n--- SELESAI ---"
Write-Host "Jika berhasil atau muncul 'Email sudah terdaftar', silakan coba login di website."
