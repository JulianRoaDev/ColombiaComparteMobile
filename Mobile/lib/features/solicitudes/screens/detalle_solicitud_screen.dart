import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/solicitudes_provider.dart';
import '../../../shared/widgets/estado_chip.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class DetalleSolicitudScreen extends StatelessWidget {
  final String solicitudId;
  const DetalleSolicitudScreen({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context) {
    final provider   = context.watch<SolicitudesProvider>();
    final solicitud  = provider.seleccionada;

    if (solicitud == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Solicitud no disponible')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Solicitud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'Eliminar solicitud',
                content: '¿Eliminar la solicitud de ${solicitud.nombre}? Esta acción no se puede deshacer.',
              );
              if (ok && context.mounted) {
                final eliminado = await provider.eliminar(solicitud.id);
                if (eliminado && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Solicitud eliminada')),
                  );
                  context.go('/solicitudes');
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(solicitud.nombre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                EstadoChip(estado: solicitud.estado),
              ],
            ),
            const SizedBox(height: 20),

            // Datos
            _Campo(label: 'Correo',    value: solicitud.correo),
            _Campo(label: 'Teléfono',  value: solicitud.telefono),
            _Campo(label: 'Finalidad', value: solicitud.finalidad),
            _Campo(label: 'País',      value: solicitud.pais.nombre),
            _Campo(label: 'Fecha',
                value: '${solicitud.fechaCreacion.day}/${solicitud.fechaCreacion.month}/${solicitud.fechaCreacion.year}'),
            const SizedBox(height: 28),

            // Cambiar estado
            Text('Cambiar estado',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: ['pendiente', 'gestionada', 'respondida'].map((e) {
                final isActual = solicitud.estado == e;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.tonal(
                    onPressed: isActual
                        ? null
                        : () async {
                            await provider.cambiarEstado(solicitud.id, e);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Estado actualizado a "$e"')),
                              );
                              context.go('/solicitudes');
                            }
                          },
                    child: Text(e),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final String value;
  const _Campo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
          const Divider(),
        ],
      ),
    );
  }
}