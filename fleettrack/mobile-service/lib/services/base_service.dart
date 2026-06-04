import 'package:dio/dio.dart';
import 'token_service.dart';
import '../core/api_config.dart';

class BaseService {
  final Dio authDio = Dio(BaseOptions(baseUrl: ApiConfig.authUrl));
  final Dio logisticsDio = Dio(BaseOptions(baseUrl: ApiConfig.logisticsUrl));

  BaseService() {
    _addInterceptors(authDio);
    _addInterceptors(logisticsDio);
  }

  void _addInterceptors(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle unauthorized, maybe redirect to login
          TokenService().removeToken();
        }
        return handler.next(e);
      },
    ));
  }
}
