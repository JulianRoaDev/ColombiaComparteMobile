import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/paises/providers/paises_provider.dart';
import 'features/solicitudes/providers/solicitudes_provider.dart';
import 'features/testimonios/providers/testimonios_provider.dart';
import 'features/noticias/providers/noticias_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaisesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SolicitudesProvider()),
        ChangeNotifierProvider(create: (_) => TestimoniosProvider()),
        ChangeNotifierProvider(create: (_) => NoticiasProvider()),
      ],
      child: const CmsApp(),
    ),
  );
}

class CmsApp extends StatefulWidget {
  const CmsApp({super.key});

  @override
  State<CmsApp> createState() => _CmsAppState();
}

class _CmsAppState extends State<CmsApp> {
  late AuthProvider _authProvider;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _router = AppRouter.createRouter(_authProvider); // ← una sola vez
    _authProvider.checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    // Solo observa para cambios de tema/locale, no recrea el router
    context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'CMS Latinoamérica Comparte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router, // ← siempre el mismo
    );
  }
}