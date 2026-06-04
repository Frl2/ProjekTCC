import 'base_service.dart';
import '../core/api_config.dart';
import '../models/vehicle.dart';

class VehicleService extends BaseService {
  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await logisticsDio.get(ApiConfig.vehicles);
      final List data = response.data['data'];
      return data.map((e) => Vehicle.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createVehicle(Vehicle vehicle) async {
    try {
      await logisticsDio.post(ApiConfig.vehicles, data: vehicle.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateVehicle(int id, Vehicle vehicle) async {
    try {
      await logisticsDio.put("${ApiConfig.vehicles}/$id", data: vehicle.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    try {
      await logisticsDio.delete("${ApiConfig.vehicles}/$id");
      return true;
    } catch (e) {
      return false;
    }
  }
}
