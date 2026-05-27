import 'package:flutter/material.dart';

class EstadoChip extends StatelessWidget {
  final String estado;
  const EstadoChip({super.key, required this.estado});

  _BadgeStyle get _style {
    switch (estado) {
      case 'publicado':
        return _BadgeStyle(
            bg: const Color(0xFFD4EDDA), text: const Color(0xFF1A6B2A));
      case 'pendiente':
        return _BadgeStyle(
            bg: const Color(0xFFFFF3CD), text: const Color(0xFF7A5A00));
      case 'gestionada':
        return _BadgeStyle(
            bg: const Color(0xFFD5E8F5), text: const Color(0xFF0B4F8A));
      case 'respondida':
        return _BadgeStyle(
            bg: const Color(0xFFE8D5F5), text: const Color(0xFF5A189A));
      case 'despublicado':
        return _BadgeStyle(
            bg: const Color(0xFFF0F0F0), text: const Color(0xFF666666));
      case 'borrador':
        return _BadgeStyle(
            bg: const Color(0xFFFFF0E0), text: const Color(0xFF7A4A00));
      default:
        return _BadgeStyle(
            bg: const Color(0xFFF0F0F0), text: const Color(0xFF666666));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color:        s.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color:       s.text,
          fontSize:    11,
          fontWeight:  FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  final Color bg;
  final Color text;
  const _BadgeStyle({required this.bg, required this.text});
}