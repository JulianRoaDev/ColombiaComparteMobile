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
        onPressed: () => context.go('/noticias/nuevo'),
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
              itemBuilder: (_, i) {
                final n = provider.noticias[i];
                return _NoticiaCard(
                  noticia: n,
                  puedeEliminar: !user!.isEditor,
                  onEditar: () => context.go('/noticias/${n.id}/editar'),
                  onToggleEstado: () async {
                    final nuevoEstado =
                        n.estado == 'publicado' ? 'borrador' : 'publicado';
                    await provider.cambiarEstado(n.id, nuevoEstado);
                  },
                  onEliminar: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Eliminar noticia',
                      content: '¿Eliminar "${n.titulo}"?',
                    );
                    if (ok) await provider.eliminar(n.id);
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

class _NoticiaCard extends StatelessWidget {
  final NoticiaModel noticia;
  final bool puedeEliminar;
  final VoidCallback onEditar;
  final VoidCallback onToggleEstado;
  final VoidCallback onEliminar;

  const _NoticiaCard({
    required this.noticia,
    required this.puedeEliminar,
    required this.onEditar,
    required this.onToggleEstado,
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
            Text('🌍 ${noticia.pais.nombre}', style: const TextStyle(fontSize: 12)),
          ]),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onToggleEstado,
                icon: Icon(
                  noticia.estado == 'publicado'
                      ? Icons.unpublished_outlined
                      : Icons.publish,
                  size: 18,
                ),
                label: Text(
                    noticia.estado == 'publicado' ? 'Despublicar' : 'Publicar'),
              ),
              IconButton(
                  icon: const Icon(Icons.edit_outlined), onPressed: onEditar),
              if (puedeEliminar)
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
