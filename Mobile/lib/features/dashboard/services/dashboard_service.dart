import 'package:dio/dio.dart';
import '../models/dashboard_stats.dart';
import '../../../core/networks/dio_client.dart';

class DashboardService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      final data     = response.data as Map<String, dynamic>;
      final rol      = data['rol'] as String;

      if (rol == 'superadmin') {
        final statsJson = data['stats'] as List;
        return {
          'success': true,
          'data': DashboardStats(
            rol:          'superadmin',
            statsPorPais: statsJson
                .map((e) => PaisStats.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        };
      } else {
        return {
          'success': true,
          'data': DashboardStats(
            rol:       rol,
            statsPais: PaisStats.fromJson(data['stats'] as Map<String, dynamic>),
          ),
        };
      }
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? 'Error al cargar estadísticas';
      return {'success': false, 'message': mensaje};
    } catch (_) {
      return {'success': false, 'message': 'Error inesperado'};
    }
  }
}