import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/urun.dart';
import 'log_service.dart';

class UrunService {
  static final _client = Supabase.instance.client;

  static Future<List<Urun>> fetchAll({String? tip}) async {
    final base = _client
        .from('urun')
        .select('*, urun_kategori(kategori_adi), toptanci(firma_adi)');
    final data = tip != null
        ? await base.eq('tip', tip).order('marka')
        : await base.order('marka');
    await LogService.log('URUN_LISTELE', 'urun', aciklama: tip != null ? 'Tip=$tip' : 'Tümü');
    return (data as List).map((e) => Urun.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Urun>> fetchByTopId(int topId) async {
    final data = await _client
        .from('urun')
        .select('*, urun_kategori(kategori_adi), toptanci(firma_adi)')
        .eq('top_id', topId)
        .order('marka');
    return (data as List).map((e) => Urun.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Toptanci>> fetchToptancilar() async {
    final data = await _client.from('toptanci').select().order('firma_adi');
    await LogService.log('TOPTANCI_LISTELE', 'toptanci');
    return (data as List).map((e) => Toptanci.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class Toptanci {
  final int topId;
  final String firmaAdi;
  final String? telefon;
  final String? email;
  final String? sehir;

  const Toptanci({
    required this.topId,
    required this.firmaAdi,
    this.telefon,
    this.email,
    this.sehir,
  });

  factory Toptanci.fromJson(Map<String, dynamic> json) => Toptanci(
        topId: json['top_id'] as int,
        firmaAdi: json['firma_adi'] as String,
        telefon: json['telefon'] as String?,
        email: json['email'] as String?,
        sehir: json['sehir'] as String?,
      );
}
