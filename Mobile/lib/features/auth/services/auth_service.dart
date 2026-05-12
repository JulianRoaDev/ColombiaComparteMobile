import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../../core/networks/dio_client.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  final Dio _dio = DioClient.instance;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ── Login ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String correo, String password) async {
    try {
      // Esta pta mrd no quiere loguear >:(
      print('>>> Intentando login a: ${_dio.options.baseUrl}/auth/login');
      print('>>> correo: $correo | password: $password');

      final response = await _dio.post(
        '/auth/login',
        data: {'correo': correo, 'password': password},
      );

      // 
      print('>>> Status: ${response.statusCode}');
      print('>>> Data: ${response.data}');

      final token = response.data['token'] as String;
      final usuarioJson = response.data['usuario'] as Map<String, dynamic>;

      // No entiendo pq dejó de loguear :)
      print('>>> Token recibido: ${token.substring(0, 20)}...');
      print('>>> Usuario: $usuarioJson');

      // Save token and user data securely
      await _storage.write(key: AppConstants.tokenKey, value: token);
      await _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(usuarioJson),
      );

      // Ya me mamé de escribir esto, pero es para asegurar que se guardó bien
      print('>>> Storage guardado OK');

      return {'success': true, 'user': UserModel.fromJson(usuarioJson)};
    } on DioException catch (e) {
      final mensaje =
          e.response?.data?['message'] ?? 'Error de conexión. Revisa tu red.';

      // Depurando ando con logs qleros
      print('>>> DioException tipo: ${e.type}');
      print('>>> DioException mensaje: ${e.message}');
      print('>>> DioException response: ${e.response?.data}');
      return {'success': false, 'message': mensaje};
    } catch (_) {
      return {
        'success': false,
        'message': 'Error inesperado. Intenta nuevamente.'
      };
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  // ── Verify if User is Logged In ──────────────────────────────────────────
  Future<UserModel?> getStoredUser() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      final userJson = await _storage.read(key: AppConstants.userKey);
      if (token == null || userJson == null) return null;
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
