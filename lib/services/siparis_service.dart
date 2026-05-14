import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/siparis.dart';
import 'log_service.dart';

class SiparisService {
  static final _client = Supabase.instance.client;

  static const _select =
      '*, perakendeci(magaza_adi), toptanci(firma_adi), siparis_detay(*, urun(urun_adi, marka)), kargo(*)';

  static Future<List<Siparis>> fetchByPerId(int perId) async {
    final data = await _client
        .from('siparis')
        .select(_select)
        .eq('per_id', perId)
        .order('siparis_tarihi', ascending: false);
    await LogService.log('SIPARIS_LISTELE', 'siparis', aciklama: 'PerID=$perId');
    return (data as List).map((e) => Siparis.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Siparis>> fetchByTopId(int topId) async {
    final data = await _client
        .from('siparis')
        .select(_select)
        .eq('top_id', topId)
        .order('siparis_tarihi', ascending: false);
    await LogService.log('SIPARIS_LISTELE', 'siparis', aciklama: 'TopID=$topId');
    return (data as List).map((e) => Siparis.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Siparis?> fetchById(int sipId) async {
    final data = await _client
        .from('siparis')
        .select(_select)
        .eq('sip_id', sipId)
        .maybeSingle();
    if (data == null) return null;
    await LogService.log('SIPARIS_DETAY', 'siparis', kayitId: sipId);
    return Siparis.fromJson(data);
  }

  static Future<int> createSiparis({
    required int perId,
    required int topId,
    required int urunId,
    required int miktar,
    required String odemeTuru,
  }) async {
    final result = await _client.rpc('create_siparis', params: {
      'p_per_id': perId,
      'p_top_id': topId,
      'p_urun_id': urunId,
      'p_miktar': miktar,
      'p_odeme_turu': odemeTuru,
    });
    final sipId = result as int;
    await LogService.log('SIPARIS_OLUSTUR', 'siparis',
        kayitId: sipId,
        aciklama: 'PerID=$perId UrunID=$urunId Miktar=$miktar');
    return sipId;
  }

  static Future<void> updateDurum(int sipId, String yeniDurum) async {
    await _client.from('siparis').update({'durum': yeniDurum}).eq('sip_id', sipId);
    await LogService.log('SIPARIS_DURUM_GUNCELLE', 'siparis',
        kayitId: sipId, aciklama: 'Yeni durum: $yeniDurum');
  }
}
