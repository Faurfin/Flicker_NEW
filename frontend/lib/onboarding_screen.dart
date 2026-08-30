import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/ui/login_screen.dart'; // Добавляем эту строку
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ЗАМЕНИТЕ НА ВАШ ФАЙЛ ЭКРАНА АВТОРИЗАЦИИ:
// import 'features/auth/ui/login_screen.dart'; 
// import 'main.dart'; // Если экран авторизации лежит там

class OnboardingData {
  final String imagePath;
  final String stepNumber;
  final String stepTag;
  final String title;
  final String description;

  OnboardingData({
    required this.imagePath,
    required this.stepNumber,
    required this.stepTag,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Главный салатовый цвет из дизайна
  final Color _accentColor = const Color(0xFFC7F431);
  final Color _bgColor = const Color(0xFF0A0A0A);

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/onboarding_1.jpg',
      stepNumber: '01',
      stepTag: 'БЕЗ ШУМА',
      title: 'Социальная сеть\nнового типа',
      description: 'Никаких виртуальных гонок, только\nлента ваших друзей',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_2.jpg',
      stepNumber: '02',
      stepTag: 'ДРУЗЬЯ ВСЕГДА РЯДОМ',
      title: 'Только реальные\nдрузья и команды',
      description: 'Голосовые комнаты, группы по\nинтересам и поиск людей',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_3.jpg',
      stepNumber: '03',
      stepTag: 'БЕЗ ЛАЙКОВ',
      title: 'Интерес, отклик,\nподдержка',
      description: 'Никакой токсичной метрики, только\nживые реакции и живое общение',
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    if (!mounted) return;
    
    // ПЕРЕХОД НА ЭКРАН АВТОРИЗАЦИИ (ЗАМЕНИТЕ PhoneLoginScreen НА ВАШ КЛАСС)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка "Пропустить"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Карусель экранов
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Картинка с закругленными краями
                        // Картинка с закругленными краями (С ИСПРАВЛЕННЫМИ ПРОПОРЦИЯМИ)
                        // Картинка (ИСПРАВЛЕНЫ БЕЛЫЕ УГЛЫ)
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: ClipRRect(
                              // Увеличили радиус до 32, чтобы срезать белые рамки JPG
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                _pages[index].imagePath,
                                width: double.infinity,
                                fit: BoxFit.fitWidth, 
                                errorBuilder: (context, error, stackTrace) => 
                                  const SizedBox(
                                    height: 350, 
                                    child: Center(child: Icon(Icons.image, color: Colors.white24, size: 50)),
                                  ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Шаг (01 — БЕЗ ШУМА)
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                            children: [
                              TextSpan(
                                text: _pages[index].stepNumber,
                                style: TextStyle(color: _accentColor),
                              ),
                              TextSpan(
                                text: ' — ${_pages[index].stepTag}',
                                style: const TextStyle(color: Color(0xFF71717A)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Заголовок
                        Text(
                          _pages[index].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Описание
                        Text(
                          _pages[index].description,
                          style: const TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Нижняя часть (Индикаторы + Кнопка)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Индикаторы страниц (прорези)
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 4,
                        width: _currentPage == index ? 32 : 24,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _accentColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Кнопка "Дальше"
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Дальше',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}