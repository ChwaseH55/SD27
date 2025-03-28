import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String API_BASE_URL = '/api'; // Firebase Hosting handles routing

  final Dio _dio = Dio(BaseOptions(
    baseUrl: API_BASE_URL,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        const prefs = FlutterSecureStorage();
        final token = await prefs.read(key: 'token');
        log('Token from SharedPreferences: ${token != null ? 'Token exists' : 'No token found'}');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          log('Added Authorization header: ${options.headers['Authorization']}');
        }

        log('Full request config: ${options.method} ${options.uri} - Headers: ${options.headers}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        log('API response: ${response.statusCode} - Data: ${response.data}');
        handler.next(response);
      },
      onError: (DioException error, handler) async {
        log('API error: ${error.response?.statusCode} - Data: ${error.response?.data}');

        if (error.response?.statusCode == 401) {
          const prefs = FlutterSecureStorage();
          await prefs.delete(key: 'userId');
          await prefs.delete(key: 'token');

          // Handle redirect to login (depends on Flutter's navigation)
          log('Unauthorized! Redirecting to login...');
        }

        handler.reject(error);
      },
    ));
  }

  Dio get dio => _dio;

  String getApiUrl(String endpoint) {
    return '$API_BASE_URL$endpoint';
  }
}
