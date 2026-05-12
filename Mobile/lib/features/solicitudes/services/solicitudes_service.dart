import 'package:dio/dio.dart';
import '../models/solicitud_model.dart';
import '../../../core/networks/dio_client.dart';

class SolicitudesService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> listar({String? estado, String? pais}) async {
    try {
      final params = <String, String>{};
      if (estado != null) params['estado'] = estado;
      if (pais   != null) params['pais']   = pais;

      final response = await _dio.get('/solicitudes', queryParameters: params);
      final lista = (response.data as List)
          .map((e) => SolicitudModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return {'success': true, 'data': lista};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> detalle(String id) async {
    try {
      final response = await _dio.get('/solicitudes/$id');
      return {'success': true, 'data': SolicitudModel.fromJson(response.data as Map<String, dynamic>)};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> cambiarEstado(String id, String estado) async {
    try {
      await _dio.patch('/solicitudes/$id/estado', data: {'estado': estado});
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> eliminar(String id) async {
    try {
      await _dio.delete('/solicitudes/$id');
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error de conexión'};
    }
  }
}