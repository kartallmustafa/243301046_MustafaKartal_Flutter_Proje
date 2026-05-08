class Stok {
  final int stokId;
  final int urunId;
  final int topId;
  final int miktar;
  final int minStok;
  final String? guncellemeTarihi;
  final String? urunAdi;
  final String? marka;
  final String? tip;

  const Stok({
    required this.stokId,
    required this.urunId,
    required this.topId,
    required this.miktar,
    required this.minStok,
    this.guncellemeTarihi,
    this.urunAdi,
    this.marka,
    this.tip,
  });

  factory Stok.fromJson(Map<String, dynamic> json) => Stok(
        stokId: json['stok_id'] as int,
        urunId: json['urun_id'] as int,
        topId: json['top_id'] as int,
        miktar: json['miktar'] as int? ?? 0,
        minStok: json['min_stok'] as int? ?? 5,
        guncellemeTarihi: json['guncelleme_tarihi'] as String?,
        urunAdi: json['urun'] != null
            ? (json['urun'] as Map<String, dynamic>)['urun_adi'] as String?
            : null,
        marka: json['urun'] != null
            ? (json['urun'] as Map<String, dynamic>)['marka'] as String?
            : null,
        tip: json['urun'] != null
            ? (json['urun'] as Map<String, dynamic>)['tip'] as String?
            : null,
      );

  String get durum {
    if (miktar <= 0) return 'KRİTİK';
    if (miktar <= minStok) return 'DÜŞÜK';
    return 'NORMAL';
  }
}
