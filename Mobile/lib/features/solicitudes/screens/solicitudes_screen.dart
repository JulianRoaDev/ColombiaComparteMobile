import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/solicitudes_provider.dart';
import '../models/solicitud_model.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/estado_chip.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});
  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudesProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Contacto'),
        actions: [
          // Filter by state
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por estado',
            onSelected: (val) {
              setState(() => _filtroEstado = val);
              context.read<SolicitudesProvider>().cargar(estado: val);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null,        child: Text('Todos')),
              const PopupMenuItem(value: 'pendiente', child: Text('Pendiente')),
              const PopupMenuItem(value: 'gestionada',child: Text('Gestionada')),
              const PopupMenuItem(value: 'respondida',child: Text('Respondida')),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<SolicitudesProvider>(
        builder: (context, provider, _) {
          if (provider.status == SolicitudesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == SolicitudesStatus.error) {
            return Center(child: Text(provider.errorMessage ?? 'Error'));
          }
          if (provider.solicitudes.isEmpty) {
            return const Center(child: Text('No hay solicitudes'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.cargar(estado: _filtroEstado),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.solicitudes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = provider.solicitudes[i];
                return _SolicitudCard(
                  solicitud: s,
                  onTap: () {
                    provider.seleccionar(s);
                    context.go('/solicitudes/${s.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudModel solicitud;
  final VoidCallback   onTap;
  const _SolicitudCard({required this.solicitud, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(solicitud.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(solicitud.finalidad, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                EstadoChip(estado: solicitud.estado),
                const SizedBox(width: 8),
                Text(solicitud.pais.nombre,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
      ),
    );
  }
}