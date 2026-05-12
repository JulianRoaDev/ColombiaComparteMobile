import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/testimonios_provider.dart';
import '../models/testimonio_model.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/estado_chip.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/filtro_pais_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';

class TestimoniosScreen extends StatefulWidget {
  const TestimoniosScreen({super.key});
  @override
  State<TestimoniosScreen> createState() => _TestimoniosScreenState();
}

class _TestimoniosScreenState extends State<TestimoniosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestimoniosProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AuthProvider>().user?.rol ?? '';
    final provider = context.watch<TestimoniosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testimonios'),
        actions: [
          if (rol == 'superadmin')
            FiltroPaisWidget(
              valorActual: provider.filtroPais,
              onCambio: provider.setFiltroPais,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/testimonios/form'),
        child: const Icon(Icons.add),
      ),
      body: Consumer<TestimoniosProvider>(
        builder: (context, prov, _) {
          if (prov.status == TestimoniosStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.status == TestimoniosStatus.error) {
            return Center(child: Text(prov.errorMessage ?? 'Error'));
          }
          if (prov.testimonios.isEmpty) {
            return const Center(child: Text('No hay testimonios'));
          }
          return RefreshIndicator(
            onRefresh: prov.cargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.testimonios.length,
              itemBuilder: (context, index) {
                final t = prov.testimonios[index];
                final estados = ['borrador', 'publicado', 'despublicado'];
                final siguiente =
                    estados[(estados.indexOf(t.estado) + 1) % estados.length];
                return _TestimonioCard(
                  testimonio: t,
                  onCambiarEstado: () => prov.cambiarEstado(t.id, siguiente),
                  onEditar: () => context.go('/testimonios/form', extra: t),
                  puedeEliminar: rol != 'editor',
                  onEliminar: () async {
                    final ok = await showConfirmDialog(context,
                        title: 'Eliminar testimonio',
                        content: '¿Eliminar a ${t.nombre}?',
                        confirmText: 'Eliminar');
                    if (ok) prov.eliminar(t.id);
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

class _TestimonioCard extends StatelessWidget {
  final TestimonioModel testimonio;
  final bool puedeEliminar;
  final VoidCallback onEditar;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;

  const _TestimonioCard({
    required this.testimonio,
    required this.puedeEliminar,
    required this.onEditar,
    required this.onCambiarEstado,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(testimonio.fotoUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(testimonio.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(testimonio.pais.nombre,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                EstadoChip(estado: testimonio.estado),
              ],
            ),
            const SizedBox(height: 10),
            Text(testimonio.testimonio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),

            // Acciones
            Row(
              children: [
                Flexible(
                  // ← agregar Flexible
                  child: DropdownButton<String>(
                    value: testimonio.estado,
                    isDense: true,
                    underline: const SizedBox(),
                    isExpanded: true, // ← agregar isExpanded
                    items: ['borrador', 'publicado', 'despublicado']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) onCambiarEstado();
                    },
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEditar,
                  tooltip: 'Editar',
                ),
                if (puedeEliminar)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onEliminar,
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
