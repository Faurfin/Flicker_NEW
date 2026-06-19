import '../../../../core/api/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<bool> sendCode(String phoneNumber) async {
    try {
      // Отправляем POST запрос на FastAPI
      final response = await _apiClient.dio.post(
        '/auth/send-code',
        data: {'phone_number': phoneNumber},
      );
      
      if (response.statusCode == 200) {
        return true; // Успешно
      }
      return false; // Ошибка
    } catch (e) {
      print('Ошибка при отправке СМС: $e');
      return false; // Ошибка сети или сервера
    }
  }
}