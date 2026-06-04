import 'base_service.dart';
import '../core/api_config.dart';

class DashboardService extends BaseService {
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await logisticsDio.get(ApiConfig.stats);
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }
}
