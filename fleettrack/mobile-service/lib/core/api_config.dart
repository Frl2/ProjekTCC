import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get authUrl => dotenv.env['AUTH_API_URL'] ?? "http://localhost:5001";
  static String get logisticsUrl => dotenv.env['LOGISTICS_API_URL'] ?? "http://localhost:5002";
  
  static const String login = "/api/auth/login";
  static const String logout = "/api/auth/logout";
  static const String me = "/api/auth/me";
  
  static const String stats = "/api/dashboard/stats";
  static const String vehicles = "/api/vehicles";
  static const String drivers = "/api/drivers";
  static const String warehouses = "/api/warehouses";
  static const String routes = "/api/routes";
  static const String shipments = "/api/shipments";
}
