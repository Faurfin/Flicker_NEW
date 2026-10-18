import 'package:flutter/material.dart';

/// Цветовая палитра дизайн-системы «Фликер»
abstract final class AppColors {
  // Обязательные константы по ТЗ
  static const Color black = Color(0xFF0A0A0A); // Основной черный Base/Black
  static const Color brand900 = Color(0xFFC3F032); // Акцентный салатовый Brand/900
  static const Color white = Color(0xFFFFFFFF); // Основной белый Base/White
  static const Color strokeDark = Color(0xFF414141); // Обводка главного аватара

  // Дополнительные цвета из текущего кода проекта (AlienProfileScreen / MainScreen)
  static const Color strokeCard = Color(0xFF1D1D1D); // Обводка блока друзей и табов
  static const Color textGray = Color(0xFF8E8E93); // Второстепенный серый текст

  // Дизайн-токены из макета профиля Figma (Node 868:10430)
  static const Color brandPrimary = Color(0xFFBDE038); // Акцентный салатовый (#BDE038)
  static const Color bgDark = Color(0xFF090B08); // Фон экрана (#090B08)
  static const Color darkCharcoal = Color(0xFF151714); // Тёмный разделитель и текст кнопок (#151714)
  static const Color textMuted = Color(0xFF7B7B7B); // Серый текст био и неактивных табов (#7B7B7B)
  static const Color textFriends = Color(0xFF8B8D98); // Цвет счетчика друзей (#8B8D98)
  static const Color badgeStroke = Color(0xFF2C2C2C); // Обводка бейджа друзей (#2C2C2C)
  static const Color badgeText = Color(0xFFB9BBC6); // Текст бейджа друзей (#B9BBC6)
}