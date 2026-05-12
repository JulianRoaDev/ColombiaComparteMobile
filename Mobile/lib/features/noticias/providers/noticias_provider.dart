import 'package:flutter/material.dart';
import '../models/noticia_model.dart';
import '../services/noticias_service.dart';
import '../../auth/models/user_model.dart';

enum NoticiasStatus { initial, loading, loaded, error }

class NoticiasProvider extends ChangeNotifier {
  final NoticiasService _service = NoticiasService();

  NoticiasStatus     _status = NoticiasStatus.initial;
  List<NoticiaModel> _noticias = [];
  String?            _errorMessage;
  PaisModel?         _filtroPais; // null = todos los países

  NoticiasStatus     get status       => _status;
  List<NoticiaModel> get noticias     => _noticias;
  String?            get errorMessage => _errorMessage;
  PaisModel?         get filtroPais   => _filtroPais;

  void setFiltroPais(PaisModel? pais) {
    _filtroPais = pais;
    cargar();
  }

  Future<void> cargar() async {
    _status = NoticiasStatus.loading;
    notifyListeners();
    final result = await _service.listar(paisId: _filtroPais?.id);
    if (result['success'] == true) {
      _noticias = result['data'] as List<NoticiaModel>;
      _status   = NoticiasStatus.loaded;
    } else {
      _errorMessage = result['message'];
      _status       = NoticiasStatus.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    final result = await _service.crear(data);
    if (result['success'] == true) {
      _noticias.insert(0, result['data'] as NoticiaModel);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> editar(String id, Map<String, dynamic> data) async {
    final result = await _service.editar(id, data);
    if (result['success'] == true) {
      final idx = _noticias.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _noticias[idx] = result['data'] as NoticiaModel;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> cambiarEstado(String id, String estado) async {
    final result = await _service.cambiarEstado(id, estado);
    if (result['success'] == true) {
      final idx = _noticias.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _noticias[idx] = result['data'] as NoticiaModel;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> eliminar(String id) async {
    final result = await _service.eliminar(id);
    if (result['success'] == true) {
      _noticias.removeWhere((n) => n.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}