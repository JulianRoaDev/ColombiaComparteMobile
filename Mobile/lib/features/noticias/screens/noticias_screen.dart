import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/noticias_provider.dart';
import '../models/noticia_model.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/estado_chip.dart';
import '../../../shared/widgets/filtro_pais_widget.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../features/auth/providers/auth_provider.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});
  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticiasProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Noticias')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/noticias/form'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: Consumer<NoticiasProvider>(
        builder: (context, provider, _) {
          if (provider.status == NoticiasStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.noticias.isEmpty) {
            return const Center(child: Text('No hay noticias'));
          }

          return RefreshIndicator(
            onRefresh: provider.cargar,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.noticias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contex, index) {
                final n = provider.noticias[index];
                final user = context.read<AuthProvider>().user!;

                final esPropietario = n.creador != null && n.creador == user.id;
                final esAdminOSuperAdmin =
                    user.isSuperAdmin || user.isAdminPais;

                final puedeCambiarEstado = esPropietario || esAdminOSuperAdmin;
                final puedeEditar = esPropietario || esAdminOSuperAdmin;
                final puedeEliminar = esPropietario || user.isSuperAdmin;

                return _NoticiaCard(
                  noticia: n,
                  puedeEliminar: puedeEliminar,
                  puedeEditar: puedeEditar,
                  puedeCambiarEstado: puedeCambiarEstado,
                  onToggleEstado: puedeCambiarEstado
                      ? () async {
                          final actual = provider.noticias.firstWhere(
                            (x) => x.id == n.id,
                            orElse: () => n,
                          );
                          final nuevoEstado = actual.estado == 'publicado'
                              ? 'borrador'
                              : 'publicado';
                          final ok =
                              await provider.cambiarEstado(n.id, nuevoEstado);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error al cambiar estado"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  onEditar: puedeEditar
                      ? () => context.push('/noticias/form', extra: n)
                      : null,
                  onEliminar: puedeEliminar
                      ? () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Eliminar noticia',
                            content: '¿Eliminar "${n.titulo}"?',
                            confirmText: 'Eliminar',
                          );
                          if (ok && context.mounted) provider.eliminar(n.id);
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NoticiaCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool puedeEliminar;
  final bool puedeEditar;
  final bool puedeCambiarEstado;
  final VoidCallback? onToggleEstado; // ← nullable
  final VoidCallback? onEditar; // ← nullable
  final VoidCallback? onEliminar;

  const _NoticiaCard({
    required this.noticia,
    required this.puedeEliminar,
    required this.puedeEditar,
    required this.puedeCambiarEstado,
    this.onToggleEstado,
    this.onEditar,
    this.onEliminar,
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
                Expanded(
                  child: Text(noticia.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                EstadoChip(estado: noticia.estado),
              ],
            ),
            const SizedBox(height: 6),
            Text(noticia.resumen,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(children: [
              Text('✍️ ${noticia.autor}', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              Text('🌍 ${noticia.pais.nombre}',
                  style: const TextStyle(fontSize: 12)),
            ]),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Toggle solo si tiene permisos
                if (puedeCambiarEstado && onToggleEstado != null)
                  TextButton.icon(
                    onPressed: onToggleEstado,
                    icon: Icon(
                      noticia.estado == 'publicado'
                          ? Icons.unpublished_outlined
                          : Icons.publish,
                      size: 18,
                    ),
                    label: Text(noticia.estado == 'publicado'
                        ? 'Despublicar'
                        : 'Publicar'),
                  ),
                if (puedeEditar && onEditar != null)
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEditar),
                if (puedeEliminar && onEliminar != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onEliminar,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
