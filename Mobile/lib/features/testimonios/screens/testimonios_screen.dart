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
                final user = context.read<AuthProvider>().user!;

                // ¿El usuario actual es dueño de este testimonio?
                // creador viene del backend como String en el JSON
                final esPropietario = t.creador != null && t.creador == user.id;
                final esAdminOSuperAdmin =
                    user.isSuperAdmin || user.isAdminPais;

                // Puede cambiar estado si es admin/superadmin O si es el dueño
                final puedeCambiarEstado = esAdminOSuperAdmin || esPropietario;

                // Puede editar si es admin/superadmin O si es el dueño
                final puedeEditar = esAdminOSuperAdmin || esPropietario;

                // Puede eliminar solo admins (no editor ni usuario_general)
                final puedeEliminar = esAdminOSuperAdmin;

                return _TestimonioCard(
                  testimonio: t,
                  puedeEliminar: puedeEliminar,
                  puedeCambiarEstado: puedeCambiarEstado,
                  puedeEditar: puedeEditar,
                  onCambiarEstado: puedeCambiarEstado
                      ? (nuevoEstado) async {
                          final ok =
                              await prov.cambiarEstado(t.id, nuevoEstado);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al cambiar estado'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : (_) {},
                  onEditar: puedeEditar
                      ? () => context.push('/testimonios/form', extra: t)
                      : () {},
                  onEliminar: puedeEliminar
                      ? () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Eliminar testimonio',
                            content: '¿Eliminar a ${t.nombre}?',
                            confirmText: 'Eliminar',
                          );
                          if (ok && context.mounted) prov.eliminar(t.id);
                        }
                      : () {},
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
  final bool puedeEditar;
  final bool puedeCambiarEstado;
  final Function(String) onCambiarEstado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TestimonioCard({
    required this.testimonio,
    required this.puedeEliminar,
    required this.puedeEditar,
    required this.puedeCambiarEstado,
    required this.onCambiarEstado,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                // Dropdown de estado — solo si tiene permisos
                if (puedeCambiarEstado)
                  Flexible(
                    child: DropdownButton<String>(
                      value: testimonio.estado,
                      isDense: true,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['borrador', 'publicado', 'despublicado']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) onCambiarEstado(val);
                      },
                    ),
                  ),
                const Spacer(),
                // Editar — solo si tiene permisos
                if (puedeEditar)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEditar,
                    tooltip: 'Editar',
                  ),
                // Eliminar — solo admins
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
