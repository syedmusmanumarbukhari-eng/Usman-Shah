import 'package:flutter/foundation.dart';
import '../models/farm_models.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  factory AuthService() => instance;

  AuthService._internal() {
    // Add default admin/demo user
    _users.add(
      UserModel(
        id: '1',
        fullName: 'Farm Manager',
        farmName: 'Green Valley Poultry',
        email: 'admin@farm.com',
        password: 'password123',
      ),
    );
  }

  final List<UserModel> _users = [];
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  String? login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty) {
      return 'Please enter your email address.';
    }
    if (cleanPassword.isEmpty) {
      return 'Please enter your password.';
    }

    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == cleanEmail && u.password == cleanPassword,
      );
      _currentUser = user;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Invalid email or password. Please try again.';
    }
  }

  String? register({
    required String fullName,
    required String farmName,
    required String email,
    required String password,
  }) {
    final cleanName = fullName.trim();
    final cleanFarm = farmName.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) return 'Full name is required.';
    if (cleanFarm.isEmpty) return 'Farm name is required.';
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) return 'Enter a valid email address.';
    if (cleanPassword.length < 6) return 'Password must be at least 6 characters.';

    final existingIndex = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
    if (existingIndex != -1) {
      return 'An account with this email already exists.';
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: cleanName,
      farmName: cleanFarm,
      email: cleanEmail,
      password: cleanPassword,
    );

    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
