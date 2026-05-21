import 'package:flutter/material.dart';
import '../models/usuario_admin_model.dart';
import '../services/usuarios_service.dart';

enum UsuariosStatus { initial, loading, loaded, error }

class UsuariosProvider extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  UsuariosStatus        _status = UsuariosStatus.initial;
  List<UsuarioAdminModel> _usuarios = [];
  String?               _errorMessage;

  UsuariosStatus          get status       => _status;
  List<UsuarioAdminModel> get usuarios     => _usuarios;
  String?                 get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _status = UsuariosStatus.loading;
    notifyListeners();
    final result = await _service.listar();
    if (result['success'] == true) {
      _usuarios = result['data'] as List<UsuarioAdminModel>;
      _status   = UsuariosStatus.loaded;
    } else {
      _errorMessage = result['message'];
      _status       = UsuariosStatus.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    final result = await _service.crear(data);
    if (result['success'] == true) {
      _usuarios.insert(0, result['data'] as UsuarioAdminModel);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> eliminar(String id) async {
    final result = await _service.eliminar(id);
    if (result['success'] == true) {
      _usuarios.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}