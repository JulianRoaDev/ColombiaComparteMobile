import 'package:flutter/material.dart';
import '../models/solicitud_model.dart';
import '../services/solicitudes_service.dart';

enum SolicitudesStatus { initial, loading, loaded, error }

class SolicitudesProvider extends ChangeNotifier {
  final SolicitudesService _service = SolicitudesService();

  SolicitudesStatus        _status       = SolicitudesStatus.initial;
  List<SolicitudModel>     _solicitudes  = [];
  SolicitudModel?          _seleccionada;
  String?                  _errorMessage;
  String?                  _filtroEstado;

  SolicitudesStatus    get status        => _status;
  List<SolicitudModel> get solicitudes   => _solicitudes;
  SolicitudModel?      get seleccionada  => _seleccionada;
  String?              get errorMessage  => _errorMessage;
  String?              get filtroEstado  => _filtroEstado;

  Future<void> cargar({String? estado, String? pais}) async {
    _status = SolicitudesStatus.loading;
    notifyListeners();

    final result = await _service.listar(estado: estado, pais: pais);

    if (result['success'] == true) {
      _solicitudes = result['data'] as List<SolicitudModel>;
      _filtroEstado = estado;
      _status = SolicitudesStatus.loaded;
    } else {
      _errorMessage = result['message'] as String;
      _status = SolicitudesStatus.error;
    }
    notifyListeners();
  }

  Future<bool> cambiarEstado(String id, String estado) async {
    final result = await _service.cambiarEstado(id, estado);
    if (result['success'] == true) {
      await cargar(estado: _filtroEstado);
      return true;
    }
    return false;
  }

  Future<bool> eliminar(String id) async {
    final result = await _service.eliminar(id);
    if (result['success'] == true) {
      _solicitudes.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  void seleccionar(SolicitudModel solicitud) {
    _seleccionada = solicitud;
    notifyListeners();
  }
}