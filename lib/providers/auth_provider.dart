import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../services/supabase_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  sb.User? get user => _service.currentUser;

  AuthProvider() {
    // Check initial state
    _status = _service.currentUser != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    print('AUTH PROVIDER INIT: status=$_status');

    _service.authStateChanges.listen((data) {
      print('AUTH STATE CHANGED: session=${data.session != null}');
      _status = data.session != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
      print('AUTH PROVIDER: notifyListeners called, new status=$_status');
    });
  }

  Future<bool> signIn(String email, String password) async {
    print('AUTH PROVIDER: signIn called');
    _setLoading(true);
    try {
      await _service.signIn(email, password);
      print('AUTH PROVIDER: signIn SUCCESS');
      _errorMessage = null;
      return true;
    } catch (e) {
      print('AUTH PROVIDER: signIn ERROR: $e');
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      await _service.register(email, password);
      _errorMessage = null;
      return true;
    } catch (e) {
      print('REGISTER ERROR: $e');
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    print('SIGN OUT BUTTON PRESSED');
    await _service.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials'))
      return 'Incorrect email or password.';
    if (msg.contains('already registered'))
      return 'An account already exists with this email.';
    if (msg.contains('Password should be'))
      return 'Password must be at least 6 characters.';
    return 'Something went wrong. Please try again.';
  }
}
