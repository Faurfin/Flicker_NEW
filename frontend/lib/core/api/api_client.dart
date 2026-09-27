import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  // Singleton паттерн, чтобы не создавать много копий клиента
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() : dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.web-flicker.online/api', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}