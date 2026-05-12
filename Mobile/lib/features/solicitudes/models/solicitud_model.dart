import '../../auth/models/user_model.dart';

class SolicitudModel {
  final String    id;
  final String    nombre;
  final String    correo;
  final String    telefono;
  final String    finalidad;
  final PaisModel pais;
  final String    estado;
  final DateTime  fechaCreacion;

  SolicitudModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.finalidad,
    required this.pais,
    required this.estado,
    required this.fechaCreacion,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    return SolicitudModel(
      id:           json['_id']        ?? '',
      nombre:       json['nombre']     ?? '',
      correo:       json['correo']     ?? '',
      telefono:     json['telefono']   ?? '',
      finalidad:    json['finalidad']  ?? '',
      pais:         PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
      estado:       json['estado']     ?? 'pendiente',
      fechaCreacion: DateTime.tryParse(json['fecha_creacion'] ?? '') ?? DateTime.now(),
    );
  }
}