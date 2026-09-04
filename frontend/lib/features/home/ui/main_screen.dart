import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _accentColor = const Color(0xFFC7F431);
  final Color _textGrey = const Color(0xFFA1A1AA);
  final Color _navBgColor = const Color(0xFF161616);
  final Color _navBorderColor = const Color(0xFF27272A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/icons/logo.svg', 
            height: 26,
          ),
          GestureDetector(
            onTap: () {
              // TODO: Открыть уведомления
            },
            child: SvgPicture.asset(
              'assets/icons/notification.svg',
              width: 28,
              height: 28,
            ),
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
          Image.asset(
            'assets/images/home_empty.png',
            height: 240,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),

          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w700, 
                letterSpacing: -0.5,
              ),
              children: [
                const TextSpan(text: 'Здесь пока ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'тихо', style: TextStyle(color: _accentColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Добавьте друзей, чтобы первыми\nвидеть их новые истории',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textGrey,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() => _currentIndex = 1);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/add_friend.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Добавить друзей',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), 
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24), 
      decoration: BoxDecoration(
        color: _navBgColor,
        border: Border(
          top: BorderSide(color: _navBorderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(0, 'Главная', 'assets/icons/nav_home.svg'),
          _buildNavItem(1, 'Поиск', 'assets/icons/nav_search.svg'),
          _buildCenterAddButton(),
          _buildNavItem(3, 'Чаты', 'assets/icons/nav_chats.svg'),
          _buildNavItem(4, 'Профиль', 'assets/icons/nav_profile.svg'),
        ],
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
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color, 
                fontSize: 11, 
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
        // TODO: Открыть меню выбора (Игры, Спорт, Оффлайн)
      },
      child: Container(
        width: 56,
        height: 40,
        margin: const EdgeInsets.only(bottom: 4), 
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/nav_add.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}