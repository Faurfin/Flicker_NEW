import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:dio/dio.dart';
import 'registration_screens.dart'; // <--- Подключаем карусель регистрации

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int _secondsLeft = 50;
  Timer? _timer;
  String _code = "";
  bool _isLoading = false;
  
  // Флаги для отслеживания статуса ввода (цвета обводки)
  bool _hasError = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsLeft = 50);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Функция проверки кода и маршрутизации
  Future<void> _verifyCode() async {
    if (_code.length < 5) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _isSuccess = false;
    });

    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api')); 
      
      final response = await dio.post('/auth/verify-code', data: {
        'phone_number': widget.phoneNumber,
        'code': _code,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        
        // Включаем зеленую обводку ячеек
        setState(() => _isSuccess = true);
        
        // Ждем 1 секунду, чтобы пользователь увидел зеленый цвет
        await Future.delayed(const Duration(seconds: 1));
        
        if (!mounted) return;
        
        // Читаем из ответа бэкенда: новый это пользователь или нет?
        final isNewUser = response.data['is_new_user'] ?? false;
        
        if (isNewUser) {
          // НОВЫЙ ПОЛЬЗОВАТЕЛЬ: Открываем карусель регистрации и передаем номер
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationFlow(phoneNumber: widget.phoneNumber),
            ),
          );
        } else {
          // СТАРЫЙ ПОЛЬЗОВАТЕЛЬ: Пускаем сразу в приложение
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('С возвращением во Фликер! 🎉', style: TextStyle(color: Colors.white)), 
              backgroundColor: Colors.green,
            ),
          );
          // В будущем здесь будет Navigator.pushReplacement на Главную ленту
        }
      }
    } catch (e) {
      // ОШИБКА: Неверный код
      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Функция повторной отправки кода
  Future<void> _resendCode() async {
    if (_secondsLeft > 0) return;
    
    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
      await dio.post('/auth/send-code', data: {
        'phone_number': widget.phoneNumber,
      });
      _startTimer();
      
      // Сбрасываем цвета при новой отправке
      setState(() {
        _hasError = false;
        _isSuccess = false;
        _code = "";
      });
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка отправки кода')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ДИНАМИЧЕСКИЙ ЦВЕТ ОБВОДКИ
    Color borderColor = Colors.transparent;
    if (_isSuccess) borderColor = Colors.green;
    else if (_hasError) borderColor = Colors.red;

    // Базовый стиль ячейки (меняет цвет границ в зависимости от стейта)
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, color: Color(0xFF2A2A2A), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
    );

    // Стиль ячейки, когда на нее нажат фокус
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          // Если есть ошибка/успех - оставляем их цвет, иначе черная рамка при фокусе
          color: (_hasError || _isSuccess) ? borderColor : Colors.black,
          width: 1.5,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Введите код из смс',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Мы отправили вам код для\nвхода на ваш номер телефона',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5D5D5D),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // ВВОД СМС КОДА
              Pinput(
                length: 5,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                pinAnimationType: PinAnimationType.scale,
                onChanged: (value) {
                  setState(() {
                    _code = value;
                    // Как только стираем или вводим цифру — убираем красноту/зеленоту
                    _hasError = false; 
                    _isSuccess = false;
                  });
                },
                onCompleted: (value) => _verifyCode(),
              ),
              
              const SizedBox(height: 24),

              // КНОПКА ПОВТОРНОЙ ОТПРАВКИ
              GestureDetector(
                onTap: _resendCode,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _secondsLeft > 0 
                        ? 'Отправить код повторно 0:${_secondsLeft.toString().padLeft(2, '0')}'
                        : 'Отправить код повторно',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _secondsLeft > 0 ? const Color(0xFFBFBFBF) : Colors.black,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ТЕКСТ СОГЛАШЕНИЯ
              const Text(
                'Продолжая авторизацию, вы соглашаетесь с политикой\nконфиденциальности и условиями сервиса',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF969696),
                ),
              ),
              const SizedBox(height: 16),

              // КНОПКА ДАЛЕЕ
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9E9E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF212121))
                        )
                      : const Text(
                          'Далее',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}