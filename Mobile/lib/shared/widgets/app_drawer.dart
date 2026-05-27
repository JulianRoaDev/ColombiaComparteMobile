import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/theme/theme_provider.dart';
import 'confirm_dialog.dart';
import 'avatar_widget.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    String currentRoute = '/dashboard';
    try {
      currentRoute = GoRouterState.of(context).uri.toString();
    } catch (_) {}

    return NavigationDrawer(
      children: [
        // ── Header ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(
                fotoUrl: user.fotoUrl,
                nombre: user.nombre,
                radius: 28,
              ),
              const SizedBox(height: 12),
              Text(user.nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(user.correo,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13)),
              if (user.paisAsignado != null) ...[
                const SizedBox(height: 4),
                Text('🌍 ${user.paisAsignado!.nombre}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            tooltip: themeProvider.isDarkMode ? 'Modo claro' : 'Modo oscuro',
            onPressed: themeProvider.toggle,
          ),
        ),

        const Divider(indent: 16, endIndent: 16),

        // ── Navigation items ────────────────────────────────────────────
        const _DrawerItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          route: '/dashboard',
        ),

        // Only SuperAdmin can see the "Países" section
        if (user.isSuperAdmin)
          const _DrawerItem(
            icon: Icons.flag_outlined,
            label: 'Países',
            route: '/paises',
          ),

        // Only SuperAdmin can see the "Usuarios" section, since only they can manage users
        if (user.isSuperAdmin)
          const _DrawerItem(
            icon: Icons.manage_accounts_outlined,
            label: 'Usuarios',
            route: '/usuarios',
          ),

        // SuperAdmin and admin can see "Solicitudes", but editors cannot
        if (!user.isEditor && !user.isUsuarioGeneral)
          const _DrawerItem(
            icon: Icons.inbox_outlined,
            label: 'Solicitudes',
            route: '/solicitudes',
          ),

        // Testimonios and noticias are visible for all roles
        const _DrawerItem(
          icon: Icons.star_outline,
          label: 'Testimonios',
          route: '/testimonios',
        ),
        const _DrawerItem(
          icon: Icons.article_outlined,
          label: 'Noticias',
          route: '/noticias',
        ),
        const _DrawerItem(
          icon: Icons.person_outline,
          label: 'Mi perfil',
          route: '/perfil',
        ),
        const _DrawerItem(
          icon: Icons.contact_mail_outlined,
          label: 'Formulario público',
          route: '/contacto',
        ),

        const Divider(indent: 16, endIndent: 16),

        // ── Log out ──────────────────────────────────────────────────
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title:
              const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          onTap: () async {
            // Navigator.of(context).pop(); // close drawer
            final confirmar = await showConfirmDialog(
              context,
              title: 'Cerrar sesión',
              content: '¿Estás seguro?',
              confirmText: 'Cerrar sesión',
            );
            if (confirmar && context.mounted) {
              context.read<DashboardProvider>().reset();
              await context.read<AuthProvider>().logout();
            }
          },
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
                  isSelected ? Theme.of(context).colorScheme.primary : null)),
      selected: isSelected,
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        context.go(route);
      },
    );
  }
}
