import '../../auth/models/user_model.dart';

// Estadistics for only one country (admin_pais and editor)
class PaisStats {
  final PaisModel pais;
  final int solicitudesPendientes;
  final int testimoniosPublicados;
  final int noticiasActivas;

  PaisStats({
    required this.pais,
    required this.solicitudesPendientes,
    required this.testimoniosPublicados,
    required this.noticiasActivas,
  });

  factory PaisStats.fromJson(Map<String, dynamic> json) {
    return PaisStats(
      pais:                    PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
      solicitudesPendientes:   json['solicitudesPendientes']   ?? 0,
      testimoniosPublicados:   json['testimoniosPublicados']   ?? 0,
      noticiasActivas:         json['noticiasActivas']         ?? 0,
    );
  }
}

// Contenedor del dashboard completo
class DashboardStats {
  final String rol;
  final List<PaisStats>? statsPorPais; // Solo superadmin
  final PaisStats?       statsPais;   // admin_pais y editor

  DashboardStats({
    required this.rol,
    this.statsPorPais,
    this.statsPais,
  });
}