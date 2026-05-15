import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latinoamerica_comparte_admin/features/noticias/models/noticia_model.dart';
import 'package:latinoamerica_comparte_admin/features/testimonios/models/testimonio_model.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/paises/screens/paises_screen.dart';
import '../features/solicitudes/screens/solicitudes_screen.dart';
import '../features/solicitudes/screens/detalle_solicitud_screen.dart';
import '../features/solicitudes/screens/contacto_publico_screen.dart';
import '../features/testimonios/screens/testimonios_screen.dart';
import '../features/testimonios/screens/formulario_testimonio_screen.dart';
import '../features/noticias/screens/noticias_screen.dart';
import '../features/noticias/screens/formulario_noticia_screen.dart';
import '../features/perfil/screens/perfil_screen.dart';

// Routes that can be accessed without authentication
const _rutasPublicas = ['/login', '/contacto'];

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuth = authProvider.isAuthenticated;
        final isLoading = authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading;
        final ruta = state.matchedLocation;

        if (isLoading) return null;

        if (isAuth && ruta == '/login') return '/dashboard';

        final esPublica = _rutasPublicas
            .where((r) => r != '/login')
            .any((r) => ruta.startsWith(r));
        if (esPublica) return null;

        if (!isAuth) return '/login';

        final user = authProvider.user;
        if (ruta == '/paises' && user?.rol != 'superadmin') return '/dashboard';
        if (ruta.startsWith('/solicitudes') && user?.rol == 'editor')
          return '/dashboard';

        return null;
      },
      routes: [
        // ── Publics ────────────────────────────────────────────────────
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/contacto',
          builder: (_, __) => const ContactoPublicoScreen(),
        ),

        // ── Proetcted ──────────────────────────────────────────────────
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/perfil',
          builder: (_, __) => const PerfilScreen(),
        ),
        GoRoute(
          path: '/paises',
          builder: (_, __) => const PaisesScreen(),
        ),
        GoRoute(
          path: '/solicitudes',
          builder: (_, __) => const SolicitudesScreen(),
        ),
        GoRoute(
          path: '/solicitudes/:id',
          builder: (_, state) =>
              DetalleSolicitudScreen(solicitudId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/testimonios',
          builder: (_, __) => const TestimoniosScreen(),
        ),
        GoRoute(
          path: '/testimonios/form',
          builder: (_, state) =>
              FormularioTestimonioScreen(testimonio: state.extra as TestimonioModel?),
        ),
        GoRoute(
          path: '/noticias',
          builder: (_, __) => const NoticiasScreen(),
        ),
        GoRoute(
          path: '/noticias/form',
          builder: (_, state) =>
              FormularioNoticiaScreen(noticia: state.extra as NoticiaModel?),
        ),
      ],
    );
  }
}
