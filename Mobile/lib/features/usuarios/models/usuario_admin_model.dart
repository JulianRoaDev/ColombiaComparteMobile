import '../../auth/models/user_model.dart';

class UsuarioAdminModel {
  final String    id;
  final String    nombre;
  final String    correo;
  final String    rol;
  final String?   fotoUrl;
  final PaisModel? paisAsignado;

  UsuarioAdminModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.fotoUrl,
    this.paisAsignado,
  });

  factory UsuarioAdminModel.fromJson(Map<String, dynamic> json) {
    return UsuarioAdminModel(
      id:     json['_id']    ?? '',
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol:    json['rol']    ?? '',
      fotoUrl: json['foto_url']?.toString(),
      paisAsignado: json['pais_asignado'] != null
          ? PaisModel.fromJson(json['pais_asignado'] as Map<String, dynamic>)
          : null,
    );
  }
}