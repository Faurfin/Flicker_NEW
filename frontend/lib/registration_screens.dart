import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Добавили dio

class RegistrationFlow extends StatefulWidget {
  final String phoneNumber; // Добавили номер телефона!

  const RegistrationFlow({super.key, required this.phoneNumber});

  @override
  State<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  final PageController _pageController = PageController();
  
  // Данные для отправки
  String _name = '';
  final List<String> _selectedInterests = [];
  String _discoverySource = '';
  bool _isLoading = false; // Добавили загрузку

  final List<String> _games = ['CS2', 'Dota 2', 'Valorant', 'Fortnite', 'Apex Legends', 'LoL', 'Minecraft', 'PUBG', 'Standoff 2'];
  final List<String> _sports = ['Футбол', 'Баскетбол', 'Тенис', 'Бег', 'Бокс', 'Велоспорт'];
  final List<String> _offline = ['Бары', 'Походы', 'Настолки', 'Концерты', 'Кино', 'Книги'];
  final List<String> _sources = ['От друзей', 'TikTok/Reels', 'Discord-комьюнити', 'Twitch/Стримы', 'Reddit/форумы', 'Просто наткнулся'];

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // --- ВОТ НАША НОВАЯ ФУНКЦИЯ ОТПРАВКИ В БАЗУ ДАННЫХ ---
  Future<void> _finishRegistration() async {
    setState(() => _isLoading = true);

    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
      
      final response = await dio.post('/auth/update-profile', data: {
        'phone_number': widget.phoneNumber,
        'name': _name.trim(),
        'interests': _selectedInterests,
        'discovery_source': _discoverySource,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль сохранен в базу! 🎉'), backgroundColor: Colors.green),
        );
        // Тут будет переход в ленту
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сохранения профиля'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) _selectedInterests.remove(interest);
      else _selectedInterests.add(interest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Запрещаем свайпать руками
          children: [
            _buildStep1(),
            _buildStep2(),
            _buildStep3(),
          ],
        ),
      ),
    );
  }

  // ================= ШАГ 1: ИМЯ И АВАТАРКА =================
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('ШАГ 1 ИЗ 3', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, letterSpacing: 1.4, color: Color(0xFF7B7B7B))),
          const SizedBox(height: 24),
          const Text('Введите ваше имя', style: TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
          
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Container(
                  width: 163, height: 163,
                  decoration: const BoxDecoration(color: Color(0xFFF4F4F4), shape: BoxShape.circle),
                  child: const Icon(Icons.image_outlined, size: 40, color: Color(0xFF9F9F9F)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE9E9E9)), borderRadius: BorderRadius.circular(15)),
                  child: const Text('Загрузить аватарку', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFA3A3A3))),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          Container(
            height: 60,
            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(13)),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              onChanged: (val) => setState(() => _name = val),
              style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF212121)),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Введите ваше Имя', hintStyle: TextStyle(color: Color(0xFFBDBDBD))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _name.trim().isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9E9E9),
                disabledBackgroundColor: const Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0,
              ),
              child: const Text('Далее', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  // ================= ШАГ 2: ИНТЕРЕСЫ =================
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('ШАГ 2 ИЗ 3', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, letterSpacing: 1.4, color: Color(0xFF7B7B7B))),
          const SizedBox(height: 12),
          const Text('Что вам по душе?', style: TextStyle(fontFamily: 'Manrope', fontSize: 36, fontWeight: FontWeight.w700, height: 1.1, color: Color(0xFF212121))),
          const SizedBox(height: 12),
          const Text('Выберите минимум 3 интереса,\nподберем подходящих вам людей', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, color: Color(0xFF5D5D5D))),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              children: [
                _buildInterestCategory('Игры', _games),
                const SizedBox(height: 24),
                _buildInterestCategory('Спорт', _sports),
                const SizedBox(height: 24),
                _buildInterestCategory('Оффлайн активности', _offline),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _selectedInterests.length >= 3 ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedInterests.length >= 3 ? const Color(0xFF212121) : const Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0,
              ),
              child: Text(
                _selectedInterests.length >= 3 ? 'Далее' : 'Выбрано ${_selectedInterests.length} из 3',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, color: _selectedInterests.length >= 3 ? Colors.white : const Color(0xFF212121)),
              ),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  Widget _buildInterestCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((item) {
            final isSelected = _selectedInterests.contains(item);
            return GestureDetector(
              onTap: () => _toggleInterest(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF212121) : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  item,
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: isSelected ? Colors.white : const Color(0xFF212121)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= ШАГ 3: ИСТОЧНИК =================
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('ШАГ 3 ИЗ 3', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, letterSpacing: 1.4, color: Color(0xFF7B7B7B))),
          const SizedBox(height: 12),
          const Text('Как вы о нас узнали?', style: TextStyle(fontFamily: 'Manrope', fontSize: 33, fontWeight: FontWeight.w700, height: 1.1, color: Color(0xFF212121))),
          const SizedBox(height: 12),
          const Text('Это не влияет на рекомендации — просто любопытно', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, color: Color(0xFF5D5D5D))),
          
          const SizedBox(height: 32),
          ..._sources.map((source) {
            final isSelected = _discoverySource == source;
            return GestureDetector(
              onTap: () => setState(() => _discoverySource = source),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE9E9E9) : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(26),
                  border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
                ),
                child: Text(source, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
              ),
            );
          }),

          const Spacer(),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _discoverySource.isNotEmpty ? _finishRegistration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9E9E9),
                disabledBackgroundColor: const Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0,
              ),
              child: const Text('Войти во Фликер', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}