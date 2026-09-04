import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Цвета
  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _accentColor = const Color(0xFFC7F431); // Brand/900
  final Color _textGrey = const Color(0xFFA1A1AA);    // Gray/600
  final Color _navBgColor = const Color(0xFF1C1C1C).withOpacity(0.5); // 1C1C1C, 50%

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: true, // Позволяет контенту заходить под нижнюю навигацию для эффекта размытия
      body: SafeArea(
        bottom: false, // Отключаем нижнюю безопасную зону для контента, чтобы он уходил под панель
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _currentIndex == 0 
                  ? _buildEmptyState() 
                  : Center(
                      child: Text(
                        'Экран $_currentIndex',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
      // Плавающая нижняя панель навигации
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset('assets/icons/logo.svg', height: 26),
          GestureDetector(
            onTap: () {}, // Уведомления
            child: SvgPicture.asset('assets/icons/bell.svg', width: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иллюстрация
          Image.asset('assets/images/illustration.png', height: 240, fit: BoxFit.contain),
          const SizedBox(height: 32),

          // Заголовок
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              children: [
                const TextSpan(text: 'Здесь пока ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'тихо', style: TextStyle(color: _accentColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Подзаголовок
          Text(
            'Добавьте друзей, чтобы первыми\nвидеть их новые истории',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGrey, fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 40),

          // Кнопка строго по Figma: W 231, H 48, Radius 8
          SizedBox(
            width: 231,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/add_friend.svg',
                    width: 20, // Немного уменьшили иконку для высоты 48
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Добавить друзей',
                    style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Отступ под плавающую навигацию
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Отступ от нижнего края экрана
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Обрезка для эффекта размытия (Radius 12)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Background blur
                child: Container(
                  width: 367,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _navBgColor, // 1C1C1C, 50%
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNavItem(0, 'Главная', 'assets/icons/nav_home.svg'),
                      _buildNavItem(1, 'Поиск', 'assets/icons/nav_search.svg'),
                      _buildCenterAddButton(),
                      _buildNavItem(3, 'Чаты', 'assets/icons/nav_chats.svg'),
                      _buildNavItem(4, 'Профиль', 'assets/icons/nav_profile.svg'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    final isActive = _currentIndex == index;
    final color = isActive ? _accentColor : _textGrey;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color, 
                fontSize: 11, 
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Открыть меню выбора активности
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: SvgPicture.asset(
          'assets/icons/nav_center.svg',
          width: 52, // Ширина центрального салатового квадрата
        ),
      ),
    );
  }
}