import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;

  Future<void> _onNextPressed() async {
    final number = _phoneController.text.trim();
    if (number.isEmpty) return;

    setState(() => _isLoading = true);

    final fullPhoneNumber = '+7$number';
    final isSuccess = await _authRepository.sendCode(fullPhoneNumber);

    setState(() => _isLoading = false);

    if (isSuccess) {
      print('Успех! Переходим к вводу кода для: $fullPhoneNumber');
      // В будущем здесь будет навигация на экран VerifyScreen
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка отправки. Проверьте подключение.')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                      const SizedBox(height: 50),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Text('LOGO', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF000000))),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Войти во Фликер',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 28, height: 1.1, color: Color(0xFF212121)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Введите номер телефона для входа',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w400, fontSize: 16, color: Color(0xFF5D5D5D)),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            width: 74,
                            height: 50,
                            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(13)),
                            alignment: Alignment.center,
                            child: const Text('ICON', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF212121))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(13)),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF212121)),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  prefixText: '+7 ',
                                  prefixStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF212121)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontFamily: 'Mulish', fontWeight: FontWeight.w600, fontSize: 10, height: 1.3, color: Color(0xFF969696)),
                          children: [
                            TextSpan(text: 'Продолжая авторизацию, вы соглашаетесь с '),
                            TextSpan(text: 'политикой конфиденциальности', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                            TextSpan(text: ' и '),
                            TextSpan(text: 'условиями сервиса', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _isLoading ? null : _onNextPressed,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(color: const Color(0xFFE9E9E9), borderRadius: BorderRadius.circular(100)),
                          alignment: Alignment.center,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF212121)))
                            : const Text('Далее', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.48, color: Color(0xFF212121))),
                        ),
                      ),
                      SizedBox(height: bottomPadding > 0 ? 16 : 34),
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