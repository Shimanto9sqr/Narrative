import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:narrative/services/auth_service.dart';
import 'package:narrative/services/local_db_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final LocalDbService _localDbService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  AuthViewModel({
    required AuthService authService,
    required LocalDbService localDbService,
  })  : _authService = authService,
        _localDbService = localDbService {
    _initAuthState();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoggedIn => _currentUser != null;
  String? get userId => _currentUser?.uid;

  void _initAuthState() {
    _currentUser = _authService.currentUser;

    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    clearMessages();
    _setLoading(true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setSuccess('Login successful!');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    clearMessages();
    _setLoading(true);

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setSuccess('Registration successful!');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      clearMessages();
      notifyListeners();
    } catch (e) {
      _setError('Error signing out: $e');
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    clearMessages();
    _setLoading(true);

    try {
      await _authService.sendPasswordResetEmail(email);
      _setSuccess('Password reset email sent!');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);

    try {
      if (_currentUser != null) {
        await _localDbService.deleteUserPreferences(_currentUser!.uid);
      }
      await _authService.deleteAccount();
      _currentUser = null;
      _setSuccess('Account deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error deleting account: $e');
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}