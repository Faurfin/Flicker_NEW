import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _textGrey = const Color(0xFFA1A1AA);
  final Color _surfaceColor = const Color(0xFF1C1C1C).withOpacity(0.5);
  final Color _accentColor = const Color(0xFFC7F431);
  
  List<Map<String, dynamic>> _recommendedUsers = [];
  bool _isLoading = true;
  String? _currentUserPhone;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_phone');
    
    if (phone != null) {
      _currentUserPhone = phone;
      await _fetchRecommendations();
    } else {
      setState(() => _isLoading = false);
      print("Ошибка: Номер текущего пользователя не найден в памяти");
    }
  }

  Future<void> _fetchRecommendations() async {
    if (_currentUserPhone == null) return;

    try {
      final encodedPhone = Uri.encodeComponent(_currentUserPhone!);
      final url = Uri.parse('http://127.0.0.1:8000/api/users/recommendations?phone_number=$encodedPhone');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes)); 
        setState(() {
          _recommendedUsers = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print("Ошибка сервера: ${response.statusCode}");
      }
    } catch (e) {
      print("Ошибка сети при загрузке рекомендаций: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeUser(String id) async {
    setState(() {
      _recommendedUsers.removeWhere((user) => user['id'] == id);
    });

    if (_currentUserPhone == null) return;

    try {
      final encodedPhone = Uri.encodeComponent(_currentUserPhone!);
      final url = Uri.parse('http://127.0.0.1:8000/api/users/hide-recommendation?phone_number=$encodedPhone');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'hidden_user_id': int.parse(id)}),
      );
    } catch (e) {
      print("Ошибка при скрытии пользователя: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _buildGlassContainer(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/search_glass.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(_textGrey, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Добавить или найти друга...',
                    style: TextStyle(color: _textGrey, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScreen()),
                );
              },
              child: _buildGlassContainer(
                height: 73,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Пригласите своих друзей',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'fliker://app/profile/invite-friends',
                          style: TextStyle(color: _textGrey, fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SvgPicture.asset(
                      'assets/icons/invite_link.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            Text(
              'Люди с похожими интересами',
              style: TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 20),

            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: CircularProgressIndicator(color: _accentColor),
                ),
              )
            else if (_recommendedUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Пока нет новых рекомендаций',
                  style: TextStyle(color: _textGrey, fontSize: 15),
                ),
              )
            else
              ..._recommendedUsers.map((user) => _buildUserItem(user)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.hardEdge,
            child: Image.network(
              user['avatar'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _surfaceColor,
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user['subtitle'],
                  style: TextStyle(color: _textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeUser(user['id']),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/icons/close_cross.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(_textGrey, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required double height, required EdgeInsets padding, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}