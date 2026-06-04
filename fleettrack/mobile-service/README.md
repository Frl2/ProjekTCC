# FleetTrack Mobile Driver App

## Setup

1. Install Flutter
2. Jalankan:

flutter pub get

3. Ubah IP pada:

lib/core/api_config.dart

contoh:

static const authUrl = "http://192.168.x.x:5001";
static const logisticsUrl = "http://192.168.x.x:5002";

4. Pastikan auth-service dan logistics-service berjalan.

5. Jalankan:

flutter run

## Fitur

* Login Driver
* List Shipment
* Detail Shipment
* Update Status Shipment

## Backend

Auth Service : Port 5001
Logistics Service : Port 5002
