import '../../auth/models/user_model.dart';

class NoticiaModel {
  final String    id;
  final String    titulo;
  final String    resumen;
  final String    contenido;
  final String    autor;
  final String?   imagenUrl;
  final PaisModel pais;
  final String    estado;
  final DateTime  fechaCreacion;

  NoticiaModel({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.contenido,
    required this.autor,
    this.imagenUrl,
    required this.pais,
    required this.estado,
    required this.fechaCreacion,
  });

  factory NoticiaModel.fromJson(Map<String, dynamic> json) {
    return NoticiaModel(
      id:           json['_id']          ?? '',
      titulo:       json['titulo']       ?? '',
      resumen:      json['resumen']      ?? '',
      contenido:    json['contenido']    ?? '',
      autor:        json['autor']        ?? '',
      imagenUrl:    json['imagen_url'],
      pais:         PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
      estado:       json['estado']       ?? 'borrador',
      fechaCreacion: DateTime.tryParse(json['fecha_creacion'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'titulo':    titulo,
    'resumen':   resumen,
    'contenido': contenido,
    'autor':     autor,
    'imagen_url': imagenUrl,
    'pais':      pais.id,
    'estado':    estado,
  };
}