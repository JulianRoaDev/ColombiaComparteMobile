import 'package:dio/dio.dart';
import '../../../core/networks/dio_client.dart';
import '../../auth/models/user_model.dart';

class PaisesService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> listar() async {
    try {
      final response = await _dio.get('/paises');
      final paises = (response.data as List)
          .map((e) => PaisModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return {'success': true, 'data': paises};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error de conexión'};
    }
  }
}