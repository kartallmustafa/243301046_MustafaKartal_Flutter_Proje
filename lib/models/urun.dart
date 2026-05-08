class UrunKategori {
  final int katId;
  final String kategoriAdi;

  const UrunKategori({required this.katId, required this.kategoriAdi});

  factory UrunKategori.fromJson(Map<String, dynamic> json) => UrunKategori(
        katId: json['kat_id'] as int,
        kategoriAdi: json['kategori_adi'] as String,
      );
}

class Urun {
  final int urunId;
  final int? katId;
  final int? topId;
  final String urunAdi;
  final String? marka;
  final String? model;
  final String? renk;
  final String? malzeme;
  final double birimFiyat;
  final String tip;
  final String? kategoriAdi;
  final String? firmaAdi;

  const Urun({
    required this.urunId,
    this.katId,
    this.topId,
    required this.urunAdi,
    this.marka,
    this.model,
    this.renk,
    this.malzeme,
    required this.birimFiyat,
    required this.tip,
    this.kategoriAdi,
    this.firmaAdi,
  });

  factory Urun.fromJson(Map<String, dynamic> json) => Urun(
        urunId: json['urun_id'] as int,
        katId: json['kat_id'] as int?,
        topId: json['top_id'] as int?,
        urunAdi: json['urun_adi'] as String,
        marka: json['marka'] as String?,
        model: json['model'] as String?,
        renk: json['renk'] as String?,
        malzeme: json['malzeme'] as String?,
        birimFiyat: (json['birim_fiyat'] as num).toDouble(),
        tip: json['tip'] as String? ?? 'CAM',
        kategoriAdi: json['urun_kategori'] != null
            ? (json['urun_kategori'] as Map<String, dynamic>)['kategori_adi'] as String?
            : null,
        firmaAdi: json['toptanci'] != null
            ? (json['toptanci'] as Map<String, dynamic>)['firma_adi'] as String?
            : null,
      );

  String get displayName => '$marka ${model ?? urunAdi}';
}
