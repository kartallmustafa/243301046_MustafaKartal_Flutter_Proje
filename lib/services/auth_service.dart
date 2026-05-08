import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import 'log_service.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static Future<Profile?> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    final profile = await fetchProfile();
    await LogService.log('LOGIN', 'auth', aciklama: 'Giriş yapıldı: $email');
    return profile;
  }

  static Future<Profile?> register({
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
    final response = await _client.auth.signUp(email: email, password: password);
    final userId = response.user?.id;
    if (userId == null) throw Exception('Kayıt başarısız');

    int? perId;
    int? topId;

    if (role == 'perakendeci') {
      final per = await _client.from('perakendeci').insert({
        'magaza_adi': magazaAdi ?? fullName,
        'sahip_adi': fullName,
        'email': email,
        'telefon': telefon,
        'sehir': sehir,
        'adres': adres,
      }).select().single();
      perId = per['per_id'] as int;
    } else {
      final top = await _client.from('toptanci').insert({
        'firma_adi': firmaAdi ?? fullName,
        'email': email,
        'telefon': telefon,
        'sehir': sehir,
        'adres': adres,
      }).select().single();
      topId = top['top_id'] as int;
    }

    await _client.from('profiles').insert({
      'id': userId,
      'role': role,
      'per_id': perId,
      'top_id': topId,
      'full_name': fullName,
    });

    await LogService.log('REGISTER', 'auth', aciklama: 'Kayıt: $email / $role');
    return await fetchProfile();
  }

  static Future<void> logout() async {
    await LogService.log('LOGOUT', 'auth', aciklama: 'Çıkış yapıldı');
    await _client.auth.signOut();
  }

  static Future<Profile?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  static bool get isLoggedIn => _client.auth.currentSession != null;
}
