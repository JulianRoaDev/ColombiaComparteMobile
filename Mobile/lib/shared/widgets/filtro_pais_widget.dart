import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/paises/providers/paises_provider.dart';

class FiltroPaisWidget extends StatelessWidget {
  final PaisModel?              valorActual;
  final ValueChanged<PaisModel?> onCambio;

  const FiltroPaisWidget({
    super.key,
    required this.valorActual,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    final paises = context.watch<PaisesProvider>().paises;

    return PopupMenuButton<PaisModel?>(
      tooltip: 'Filtrar por país',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.filter_list),
          if (valorActual != null)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  valorActual!.codigo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      onSelected: onCambio,
      itemBuilder: (_) => [
        const PopupMenuItem<PaisModel?>(
          value: null,
          child: Text('Todos los países'),
        ),
        ...paises.map(
          (p) => PopupMenuItem<PaisModel?>(
            value: p,
            child: Text(p.nombre),
          ),
        ),
      ],
    );
  }
}