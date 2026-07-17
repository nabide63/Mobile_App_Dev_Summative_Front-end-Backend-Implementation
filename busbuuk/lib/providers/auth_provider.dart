// login/signup/logout state, wraps AuthService + FirebaseAuth
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // keep our own user profile in sync whenever firebase's auth state changes
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }
      _currentUser = await _firestoreService.getUserProfile(firebaseUser.uid);
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUserProfile(newUser);

      _currentUser = newUser;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      _currentUser = await _firestoreService.getUserProfile(
        credential.user!.uid,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
