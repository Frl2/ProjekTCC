import 'package:dio/dio.dart';

import '../core/api_config.dart';
import 'token_service.dart';

class UserService {

  final Dio dio = Dio();

  Future<Map<String, dynamic>>
      getCurrentUser() async {

    final token =
        await TokenService().getToken();

    final response = await dio.get(
      '${ApiConfig.authUrl}/api/auth/me',

      options: Options(
        headers: {
          "Authorization":
              "Bearer $token",
        },
      ),
    );

    return response.data['data'];
  }
}