import 'package:flutter/material.dart';
import '../models/testimonio_model.dart';
import '../services/testimonios_services.dart';
import '../../auth/models/user_model.dart';

enum TestimoniosStatus { initial, loading, loaded, error }

class TestimoniosProvider extends ChangeNotifier {
  final TestimoniosService _service = TestimoniosService();

  TestimoniosStatus     _status = TestimoniosStatus.initial;
  List<TestimonioModel> _testimonios = [];
  String?               _errorMessage;
  PaisModel?            _filtroPais;

  TestimoniosStatus     get status       => _status;
  List<TestimonioModel> get testimonios  => _testimonios;
  String?               get errorMessage => _errorMessage;
  PaisModel?            get filtroPais   => _filtroPais;

  void setFiltroPais(PaisModel? pais) {
    _filtroPais = pais;
    cargar();
  }

  Future<void> cargar() async {
    _status = TestimoniosStatus.loading;
    notifyListeners();
    final result = await _service.listar(paisId: _filtroPais?.id);
    if (result['success'] == true) {
      _testimonios = result['data'] as List<TestimonioModel>;
      _status      = TestimoniosStatus.loaded;
    } else {
      _errorMessage = result['message'];
      _status       = TestimoniosStatus.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    final result = await _service.crear(data);
    if (result['success'] == true) {
      _testimonios.insert(0, result['data'] as TestimonioModel);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> editar(String id, Map<String, dynamic> data) async {
    final result = await _service.editar(id, data);
    if (result['success'] == true) {
      final idx = _testimonios.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _testimonios[idx] = result['data'] as TestimonioModel;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> cambiarEstado(String id, String estado) async {
    final result = await _service.cambiarEstado(id, estado);
    if (result['success'] == true) {
      final idx = _testimonios.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _testimonios[idx] = result['data'] as TestimonioModel;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> eliminar(String id) async {
    final result = await _service.eliminar(id);
    if (result['success'] == true) {
      _testimonios.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}