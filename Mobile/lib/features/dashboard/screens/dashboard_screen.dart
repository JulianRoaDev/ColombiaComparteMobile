import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';
import '../../../shared/widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar estadísticas al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStats();
    });
  }

  Future<void> _confirmarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      context.read<DashboardProvider>().reset();
      await context.read<AuthProvider>().logout();
      // GoRouter redirige automáticamente al login
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().loadStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bienvenida ─────────────────────────────────────────────
              _WelcomeHeader(user: user),
              const SizedBox(height: 24),
              const SizedBox(height: 28),
              const _AccesoRapido(),

              // ── Contenido del dashboard según estado ───────────────────
              Consumer<DashboardProvider>(
                builder: (context, dashProvider, _) {
                  switch (dashProvider.status) {
                    case DashboardStatus.loading:
                    case DashboardStatus.initial:
                      return const _LoadingWidget();

                    case DashboardStatus.error:
                      return _ErrorWidget(
                        message:
                            dashProvider.errorMessage ?? 'Error desconocido',
                        onRetry: () => dashProvider.loadStats(),
                      );

                    case DashboardStatus.loaded:
                      final stats = dashProvider.stats!;
                      if (stats.rol == 'superadmin') {
                        return _SuperAdminDashboard(stats: stats);
                      } else {
                        return _PaisDashboard(stats: stats, rol: stats.rol);
                      }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Welcome header
// ─────────────────────────────────────────────────────────────────────────────
class _WelcomeHeader extends StatelessWidget {
  final UserModel? user;
  const _WelcomeHeader({this.user});

  String _rolLabel(String? rol) {
    switch (rol) {
      case 'superadmin':
        return 'Super Administrador';
      case 'admin_pais':
        return 'Administrador de País';
      case 'editor':
        return 'Editor';
      default:
        return 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido,',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.nombre ?? '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              _rolLabel(user?.rol),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            backgroundColor: colorScheme.secondaryContainer,
            padding: EdgeInsets.zero,
          ),
          if (user?.paisAsignado != null) ...[
            const SizedBox(height: 4),
            Text(
              '🌍 ${user!.paisAsignado!.nombre}',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: dashboard del superadmin (Countrie metrics)
// ─────────────────────────────────────────────────────────────────────────────
class _SuperAdminDashboard extends StatelessWidget {
  final DashboardStats stats;
  const _SuperAdminDashboard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen global',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...stats.statsPorPais!.map(
          (paisStat) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PaisCard(paisStat: paisStat),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: dashboard admin_pais / editor (Only stats of assigned country)
// ─────────────────────────────────────────────────────────────────────────────
class _PaisDashboard extends StatelessWidget {
  final DashboardStats stats;
  final String rol;
  const _PaisDashboard({required this.stats, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen — ${stats.statsPais!.pais.nombre}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _PaisCard(paisStat: stats.statsPais!),
        if (rol == 'editor') ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Como editor puedes crear y editar contenido, pero no eliminar ni administrar usuarios.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: stadistics taget by country
// ─────────────────────────────────────────────────────────────────────────────
class _PaisCard extends StatelessWidget {
  final PaisStats paisStat;
  const _PaisCard({required this.paisStat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del país
          Row(
            children: [
              Icon(Icons.flag, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                paisStat.pais.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  paisStat.pais.codigo,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid de métricas
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.inbox_outlined,
                  label: 'Solicitudes pendientes',
                  value: paisStat.solicitudesPendientes.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: Icons.star_outline,
                  label: 'Testimonios publicados',
                  value: paisStat.testimoniosPublicados.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: Icons.article_outlined,
                  label: 'Noticias activas',
                  value: paisStat.noticiasActivas.toString(),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: tile de una métrica individual
// ─────────────────────────────────────────────────────────────────────────────
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  const _AccesoRapido();

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AuthProvider>().user?.rol ?? '';

    final items = [
      if (rol == 'superadmin')
        const _AccesoItem(
            Icons.flag_outlined, 'Países', '/paises', const Color(0xFF9D4EDD)),
      if (rol != 'editor')
        const _AccesoItem(
            Icons.inbox_outlined, 'Solicitudes', '/solicitudes', Colors.orange),
      const _AccesoItem(
          Icons.star_outline, 'Testimonios', '/testimonios', Colors.green),
      const _AccesoItem(
          Icons.article_outlined, 'Noticias', '/noticias', Colors.blue),
      const _AccesoItem(
          Icons.person_outline, 'Mi perfil', '/perfil', const Color(0xFF7B2CBF)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acceso rápido',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: items.map((item) => _AccesoCard(item: item)).toList(),
        ),
      ],
    );
  }
}

class _AccesoItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _AccesoItem(this.icon, this.label, this.route, this.color);
}

class _AccesoCard extends StatelessWidget {
  final _AccesoItem item;
  const _AccesoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(item.route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 28),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: item.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
