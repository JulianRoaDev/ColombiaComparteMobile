import '../../auth/models/user_model.dart';

class TestimonioModel {
  final String    id;
  final String    nombre;
  final String    fotoUrl;
  final String    testimonio;
  final PaisModel pais;
  final String?   instagramUrl;
  final String?   facebookUrl;
  final String    estado;
  final DateTime  fechaCreacion;

  TestimonioModel({
    required this.id,
    required this.nombre,
    required this.fotoUrl,
    required this.testimonio,
    required this.pais,
    this.instagramUrl,
    this.facebookUrl,
    required this.estado,
    required this.fechaCreacion,
  });

  factory TestimonioModel.fromJson(Map<String, dynamic> json) {
    return TestimonioModel(
      id:           json['_id']          ?? '',
      nombre:       json['nombre']       ?? '',
      fotoUrl:      json['foto_url']     ?? '',
      testimonio:   json['testimonio']   ?? '',
      pais:         PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
      instagramUrl: json['instagram_url'],
      facebookUrl:  json['facebook_url'],
      estado:       json['estado']       ?? 'borrador',
      fechaCreacion: DateTime.tryParse(json['fecha_creacion'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre':       nombre,
    'foto_url':     fotoUrl,
    'testimonio':   testimonio,
    'pais':         pais.id,
    'instagram_url': instagramUrl,
    'facebook_url':  facebookUrl,
    'estado':       estado,
  };
}