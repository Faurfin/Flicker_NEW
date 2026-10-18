import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

class AlienProfileScreen extends StatefulWidget {
  final int userId;

  const AlienProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AlienProfileScreen> createState() => _AlienProfileScreenState();
}

class _AlienProfileScreenState extends State<AlienProfileScreen> {
  // Навигация нижней панели
  int _selectedNavIndex = 4;

  // Статические mock-данные
  static const Map<String, dynamic> _mockProfileData = {
    'username': 'maksim_ph',
    'bio': 'Мы пока ничего не знаем об этом пользователе...',
    'friends_count': 38,
    'initial': 'А',
  };

  // Точные параметры из Figma
  static const double _cardTop = 84.0;
  static const double _avatarRadius = 47.0;

  // Жестко заданные цвета фонов для гарантии визуального разделения (как в Figma)
  static const Color _topBgColor = Color(0xFF151714); 
  static const Color _cardBgColor = Color(0xFF090B08); 

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _topBgColor, // Верхний фон
        extendBody: true, 
        appBar: _buildAppBar(context),
        body: SafeArea(
          bottom: false,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Зона верхнего фона (светлее)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _cardTop,
                child: Container(
                  color: _topBgColor,
                ),
              ),

              // 2. Карточка контента со скруглениями (темнее)
              Positioned(
                top: _cardTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: _cardBgColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Отступ под половину аватара + gap
                      const SizedBox(height: _avatarRadius + 16.0),

                      // Имя и Био
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildNameAndBio(),
                      ),
                      const SizedBox(height: 16.0),

                      // Кнопки действий
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildActionButtons(),
                      ),
                      const SizedBox(height: 16.0),

                      // Строка друзей
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildStatsRow(),
                      ),
                      const SizedBox(height: 16.0),

                      // Вкладки
                      _buildTabBar(),

                      // Контент вкладок
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildEmptyPostsPlaceholder(),
                            _buildEmptyPostsPlaceholder(),
                            _buildAboutTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Аватар (перекрывает границу двух фонов)
              Positioned(
                top: _cardTop - _avatarRadius,
                left: 16.0,
                child: _buildMainAvatar(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: AppBar(
        backgroundColor: _topBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.maybePop(context),
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  width: 24.0,
                  height: 24.0,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Фли',
                    style: TextStyle(
                      fontFamily: 'SF Pro Rounded',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'кер',
                    style: TextStyle(
                      fontFamily: 'SF Pro Rounded',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      color: Color(0xFFBDE038), // Точный цвет из Figma
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: SvgPicture.asset(
                  'assets/icons/more.svg',
                  width: 24.0,
                  height: 24.0,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAvatar() {
    final String initial = _mockProfileData['initial'] as String;

    return Container(
      width: 94.0,
      height: 94.0,
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(53.0),
        border: Border.all(
          color: const Color(0xFF414141), // Точный цвет обводки из Figma
          width: 1.0,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildNameAndBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mockProfileData['username'] as String,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            height: 19.2 / 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          _mockProfileData['bio'] as String,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF7B7B7B),
            fontSize: 13.0,
            height: 16.0 / 13.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    const Color brandColor = Color(0xFFBDE038);
    const Color darkText = Color(0xFF151714);

    return SizedBox(
      height: 48.0,
      child: Row(
        children: [
          Expanded(
            flex: 168,
            child: SizedBox(
              height: 48.0,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: darkText,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/add_friend.svg',
                      width: 20.0,
                      height: 20.0,
                      colorFilter: const ColorFilter.mode(darkText, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8.0),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Добавить в друзья',
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            color: darkText,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            height: 18.0 / 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 167,
            child: SizedBox(
              height: 48.0,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: brandColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  side: const BorderSide(
                    color: brandColor,
                    width: 1.0,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/chat.svg',
                      width: 20.0,
                      height: 20.0,
                      colorFilter: const ColorFilter.mode(brandColor, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8.0),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Написать сообщение',
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            color: brandColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            height: 18.0 / 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final int friendsCount = _mockProfileData['friends_count'] as int;

    return SizedBox(
      height: 48.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 98.0,
            height: 32.0,
            child: Stack(
              children: [
                Positioned(left: 0.0, child: _buildMiniFriendAvatar('assets/icons/avatar_1.svg')),
                Positioned(left: 22.0, child: _buildMiniFriendAvatar('assets/icons/avatar_2.svg')),
                Positioned(left: 44.0, child: _buildMiniFriendAvatar('assets/icons/avatar_3.svg')),
                Positioned(left: 66.0, child: _buildMiniFriendBadge('+9')),
              ],
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            '$friendsCount друзей',
            style: const TextStyle(
              fontFamily: 'Inter Tight',
              color: Color(0xFF8B8D98),
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.42,
              height: 20.0 / 14.0,
            ),
          ),
          const Spacer(),
          SvgPicture.asset(
            'assets/icons/chevron_right.svg',
            width: 24.0,
            height: 24.0,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniFriendAvatar(String assetPath) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C2C2C),
        border: Border.all(
          color: _cardBgColor, // Обводка цветом фона карточки для эффекта "выреза"
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMiniFriendBadge(String text) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCC000000), // 80% черный
        border: Border.all(
          color: const Color(0xFF2C2C2C),
          width: 1.0,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter Tight',
          color: Color(0xFFB9BBC6),
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.42,
          height: 20.0 / 14.0,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    const Color brandColor = Color(0xFFBDE038);
    
    return Container(
      height: 44.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF151714),
            width: 1.0,
          ),
        ),
      ),
      child: const TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: brandColor,
        indicatorWeight: 2.0,
        labelColor: brandColor,
        unselectedLabelColor: Color(0xFF7B7B7B),
        labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
        labelStyle: TextStyle(
          fontFamily: 'Inter Tight',
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter Tight',
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: 'Публикации'),
          Tab(text: 'Истории'),
          Tab(text: 'О себе'),
        ],
      ),
    );
  }

  Widget _buildEmptyPostsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/empty_posts.svg',
              width: 54.0,
              height: 54.0,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(height: 4.0),
            const Text(
              'Пока нет публикаций',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                height: 20.0 / 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            const Text(
              'Когда пользователь добавит контент, он появится здесь',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter Tight',
                color: Color(0xFF7B7B7B),
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                height: 18.0 / 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          _mockProfileData['bio'] as String,
          style: const TextStyle(
            fontFamily: 'Inter Tight',
            color: Colors.white,
            fontSize: 14.0,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: double.infinity,
          color: const Color(0x801C1C1C), // 1C1C1C, 50%
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64.0,
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
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    final bool isActive = _selectedNavIndex == index;
    final Color color = isActive ? const Color(0xFFBDE038) : AppColors.textGray;

    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24.0,
              height: 24.0,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.0,
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
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: SvgPicture.asset(
          'assets/icons/nav_center.svg',
          width: 52.0,
        ),
      ),
    );
  }
}