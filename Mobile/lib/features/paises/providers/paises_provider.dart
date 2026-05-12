import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../services/paises_service.dart';

enum PaisesStatus { initial, loading, loaded, error }

class PaisesProvider extends ChangeNotifier {
  final PaisesService _service = PaisesService();

  PaisesStatus    _status = PaisesStatus.initial;
  List<PaisModel> _paises = [];
  String?         _errorMessage;

  PaisesStatus    get status       => _status;
  List<PaisModel> get paises       => _paises;
  String?         get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _status = PaisesStatus.loading;
    notifyListeners();

    final result = await _service.listar();
    if (result['success'] == true) {
      _paises = result['data'] as List<PaisModel>;
      _status = PaisesStatus.loaded;
    } else {
      _errorMessage = result['message'];
      _status = PaisesStatus.error;
    }
    notifyListeners();
  }
}