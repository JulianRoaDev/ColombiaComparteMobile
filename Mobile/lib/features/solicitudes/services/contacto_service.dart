import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';

class ContactoService {
  // Clean Dio, Whitout interceptor JWT
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // GET /paises/publico — not auth
  Future<List<Map<String, dynamic>>> obtenerPaises() async {
    try {
      final response = await _dio.get('/paises/publico');
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (_) {
      return [];
    }
  }

  // POST /solicitudes — not auth
  Future<Map<String, dynamic>> enviarSolicitud({
    required String nombre,
    required String correo,
    required String telefono,
    required String finalidad,
    required String paisId,
  }) async {
    try {
      await _dio.post('/solicitudes', data: {
        'nombre':   nombre,
        'correo':   correo,
        'telefono': telefono,
        'finalidad':finalidad,
        'pais':     paisId,
      });
      return {'success': true};
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Error de conexión';
      return {'success': false, 'message': msg};
    }
  }
}