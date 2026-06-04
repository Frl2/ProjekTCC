import 'base_service.dart';
import '../core/api_config.dart';
import '../models/shipment.dart';

class ShipmentService extends BaseService {
  Future<List<Shipment>> getShipments() async {
    try {
      final response = await logisticsDio.get(ApiConfig.shipments);
      final List data = response.data['data'];
      return data.map((e) => Shipment.fromJson(e)).toList();
    } catch (e) {
      print("GET SHIPMENTS ERROR: $e");
      return [];
    }
  }

  Future<Shipment?> getShipmentDetail(int id) async {
    try {
      final response = await logisticsDio.get("${ApiConfig.shipments}/$id");
      return Shipment.fromJson(response.data['data']);
    } catch (e) {
      print("GET SHIPMENT DETAIL ERROR: $e");
      return null;
    }
  }

  Future<bool> createShipment(Map<String, dynamic> data) async {
    try {
      await logisticsDio.post(ApiConfig.shipments, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(int id, Map<String, dynamic> data) async {
    try {
      await logisticsDio.put("${ApiConfig.shipments}/$id/status", data: data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
