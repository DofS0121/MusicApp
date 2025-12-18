import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: "application/json",
  ));

  Future<Response> get(String endpoint, {String? token}) {
    return _dio.get(
      endpoint,
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
  }

  Future<Response> post(String endpoint, dynamic data, {String? token}) {
    return _dio.post(
      endpoint,
      data: data,
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
  }
}
