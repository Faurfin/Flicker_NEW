import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  // Singleton паттерн, чтобы не создавать много копий клиента
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() : dio = Dio(
    BaseOptions(
      // ВНИМАНИЕ: Для эмулятора Android пиши 10.0.2.2, для iOS или реального телефона пиши IP компьютера (например, 192.168.1.X)
      baseUrl: 'http://127.0.0.1:8000/api', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}