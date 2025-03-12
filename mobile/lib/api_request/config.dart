import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// API Configuration
const String apiBaseUrl = 'https://sd27-87d55.web.app/api'; // Use relative URL - Firebase Hosting handles routing

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      contentType: 'application/json',
    ),
  );

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static void initialize() {
    // Add request interceptor to add auth token and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          log('Token from storage: ${token != null ? "Token exists" : "No token found"}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            log('Added Authorization header: ${options.headers['Authorization']}');
          }

          log('Full request config: URL=${options.uri}, Method=${options.method}, Headers=${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          log('API response: Status=${response.statusCode}, Data=${response.data}');
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          log('API error: Status=${error.response?.statusCode}, Data=${error.response?.data}');

          if (error.response?.statusCode == 401) {
            // Clear token and navigate to login
            await _storage.delete(key: 'token');
            await _storage.delete(key: 'userId');
            // You should handle navigation to login screen within your app
          }

          handler.reject(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;

  // Helper method to get API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }
}
