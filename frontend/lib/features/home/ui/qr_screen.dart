import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:qr/qr.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with SingleTickerProviderStateMixin {
  final Color _bgColor = const Color(0xFF0A0A0A);
  final Color _cardColor = const Color(0xFF151515); 
  final Color _actionBgColor = const Color(0xFF1C1C1C).withOpacity(0.4); 

  final Color _badgeBgColor = const Color(0xFF111A10);
  final Color _badgeBorderColor = const Color(0xFF2D591E);
  final Color _successGreen = const Color(0xFF34C759);

  bool _isLoading = true;
  String _username = "";
  String _avatarUrl = "";
  String _inviteLink = "";

  final GlobalKey _qrKey = GlobalKey();

  bool _showBadge = false;
  String _badgeText = "Ссылка скопирована"; 

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), 
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fetchProfileAndCopy();
  }

  @override
  void dispose() {
    _pulseController.dispose(); 
    super.dispose();
  }

  Future<void> _fetchProfileAndCopy() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_phone');

    if (phone == null) return;

    try {
      final encodedPhone = Uri.encodeComponent(phone);
      final url = Uri.parse('http://127.0.0.1:8000/api/users/me?phone_number=$encodedPhone');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _username = data['username'];
          _avatarUrl = data['avatar'];
          _inviteLink = data['link'];
          _isLoading = false;
        });
        
        _triggerAction('Ссылка скопирована', () {
          Clipboard.setData(ClipboardData(text: _inviteLink));
        });
      }
    } catch (e) {
      print("Ошибка загрузки профиля: $e");
      setState(() => _isLoading = false);
    }
  }

  void _triggerAction(String text, VoidCallback action) {
    if (_inviteLink.isEmpty) return;
    
    action();

    if (mounted) {
      setState(() {
        _badgeText = text;
        _showBadge = true;
      });
      _pulseController.forward(from: 0.0);
    }
  }

  Future<void> _saveQrCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(
        pngBytes, 
        quality: 100, 
        name: "Fliker_QR_$_username"
      );

      if (result['isSuccess'] == true) {
        _triggerAction('QR-код сохранен', () {});
      }
    } catch (e) {
      print("Ошибка при сохранении QR: $e");
    }
  }

  void _shareLink() {
    if (_inviteLink.isEmpty) return;
    Share.share(
      'Присоединяйся ко мне во Fliker!\nМоя ссылка: $_inviteLink',
      subject: 'Приглашение во Fliker',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFC7F431)))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ваш QR-код',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500, height: 32/24),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.transparent,
                              child: SvgPicture.asset('assets/icons/qr_close.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    RepaintBoundary(
                      key: _qrKey,
                      child: SizedBox(
                        width: 312,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 56), 
                              padding: const EdgeInsets.fromLTRB(16, 72, 16, 40), 
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '@$_username',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, height: 30/20),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  SizedBox(
                                    width: 231,
                                    height: 231,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CustomPaint(
                                          size: const Size(231, 231),
                                          painter: QrDotPainter(
                                            data: _inviteLink.isEmpty ? "https://fliker.app" : _inviteLink,
                                            color: Colors.white,
                                            dotScale: 0.6, 
                                          ),
                                        ),
                                        
                                        Positioned(top: 0, left: 0, child: _buildCustomEye()),
                                        Positioned(top: 0, right: 0, child: _buildCustomEye()),
                                        Positioned(bottom: 0, left: 0, child: _buildCustomEye()),

                                        SvgPicture.asset(
                                          'assets/icons/qr_logo.svg', 
                                          width: 57, 
                                          height: 57
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Positioned(
                              top: 0,
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _bgColor, width: 4), 
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: Image.network(
                                    _avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      color: _actionBgColor,
                                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    AnimatedOpacity(
                      opacity: _showBadge ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 203,
                          height: 36, 
                          decoration: BoxDecoration(
                            color: _badgeBgColor, 
                            border: Border.all(color: _badgeBorderColor, width: 1), 
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, color: _successGreen, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _badgeText, 
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton(
                            'assets/icons/action_copy.svg', 
                            'Копировать', 
                            () => _triggerAction('Ссылка скопирована', () => Clipboard.setData(ClipboardData(text: _inviteLink)))
                          ),
                          const SizedBox(width: 32),
                          _buildActionButton(
                            'assets/icons/action_save.svg', 
                            'Сохранить', 
                            _saveQrCode
                          ),
                          const SizedBox(width: 32),
                          _buildActionButton(
                            'assets/icons/action_share.svg', 
                            'Поделиться', 
                            _shareLink
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCustomEye() {
    return SizedBox(
      width: 44, 
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5.0), 
            ),
          ),
          Transform.rotate(
            angle: pi / 4, 
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3), 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String iconPath, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _actionBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(iconPath, width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 12, 
            fontWeight: FontWeight.w500, 
            height: 18 / 12, 
          ),
        ),
      ],
    );
  }
} // <- Эта скобка терялась!

class QrDotPainter extends CustomPainter {
  final String data;
  final Color color;
  final double dotScale; 

  QrDotPainter({required this.data, required this.color, this.dotScale = 0.6});

  @override
  void paint(Canvas canvas, Size size) {
    final qrCode = QrCode(5, QrErrorCorrectLevel.Q)..addData(data);
    final qrImage = QrImage(qrCode);
    final int moduleCount = qrCode.moduleCount; 
    final double cellSize = size.width / moduleCount;
    final Paint paint = Paint()..color = color..style = PaintingStyle.fill;

    int centerModules = 10; 
    int centerStart = (moduleCount - centerModules) ~/ 2; 
    int centerEnd = centerStart + centerModules; 

    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (x < 7 && y < 7) continue; 
        if (x >= moduleCount - 7 && y < 7) continue; 
        if (x < 7 && y >= moduleCount - 7) continue; 

        if (x >= centerStart && x < centerEnd && y >= centerStart && y < centerEnd) {
          continue;
        }

        if (qrImage.isDark(y, x)) {
          canvas.drawCircle(
            Offset(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2),
            (cellSize / 2) * dotScale, 
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrDotPainter oldDelegate) => oldDelegate.data != data;
}