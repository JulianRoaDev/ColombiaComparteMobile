import 'package:dio/dio.dart';
import '../models/noticia_model.dart';
import '../../../core/networks/dio_client.dart';

class NoticiasService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> listar({String? paisId}) async {
    try {
      final params = paisId != null ? {'pais': paisId} : null;
      final response = await _dio.get('/noticias', queryParameters: params);
      final lista =
          (response.data as List).map((e) => NoticiaModel.fromJson(e)).toList();
      return {'success': true, 'data': lista};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Error'
      };
    }
  }

  Future<Map<String, dynamic>> editar(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/noticias/$id', data: data);
      return {'success': true, 'data': NoticiaModel.fromJson(response.data)};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Error'
      };
    }
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/noticias', data: data);
      return {
        'success': true,
        'data': NoticiaModel.fromJson(response.data as Map<String, dynamic>)
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Error de conexión'
      };
    }
  }

  Future<Map<String, dynamic>> actualizar(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/noticias/$id', data: data);
      return {
        'success': true,
        'data': NoticiaModel.fromJson(response.data as Map<String, dynamic>)
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Error de conexión'
      };
    }
  }

  Future<Map<String, dynamic>> cambiarEstado(String id, String estado) async {
    try {
      await _dio.patch('/noticias/$id/estado', data: {'estado': estado});
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Error de conexión'
      };
    }
  }

  Future<Map<String, dynamic>> eliminar(String id) async {
    try {
      await _dio.delete('/noticias/$id');
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Error de conexión'
      };
    }
  }
}
