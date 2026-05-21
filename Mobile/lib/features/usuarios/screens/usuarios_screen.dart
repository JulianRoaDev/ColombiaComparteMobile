import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/usuario_admin_model.dart';
import '../providers/usuarios_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuariosProvider>().cargar();
    });
  }

  String _rolLabel(String rol) {
    const map = {
      'superadmin':     'Super Admin',
      'admin_pais':     'Admin País',
      'editor':         'Editor',
      'usuario_general':'Usuario General',
    };
    return map[rol] ?? rol;
  }

  Color _rolColor(String rol) {
    switch (rol) {
      case 'superadmin':     return Colors.deepPurple;
      case 'admin_pais':     return Colors.blue;
      case 'editor':         return Colors.teal;
      case 'usuario_general':return Colors.orange;
      default:               return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/usuarios/form'),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: Consumer<UsuariosProvider>(
        builder: (context, provider, _) {
          if (provider.status == UsuariosStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == UsuariosStatus.error) {
            return Center(child: Text(provider.errorMessage ?? 'Error'));
          }
          if (provider.usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }

          return RefreshIndicator(
            onRefresh: provider.cargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.usuarios.length,
              itemBuilder: (context, index) {
                final u = provider.usuarios[index];
                final color = _rolColor(u.rol);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Text(
                        u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(u.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.correo, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(_rolLabel(u.rol),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (u.paisAsignado != null) ...[
                            const SizedBox(width: 8),
                            Text('🌍 ${u.paisAsignado!.nombre}',
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ]),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final ok = await showConfirmDialog(
                          context,
                          title: 'Eliminar usuario',
                          content: '¿Eliminar a ${u.nombre}?',
                          confirmText: 'Eliminar',
                        );
                        if (ok && context.mounted) {
                          provider.eliminar(u.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}