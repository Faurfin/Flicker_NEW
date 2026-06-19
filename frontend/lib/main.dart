import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'otp_screen.dart'; // Подключаем второй экран

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PhoneLoginScreen(),
    );
  }
}

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Функция отправки телефона на сервер
  Future<void> _sendPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
      
      // Формируем номер с +7, если пользователь ввел только цифры
      final fullPhoneNumber = '+7$phone';
      
      final response = await dio.post('/auth/send-code', data: {
        'phone_number': fullPhoneNumber,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: fullPhoneNumber),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка соединения с сервером')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Отступ сверху
                      const SizedBox(height: 50),
                      
                      // ЛОГОТИП
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'LOGO',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // ЗАГОЛОВКИ
                      const Text(
                        'Войти во Фликер',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          height: 1.1,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Введите номер телефона для входа',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFF5D5D5D),
                          letterSpacing: 0.48,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // ПОЛЯ ВВОДА (ICON и +7)
                      Row(
                        children: [
                          // Блок с иконкой
                          Container(
                            width: 74,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'ICON',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Блок с номером телефона
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF212121),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  prefixText: '+7 ', // Префикс внутри поля
                                  prefixStyle: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ТЕКСТ УСЛОВИЙ
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            height: 1.3,
                            color: Color(0xFF969696),
                          ),
                          children: [
                            TextSpan(text: 'Продолжая авторизацию, вы соглашаетесь с '),
                            TextSpan(text: 'политикой\nконфиденциальности', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                            TextSpan(text: ' и '),
                            TextSpan(text: 'условиями сервиса', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // КНОПКА ДАЛЕЕ
                      GestureDetector(
                        onTap: _isLoading ? null : _sendPhone,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          alignment: Alignment.center,
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.48,
                                  color: Color(0xFF212121),
                                ),
                              ),
                        ),
                      ),
                      
                      // Отступ снизу для Home Indicator
                      const SizedBox(height: 34),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}