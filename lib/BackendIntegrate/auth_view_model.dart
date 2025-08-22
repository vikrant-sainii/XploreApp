import 'api_service.dart';
import 'models.dart';
import 'package:flutter/foundation.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  bool get isLoading => _state == AuthState.loading;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      final response = await _apiService.signup(
        email: email,
        password: password,
        name: name,
      );

      // After successful signup, automatically log in
      await login(email: email, password: password);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.idToken != null) {
        await _loadCurrentUser();
        _setState(AuthState.authenticated);
      } else {
        _setError('Failed to authenticate');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _apiService.getCurrentUser();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load current user: $e');
      }
    }
  }

  Future<void> updateProfile({
    String? name,
    int? rollno,
    String? branch,
    String? hostelName,
    String? roomNo,
    String? skills,
  }) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      _currentUser = await _apiService.updateCurrentUser(
        name: name,
        rollno: rollno,
        branch: branch,
        hostelName: hostelName,
        roomNo: roomNo,
        skills: skills,
      );

      _setState(AuthState.authenticated);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void logout() {
    _apiService.clearTokens();
    _currentUser = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_currentUser != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }
}