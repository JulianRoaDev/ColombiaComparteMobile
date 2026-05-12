import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../services/dashboard_service.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardStatus _status       = DashboardStatus.initial;
  DashboardStats? _stats;
  String?         _errorMessage;

  DashboardStatus get status       => _status;
  DashboardStats? get stats        => _stats;
  String?         get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _status = DashboardStatus.loading;
    notifyListeners();

    final result = await _service.getStats();

    if (result['success'] == true) {
      _stats  = result['data'] as DashboardStats;
      _status = DashboardStatus.loaded;
    } else {
      _errorMessage = result['message'] as String;
      _status       = DashboardStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = DashboardStatus.initial;
    _stats  = null;
    notifyListeners();
  }
}