import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/features/home/ui/qr_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _glassColor = const Color(0xFF1C1C1C).withOpacity(0.5); 
  
  // Базовый URL сервера (замени на IP компа при тесте на реальном устройстве)
  final String _baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('current_phone') ?? '';
      
      final encodedQuery = Uri.encodeComponent(query);
      final encodedPhone = Uri.encodeComponent(phone);

      final url = Uri.parse('$_baseUrl/api/users/search?q=$encodedQuery&phone_number=$encodedPhone');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Ошибка поиска: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isQueryEmpty = _searchController.text.trim().isEmpty;
    final String listTitle = isQueryEmpty 
        ? 'Похожие пользователи' 
        : 'Результаты которые мы нашли';

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(color: _glassColor),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400, 
                        height: 24 / 16,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Поиск...',
                        hintStyle: const TextStyle(color: Color(0xFF666666)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.5),
                          child: SvgPicture.asset(
                            'assets/icons/search_glass.svg',
                            colorFilter: const ColorFilter.mode(Color(0xFF666666), BlendMode.srcIn),
                          ),
                        ),
                        suffixIcon: !isQueryEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.5),
                                  child: SvgPicture.asset(
                                    'assets/icons/close_cross.svg',
                                    colorFilter: const ColorFilter.mode(Color(0xFF666666), BlendMode.srcIn),
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.5), 
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrScreen()),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 73,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: _glassColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Пригласите своих друзей',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 24/16),
                              ),
                              SizedBox(height: 1), 
                              Text(
                                'fliker://app/profile/invite-friends',
                                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, height: 18/13),
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
                ),
              ),

              const SizedBox(height: 24),

              // Точные параметры текста пустого состояния
              if (!isQueryEmpty && _searchResults.isEmpty && !_isLoading) 
                const SizedBox(
                  width: 272, // Топографическая ширина из Figma
                  child: Text(
                    'К сожалению мы ничего не смогли найти по вашему запросу',
                    style: TextStyle(
                      color: Color(0xFF8E8E93), 
                      fontSize: 16,
                      fontWeight: FontWeight.w400, 
                      height: 24 / 16,
                    ),
                  ),
                )
              else if (_searchResults.isNotEmpty) ...[
                Text(
                  listTitle,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93), 
                    fontSize: 16, 
                    fontWeight: FontWeight.w400, 
                    height: 24 / 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildSearchResults()),
              ],
              
              if (_isLoading && _searchResults.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFC7F431))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.separated(
      itemCount: _searchResults.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 20), 
      itemBuilder: (context, index) {
        
        if (index == _searchResults.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 40.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 127,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: _glassColor),
                    child: const Text(
                      'Показать ещё',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500, 
                        height: 20 / 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final user = _searchResults[index];
        
        // Преобразование относительной ссылки в абсолютную
        String avatarUrl = user['avatar'] ?? "https://via.placeholder.com/150";
        if (avatarUrl.startsWith('/')) {
          avatarUrl = '$_baseUrl$avatarUrl';
        }

        return Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                avatarUrl, // Используем обработанный URL
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: const Color(0xFF151515),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['username'] ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600, 
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 2), 
                  Text(
                    'Подписаны ${user['followers_count'] ?? 0} человека',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93), 
                      fontSize: 14,
                      fontWeight: FontWeight.w400, 
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}