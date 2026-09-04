import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../home/ui/main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phoneNumber; // Добавили переменную!

  const ProfileSetupScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _accentColor = const Color(0xFFC7F431);
  final Color _inputBgColor = const Color(0xFF161616);
  final Color _textGrey = const Color(0xFFA1A1AA);
  final Color _btnDisabledBg = const Color(0xFF27272A);
  final Color _btnDisabledText = const Color(0xFF71717A);

  final TextEditingController _nameController = TextEditingController();
  bool _isNameFocused = false;
  
  Uint8List? _avatarBytes; 
  final ImagePicker _picker = ImagePicker();

  final List<String> _selectedInterests = [];
  final Map<String, List<String>> _interestCategories = {
    'Игры': ['CS2', 'Dota 2', 'Valorant', 'Fortnite', 'Apex Legends', 'LoL'],
    'Спорт': ['Футбол', 'Баскетбол', 'Теннис', 'Бег', 'Бокс', 'Велоспорт'],
    'Оффлайн активности': ['Походы', 'Настолки', 'Концерты', 'Кино', 'Книги'],
  };

  String? _selectedSource;
  final List<String> _sources = [
    'TikTok/Reels',
    'Discord-комьюнити',
    'Twitch/Стримы',
    'Reddit/форумы',
    'Просто наткнулся'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes(); 
      setState(() {
        _avatarBytes = bytes;
      });
    }
  }

  void _nextStep() {
    FocusScope.of(context).unfocus(); 
    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submitProfile();
    }
  }

  Future<void> _submitProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFC7F431))),
    );

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/auth/update-profile');
      
      final Map<String, dynamic> requestBody = {
        'phone_number': widget.phoneNumber, 
        'name': _nameController.text.trim(),
        'interests': _selectedInterests, 
        'discovery_source': _selectedSource,
      };

      if (_avatarBytes != null) {
        requestBody['avatar_base64'] = base64Encode(_avatarBytes!);
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        print("Ошибка бэкенда: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); 
      print("Ошибка сети при сохранении профиля: $e");
    }
  }

  bool get _isButtonActive {
    if (_currentStep == 0) return _nameController.text.trim().isNotEmpty;
    if (_currentStep == 1) return _selectedInterests.length == 3;
    if (_currentStep == 2) return _selectedSource != null;
    return false;
  }

  String get _buttonText {
    if (_currentStep == 0) return 'Дальше';
    if (_currentStep == 1) {
      return _selectedInterests.length == 3 ? 'Далее' : 'Выбрано ${_selectedInterests.length} из 3';
    }
    return 'Войти во Фликер';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _currentStep > 0) {
          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ШАГ ${_currentStep + 1} ИЗ 3',
                      style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: _btnDisabledBg, borderRadius: BorderRadius.circular(3))),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          width: MediaQuery.of(context).size.width * ((_currentStep + 1) / 3),
                          decoration: BoxDecoration(color: _accentColor, borderRadius: BorderRadius.circular(3)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), 
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    _buildStep1Name(),
                    _buildStep2Interests(),
                    _buildStep3Source(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonActive ? _accentColor : _btnDisabledBg,
                      foregroundColor: _isButtonActive ? Colors.black : _btnDisabledText,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isButtonActive ? _nextStep : null,
                    child: Text(_buttonText, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Name() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Как вас зовут?', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Как друзья будут к вам обращаться ?', style: TextStyle(color: _textGrey, fontSize: 16)),
          const SizedBox(height: 48),
          Center(
            child: GestureDetector(
              onTap: _pickAvatar, 
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(color: _inputBgColor, shape: BoxShape.circle),
                        child: ClipOval(
                          child: _avatarBytes != null
                              ? Image.memory(_avatarBytes!, fit: BoxFit.cover, width: 120, height: 120)
                              : Center(child: Icon(Icons.camera_alt_outlined, color: _accentColor, size: 40)),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: _accentColor, shape: BoxShape.circle, border: Border.all(color: _bgColor, width: 4)),
                        child: Icon(_avatarBytes != null ? Icons.edit : Icons.add, color: Colors.black, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_avatarBytes != null ? 'Изменить аватарку' : 'Загрузите аватарку', style: TextStyle(color: _textGrey, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Focus(
            onFocusChange: (hasFocus) => setState(() => _isNameFocused = hasFocus),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                color: _inputBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isNameFocused || _nameController.text.isNotEmpty ? _accentColor : Colors.transparent, width: 1.5),
              ),
              child: TextField(
                controller: _nameController,
                onChanged: (val) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Введите ваше Имя',
                  hintStyle: TextStyle(color: _btnDisabledText, fontSize: 18, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Interests() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Что вам по душе?', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Это поможет находить людей со\nсхожими интересами', style: TextStyle(color: _textGrey, fontSize: 16, height: 1.3)),
          const SizedBox(height: 32),
          ..._interestCategories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: entry.value.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            if (_selectedInterests.length < 3) {
                              _selectedInterests.add(interest);
                            }
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(color: isSelected ? _accentColor : _inputBgColor, borderRadius: BorderRadius.circular(100)),
                        child: Text(
                          interest,
                          style: TextStyle(color: isSelected ? Colors.black : _textGrey, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep3Source() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Как вы о нас узнали?', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Это не влияет на рекомендации\nпросто любопытно', style: TextStyle(color: _textGrey, fontSize: 16, height: 1.3)),
          const SizedBox(height: 32),
          ..._sources.map((source) {
            final isSelected = _selectedSource == source;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedSource = source),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(color: isSelected ? _accentColor : _inputBgColor, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    source,
                    style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}