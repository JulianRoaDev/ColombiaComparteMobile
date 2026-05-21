import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _editando = false;
  final _nombreCtrl = TextEditingController();
  final _fotoCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fotoCtrl.dispose();
    super.dispose();
  }

  void _iniciarEdicion(UserModel user) {
    _nombreCtrl.text = user.nombre;
    _fotoCtrl.text = user.fotoUrl ?? '';
    setState(() => _editando = true);
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) return;

    final fotoUrlText = _fotoCtrl.text.trim();
    if (fotoUrlText.isNotEmpty && !_isValidPhotoUrl(fotoUrlText)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La URL de la foto debe ser válida y usar http/https'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _guardando = true);

    try {
      // if fotoUrlText is empty, we want to send null to the backend to indicate "no change"
      final currentUser = context.read<AuthProvider>().user;
      final fotoFinal =
          fotoUrlText.isEmpty ? currentUser?.fotoUrl : fotoUrlText;

      final ok = await context.read<AuthProvider>().actualizarPerfil(
            nombre: _nombreCtrl.text.trim(),
            fotoUrl: fotoFinal,
          );
      if (mounted) {
        setState(() {
          _guardando = false;
          _editando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Perfil actualizado' : 'Error al actualizar'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _guardando = false);
    }
  }

  bool _isValidPhotoUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _rolLabel(String rol) {
    const map = {
      'superadmin': 'Super Administrador',
      'admin_pais': 'Administrador de País',
      'editor': 'Editor',
      'usuario_general': 'Usuario General',
    };
    return map[rol] ?? rol;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          if (user != null && !_editando)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
              onPressed: () => _iniciarEdicion(user),
            ),
          if (_editando)
            TextButton(
              onPressed: () => setState(() {
                _editando = false;
                _guardando = false;
              }),
              child: const Text('Cancelar'),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  // Reemplaza todo el Stack del avatar por esto:
                  _AvatarWidget(
                    fotoUrl: user.fotoUrl,
                    nombre: user.nombre,
                    radius: 48,
                  ),
                  const SizedBox(height: 16),

                  if (!_editando) ...[
                    // ── Vista normal ──────────────────────────────────────
                    Text(user.nombre,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_rolLabel(user.rol),
                          style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 32),
                    _InfoCard(children: [
                      _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Correo',
                          value: user.correo),
                      const Divider(height: 1),
                      _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Rol',
                          value: _rolLabel(user.rol)),
                      if (user.paisAsignado != null) ...[
                        const Divider(height: 1),
                        _InfoRow(
                            icon: Icons.flag_outlined,
                            label: 'País asignado',
                            value: user.paisAsignado!.nombre),
                      ],
                    ]),
                  ] else ...[
                    // ── Modo edición ──────────────────────────────────────
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fotoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL de foto de perfil (opcional)',
                        prefixIcon: Icon(Icons.photo_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Preview de la foto si hay URL
                    AnimatedBuilder(
                      animation: _fotoCtrl,
                      builder: (context, _) {
                        final url = _fotoCtrl.text.trim();
                        if (url.isEmpty) return const SizedBox();
                        if (!_isValidPhotoUrl(url)) {
                          return Column(
                            children: [
                              Text(
                                  'URL inválida — debe comenzar con http/https',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 12)),
                              const SizedBox(height: 8),
                              _AvatarWidget(
                                  fotoUrl: null,
                                  nombre: user.nombre,
                                  radius: 36),
                            ],
                          );
                        }
                        return _AvatarWidget(
                            fotoUrl: url, nombre: user.nombre, radius: 36);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _guardando ? null : _guardar,
                        child: _guardando
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : const Text('Guardar cambios'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Cerrar sesión ─────────────────────────────────────
                  if (!_editando)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión',
                            style: TextStyle(fontSize: 16)),
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Cerrar sesión',
                            content: '¿Estás seguro?',
                            confirmText: 'Cerrar sesión',
                          );
                          if (ok && context.mounted) {
                            context.read<DashboardProvider>().reset();
                            await context.read<AuthProvider>().logout();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String? fotoUrl;
  final String nombre;
  final double radius;

  const _AvatarWidget({
    required this.fotoUrl,
    required this.nombre,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final fallback = Text(
      initial,
      style: TextStyle(
        fontSize: radius * 0.83,
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
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                // Si la imagen falla → muestra la inicial
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child; // cargó
                  return CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  );
                },
              ),
            )
          : fallback,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
