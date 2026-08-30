import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Импорт для SVG

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _accentColor = const Color(0xFFC7F431);
  final Color _inputBgColor = const Color(0xFF161616);
  final Color _textGrey = const Color(0xFFA1A1AA);
  
  // Обновленные цвета для неактивной кнопки (очень темная, как на 2 скрине)
  final Color _btnDisabledBg = const Color(0xFF27272A); // Заметный серый фон
  final Color _btnDisabledText = const Color(0xFF71717A); // Светло-серый текст

  bool _isFocused = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    final digitsOnly = value.replaceAll(' ', '');
    setState(() {
      _isPhoneValid = digitsOnly.length == 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    
                    const Text(
                      'Войти во Фликер',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Введите номер телефона для входа',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        // Контейнер с флагом (SVG)
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: _inputBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // СЮДА ПОДГРУЗИТСЯ ТВОЙ SVG (Убедись, что файл лежит по этому пути)
                              SvgPicture.asset(
                                'assets/icons/ru_flag.svg',
                                width: 24,
                                height: 24,
                                // Если файла пока нет, можно временно оставить заглушку, раскомментировав строку ниже
                                // placeholderBuilder: (context) => const Text('🇷🇺', style: TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Контейнер с вводом и перманентным +7
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 56,
                            decoration: BoxDecoration(
                              color: _inputBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isFocused ? _accentColor : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            // Использование Row позволяет +7 отображаться всегда
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Text(
                                  '+7',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.number,
                                    onChanged: _onPhoneChanged,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _RussianPhoneFormatter(),
                                    ],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: _textGrey,
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: 'Продолжая авторизацию, вы соглашаетесь с '),
                          TextSpan(
                            text: 'политикой\nконфиденциальности',
                            style: TextStyle(color: _accentColor),
                          ),
                          const TextSpan(text: ' и '),
                          TextSpan(
                            text: 'условиями сервиса',
                            style: TextStyle(color: _accentColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Указываем цвета для включенного состояния
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.black,
                    
                    // Указываем цвета специально для ВЫКЛЮЧЕННОГО состояния
                    disabledBackgroundColor: _btnDisabledBg,
                    disabledForegroundColor: _btnDisabledText,
                    
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isPhoneValid
                      ? () {
                          // Логика перехода дальше
                        }
                      : null, 
                  child: const Text(
                    'Дальше',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RussianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > 10) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < newValue.text.length; i++) {
      if (i == 3 || i == 6 || i == 8) {
        formatted += ' ';
      }
      formatted += newValue.text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}