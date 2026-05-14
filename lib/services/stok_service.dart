import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stok.dart';
import 'log_service.dart';

class StokService {
  static final _client = Supabase.instance.client;

  static Future<List<Stok>> fetchByTopId(int topId) async {
    final data = await _client
        .from('stok')
        .select('*, urun(urun_adi, marka, tip)')
        .eq('top_id', topId)
        .order('miktar');
    await LogService.log('STOK_LISTELE', 'stok', aciklama: 'TopID=$topId');
    return (data as List).map((e) => Stok.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> updateMiktar(int stokId, int yeniMiktar, int topId) async {
    await _client
        .from('stok')
        .update({
          'miktar': yeniMiktar,
          'guncelleme_tarihi': DateTime.now().toIso8601String().split('T').first,
        })
        .eq('stok_id', stokId);
    await LogService.log('STOK_GUNCELLE', 'stok',
        kayitId: stokId, aciklama: 'Yeni miktar: $yeniMiktar');
  }
}
