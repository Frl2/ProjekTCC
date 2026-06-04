import 'base_service.dart';
import '../core/api_config.dart';
import '../models/driver.dart';

class DriverService extends BaseService {
  Future<List<Driver>> getDrivers() async {
    try {
      final response = await logisticsDio.get(ApiConfig.drivers);
      final List data = response.data['data'];
      return data.map((e) => Driver.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createDriver(Driver driver) async {
    try {
      await logisticsDio.post(ApiConfig.drivers, data: driver.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDriver(int id, Driver driver) async {
    try {
      await logisticsDio.put("${ApiConfig.drivers}/$id", data: driver.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDriver(int id) async {
    try {
      await logisticsDio.delete("${ApiConfig.drivers}/$id");
      return true;
    } catch (e) {
      return false;
    }
  }
}
