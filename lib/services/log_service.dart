import 'package:supabase_flutter/supabase_flutter.dart';

class LogService {
  static final _client = Supabase.instance.client;

  static Future<void> log(
    String islemTuru,
    String tabloAdi, {
    int? kayitId,
    String? aciklama,
  }) async {
    try {
      final user = _client.auth.currentUser;
      await _client.from('islem_log').insert({
        'user_id': user?.id,
        'islem_turu': islemTuru,
        'tablo_adi': tabloAdi,
        'kayit_id': kayitId,
        'aciklama': aciklama,
        'tarih': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Log hatası uygulamayı durdurmamalı
    }
  }
}
