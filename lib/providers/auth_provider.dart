import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Profile? _profile;
  bool _loading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _profile != null;

  Future<void> init() async {
    if (!AuthService.isLoggedIn) return;
    _profile = await AuthService.fetchProfile();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await AuthService.login(email, password);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String? magazaAdi,
    String? firmaAdi,
    String? telefon,
    String? sehir,
    String? adres,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await AuthService.register(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        magazaAdi: magazaAdi,
        firmaAdi: firmaAdi,
        telefon: telefon,
        sehir: sehir,
        adres: adres,
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('Invalid login credentials')) return 'E-posta veya şifre hatalı';
    if (raw.contains('Email already registered')) return 'Bu e-posta zaten kayıtlı';
    if (raw.contains('Password should be at least')) return 'Şifre en az 6 karakter olmalı';
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
