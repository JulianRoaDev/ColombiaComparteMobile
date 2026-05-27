import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? fotoUrl;
  final String  nombre;
  final double  radius;

  const AvatarWidget({
    super.key,
    required this.nombre,
    this.fotoUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    final fallback = Text(
      initial,
      style: TextStyle(
        fontSize: radius * 0.75,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );

    final tieneUrl = fotoUrl != null && fotoUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: tieneUrl
          ? ClipOval(
              child: Image.network(
                fotoUrl!.trim(),
                width:  radius * 2,
                height: radius * 2,
                fit:    BoxFit.cover,
                errorBuilder:   (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
            )
          : fallback,
    );
  }
}