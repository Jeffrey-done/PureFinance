import 'package:flutter/material.dart';

class CategoryIconWidget extends StatelessWidget {
  final String? iconCode;
  final String? colorHex;
  final double size;

  const CategoryIconWidget({
    super.key,
    this.iconCode,
    this.colorHex,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(colorHex) ?? Theme.of(context).colorScheme.primaryContainer;
    final icon = _parseIcon(iconCode);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: bgColor,
        size: size * 0.5,
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final hexStr = hex.replaceFirst('#', '');
    if (hexStr.length == 6) {
      return Color(int.parse('FF$hexStr', radix: 16));
    }
    return null;
  }

  IconData _parseIcon(String? code) {
    if (code == null || code.isEmpty) return Icons.category;
    try {
      final codePoint = int.parse(code);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.category;
    }
  }
}
