import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status        = AuthStatus.initial;
  UserModel? _user;
  String?    _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────
  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;

  // ── Verify Authentication Status ─────────────────────────────────────────
  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final storedUser = await _authService.getStoredUser();

    if (storedUser != null) {
      _user   = storedUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<bool> login(String correo, String password) async {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(correo, password);

    if (result['success'] == true) {
      _user   = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String;
      _status       = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}