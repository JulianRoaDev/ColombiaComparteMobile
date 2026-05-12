import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  String _rolLabel(String rol) {
    switch (rol) {
      case 'superadmin':  return 'Super Administrador';
      case 'admin_pais':  return 'Administrador de País';
      case 'editor':      return 'Editor';
      default:            return rol;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user        = context.watch<AuthProvider>().user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      user.nombre.isNotEmpty
                          ? user.nombre[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.nombre,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _rolLabel(user.rol),
                      style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Info ────────────────────────────────────────────────
                  _InfoCard(
                    children: [
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
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Log out ────────────────────────────────────────
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
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon,
              color: Theme.of(context).colorScheme.primary, size: 20),
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