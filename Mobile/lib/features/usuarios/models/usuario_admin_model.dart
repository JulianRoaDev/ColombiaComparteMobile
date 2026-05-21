import '../../auth/models/user_model.dart';

class UsuarioAdminModel {
  final String    id;
  final String    nombre;
  final String    correo;
  final String    rol;
  final PaisModel? paisAsignado;

  UsuarioAdminModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.paisAsignado,
  });

  factory UsuarioAdminModel.fromJson(Map<String, dynamic> json) {
    return UsuarioAdminModel(
      id:     json['_id']    ?? '',
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol:    json['rol']    ?? '',
      paisAsignado: json['pais_asignado'] != null
          ? PaisModel.fromJson(json['pais_asignado'] as Map<String, dynamic>)
          : null,
    );
  }
}