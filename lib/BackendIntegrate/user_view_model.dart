import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

enum UserState { initial, loading, loaded, error }

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserState _state = UserState.initial;
  User? _user;
  String? _errorMessage;

  UserState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == UserState.loading;

  void _setState(UserState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(UserState.error);
  }

  Future<void> loadUser(String userId) async {
    try {
      _setState(UserState.loading);
      _errorMessage = null;

      _user = await _apiService.getUserById(userId);
      _setState(UserState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == UserState.error) {
      _setState(_user != null ? UserState.loaded : UserState.initial);
    }
  }

  void clear() {
    _user = null;
    _errorMessage = null;
    _setState(UserState.initial);
  }
}