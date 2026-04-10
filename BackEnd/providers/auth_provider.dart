import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider({required this.authService}) {
    _init();
  }

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  

  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  User? get firebaseUser => authService.firebaseUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isUser => _currentUser?.role == 'user';

  void _init() {
    _authSubscription = authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isInitializing = false;
        notifyListeners();
        return;
      }

      final profile = await authService.getCurrentUserProfile();
      _currentUser = profile;
      _isInitializing = false;
      notifyListeners();
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await authService.register(
        name: name,
        email: email,
        password: password,
      );

      _currentUser = user;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = authService.mapFirebaseAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await authService.login(
        email: email,
        password: password,
      );

      _currentUser = user;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = authService.mapFirebaseAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await authService.logout();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}