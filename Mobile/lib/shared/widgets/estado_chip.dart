import 'package:flutter/material.dart';

class EstadoChip extends StatelessWidget {
  final String estado;
  const EstadoChip({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String estado) {
    switch (estado) {
      case 'pendiente':    return {'label': 'Pendiente',    'color': Colors.orange};
      case 'gestionada':   return {'label': 'Gestionada',   'color': Colors.blue};
      case 'respondida':   return {'label': 'Respondida',   'color': Colors.green};
      case 'publicado':    return {'label': 'Publicado',    'color': Colors.green};
      case 'borrador':     return {'label': 'Borrador',     'color': Colors.grey};
      case 'despublicado': return {'label': 'Despublicado', 'color': Colors.red};
      default:             return {'label': estado,         'color': Colors.grey};
    }
  }
}