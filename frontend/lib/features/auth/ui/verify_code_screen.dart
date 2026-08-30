import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

enum VerifyState { typing, loading, error, success }

class VerifyCodeScreen extends StatefulWidget {
  final String phoneNumber;
  final String rawPhoneNumber; // Чистый номер (+72222222222) для отправки на бэкенд

  const VerifyCodeScreen({
    super.key,
    required this.phoneNumber,
    required this.rawPhoneNumber,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _accentColor = const Color(0xFFC7F431);
  final Color _boxBgColor = const Color(0xFF161616);
  final Color _boxBorderColor = const Color(0xFF27272A);
  final Color _textGrey = const Color(0xFFA1A1AA);
  final Color _btnDisabledBg = const Color(0xFF27272A);
  
  final Color _errorColor = const Color(0xFFFF4D4D); 
  final Color _successColor = const Color(0xFFC7F431); 

  VerifyState _state = VerifyState.typing;
  
  int _secondsRemaining = 50;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 50);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onCodeChanged(String value) {
    if (_state == VerifyState.error) {
      setState(() => _state = VerifyState.typing);
    } else {
      setState(() {});
    }
  }

  // Настоящая отправка на бэкенд для проверки
  // Настоящая отправка на бэкенд для проверки
  Future<void> _verifyCode() async {
    if (_codeController.text.length != 5) return;
    
    _focusNode.unfocus();
    setState(() => _state = VerifyState.loading);

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/auth/verify-code');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': widget.rawPhoneNumber,
          'code': _codeController.text, 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _state = VerifyState.success);
        
        // 1. Декодируем ответ сервера
        final responseData = jsonDecode(response.body);
        
        // 2. Ждем полсекунды, чтобы пользователь увидел зеленую анимацию успеха
        Future.delayed(const Duration(milliseconds: 500), () {
          
          // TODO: Сохранить токен авторизации (например, через SharedPreferences)
          // final token = responseData['access_token'];

          // 3. Переход на следующий экран. 
          // Если бэкенд отдает флаг нового пользователя, можно использовать условие:
          // bool isNewUser = responseData['is_new_user'] ?? true;
          // if (isNewUser) { ... } else { ... }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // ВРЕМЕННАЯ ЗАГЛУШКА: Замени это на свой реальный экран создания профиля
              builder: (context) => const Scaffold(
                backgroundColor: Color(0xFF0A0A0A),
                body: Center(
                  child: Text(
                    'Экран регистрации\n(Создание профиля)', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          );
        });
      } else {
        _handleError();
      }
    } catch (e) {
      print("Ошибка сети при проверке кода: $e");
      _handleError();
    }
  }

  // Метод для повторной отправки СМС
  Future<void> _resendCode() async {
    setState(() => _state = VerifyState.loading);
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/auth/send-code');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': widget.rawPhoneNumber}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _startTimer(); // Сбрасываем таймер обратно на 50 сек
        setState(() => _state = VerifyState.typing);
        print("Код отправлен повторно!");
      } else {
        _handleError();
      }
    } catch (e) {
      print("Ошибка сети при отправке: $e");
      _handleError();
    }
  }

  void _handleError() {
    setState(() {
      _state = VerifyState.error;
      _codeController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCodeComplete = _codeController.text.length == 5;
    final bool canResend = _secondsRemaining == 0;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    
                    const Text(
                      'Введите код из СМС',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Мы отправили вам код для входа\nна ваш номер телефона',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.phoneNumber, 
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: 0.0,
                            child: TextField(
                              controller: _codeController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              onChanged: _onCodeChanged,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(5, (index) {
                              String digit = '';
                              if (_codeController.text.length > index) {
                                digit = _codeController.text[index];
                              }

                              bool isActive = _codeController.text.length == index && _focusNode.hasFocus;
                              
                              Color borderColor = Colors.transparent;
                              if (_state == VerifyState.error) {
                                borderColor = _errorColor;
                              } else if (_state == VerifyState.success) {
                                borderColor = _successColor;
                              } else if (isActive) {
                                borderColor = _accentColor;
                              } else if (digit.isEmpty) {
                                borderColor = _boxBorderColor;
                              }

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _boxBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor,
                                    width: isActive || _state != VerifyState.typing ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  digit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCodeComplete || canResend ? (isCodeComplete ? _accentColor : _boxBorderColor) : _btnDisabledBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      // Логика кнопки: если код 5 цифр -> отправляем код. Иначе, если таймер 0 -> запрашиваем код заново.
                      onPressed: isCodeComplete 
                          ? _verifyCode 
                          : (canResend ? _resendCode : null),
                      child: isCodeComplete
                          ? const Text(
                              'Войти',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Отправить код повторно ',
                                    style: TextStyle(color: canResend ? Colors.white : const Color(0xFF71717A)),
                                  ),
                                  TextSpan(
                                    text: canResend ? '' : '0:${_secondsRemaining.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: _secondsRemaining > 0 
                                          ? _accentColor 
                                          : const Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
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
          ],
        ),
      ),
    );
  }
}