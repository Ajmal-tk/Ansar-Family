import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  ProfileModel? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentProfile != null;
  bool get isAdmin => _currentProfile?.isAdmin ?? false;
  bool get isManagement => _currentProfile?.isManagement ?? false;
  bool get isApproved => _currentProfile?.isApproved ?? false;
  bool get isPending => _currentProfile?.isPending ?? false;

  AuthProvider() {
    initAuth();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uId = SupabaseService.instance.currentUserId;
      _currentProfile = await SupabaseService.instance.fetchProfile(uId);
    } catch (e) {
      debugPrint("Error initializing auth: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String emailOrUsername, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.instance.signIn(emailOrUsername: emailOrUsername, password: password);
      final uId = SupabaseService.instance.currentUserId;
      _currentProfile = await SupabaseService.instance.fetchProfile(uId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.instance.signUp(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        address: address,
      );
      final uId = SupabaseService.instance.currentUserId;
      _currentProfile = await SupabaseService.instance.fetchProfile(uId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
    _currentProfile = null;
    notifyListeners();
  }

  Future<void> switchDemoRole(String role) async {
    _isLoading = true;
    notifyListeners();

    SupabaseService.instance.switchMockRole(role);
    final uId = SupabaseService.instance.currentUserId;
    _currentProfile = await SupabaseService.instance.fetchProfile(uId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_currentProfile != null) {
      _currentProfile = await SupabaseService.instance.fetchProfile(_currentProfile!.id);
      notifyListeners();
    }
  }
}
