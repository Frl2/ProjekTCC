import 'base_service.dart';
import '../core/api_config.dart';
import '../models/route.dart';

class RouteService extends BaseService {
  Future<List<ShipRoute>> getRoutes() async {
    try {
      final response = await logisticsDio.get(ApiConfig.routes);
      final List data = response.data['data'];
      return data.map((e) => ShipRoute.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createRoute(ShipRoute route) async {
    try {
      await logisticsDio.post(ApiConfig.routes, data: route.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRoute(int id) async {
    try {
      await logisticsDio.delete("${ApiConfig.routes}/$id");
      return true;
    } catch (e) {
      return false;
    }
  }
}
