import 'package:dio/dio.dart';
import '../models/usuario_admin_model.dart';
import '../../../core/networks/dio_client.dart';

class UsuariosService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> listar() async {
    try {
      final response = await _dio.get('/usuarios');
      final lista = (response.data as List)
          .map((e) => UsuarioAdminModel.fromJson(e))
          .toList();
      return {'success': true, 'data': lista};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/usuarios', data: data);
      return {'success': true, 'data': UsuarioAdminModel.fromJson(response.data)};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> eliminar(String id) async {
    try {
      await _dio.delete('/usuarios/$id');
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error'};
    }
  }
}