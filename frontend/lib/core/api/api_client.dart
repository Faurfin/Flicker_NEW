import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Модель детального профиля пользователя (соответствует UserProfileDetailResponse в FastAPI)
class UserProfileDetailResponse {
  final int id;
  final String username;
  final String? avatarUrl;
  final String bio;
  final int friendsCount;
  final String friendshipStatus; // 'none' | 'request_sent' | 'friends' | 'self'

  const UserProfileDetailResponse({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.bio,
    required this.friendsCount,
    required this.friendshipStatus,
  });

  factory UserProfileDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileDetailResponse(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      username: (json['username'] ?? 'Пользователь') as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: (json['bio'] ?? '') as String,
      friendsCount: (json['friends_count'] ?? 0) as int,
      friendshipStatus: (json['friendship_status'] ?? 'none') as String,
    );
  }

  /// Первая буква имени для аватарки, если фото не загружено
  String get initial {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed[0].toUpperCase();
  }
}

class ApiClient {
  final Dio dio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'http://localhost:8000/api',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  /// Запрос профиля пользователя по ID: GET /api/users/{user_id}
  Future<UserProfileDetailResponse> getUserProfile(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPhone = prefs.getString('current_phone');

    final response = await dio.get(
      '/users/$userId',
      queryParameters: {
        if (currentPhone != null && currentPhone.isNotEmpty)
          'phone_number': currentPhone,
      },
    );

    return UserProfileDetailResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}