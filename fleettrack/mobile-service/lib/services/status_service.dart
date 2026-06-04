import 'package:dio/dio.dart';

import '../core/api_config.dart';
import 'token_service.dart';

class StatusService {
  final Dio dio = Dio();

  Future<bool> updateStatus(
    int shipmentId,
    String status,
  ) async {
    try {
      final token =
          await TokenService().getToken();

      await dio.put(
        '${ApiConfig.logisticsUrl}/api/shipments/$shipmentId/status',

        data: {
          "status": status,
        },

        options: Options(
          headers: {
            "Authorization":
                "Bearer $token",
          },
        ),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}