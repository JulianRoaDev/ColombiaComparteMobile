class PaisModel {
  final String id;
  final String nombre;
  final String codigo;

  PaisModel({
    required this.id,
    required this.nombre,
    required this.codigo,
  });

  factory PaisModel.fromJson(Map<String, dynamic> json) {
    return PaisModel(
      id:     json['_id']    ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':    id,
    'nombre': nombre,
    'codigo': codigo,
  };
}

// ─────────────────────────────────────────────────────────────

class UserModel {
  final String    id;
  final String    nombre;
  final String    correo;
  final String    rol;
  final PaisModel? paisAsignado;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.paisAsignado,
  });

  // Helpers de rol
  bool get isSuperAdmin => rol == 'superadmin';
  bool get isAdminPais  => rol == 'admin_pais';
  bool get isEditor     => rol == 'editor';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:     json['id']     ?? '',
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol:    json['rol']    ?? '',
      paisAsignado: json['pais_asignado'] != null
          ? PaisModel.fromJson(json['pais_asignado'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'nombre':       nombre,
    'correo':       correo,
    'rol':          rol,
    'pais_asignado': paisAsignado?.toJson(),
  };
}