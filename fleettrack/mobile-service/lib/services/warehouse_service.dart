import 'base_service.dart';
import '../core/api_config.dart';
import '../models/warehouse.dart';

class WarehouseService extends BaseService {
  Future<List<Warehouse>> getWarehouses() async {
    try {
      final response = await logisticsDio.get(ApiConfig.warehouses);
      final List data = response.data['data'];
      return data.map((e) => Warehouse.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createWarehouse(Warehouse warehouse) async {
    try {
      await logisticsDio.post(ApiConfig.warehouses, data: warehouse.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWarehouse(int id, Warehouse warehouse) async {
    try {
      await logisticsDio.put("${ApiConfig.warehouses}/$id", data: warehouse.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteWarehouse(int id) async {
    try {
      await logisticsDio.delete("${ApiConfig.warehouses}/$id");
      return true;
    } catch (e) {
      return false;
    }
  }
}
