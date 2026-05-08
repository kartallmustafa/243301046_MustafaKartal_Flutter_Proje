class SiparisDetay {
  final int detayId;
  final int sipId;
  final int urunId;
  final int miktar;
  final double birimFiyat;
  final double indirimOrani;
  final double araToplam;
  final String? urunAdi;
  final String? marka;

  const SiparisDetay({
    required this.detayId,
    required this.sipId,
    required this.urunId,
    required this.miktar,
    required this.birimFiyat,
    required this.indirimOrani,
    required this.araToplam,
    this.urunAdi,
    this.marka,
  });

  factory SiparisDetay.fromJson(Map<String, dynamic> json) => SiparisDetay(
        detayId: json['detay_id'] as int,
        sipId: json['sip_id'] as int,
        urunId: json['urun_id'] as int,
        miktar: json['miktar'] as int? ?? 1,
        birimFiyat: (json['birim_fiyat'] as num?)?.toDouble() ?? 0.0,
        indirimOrani: (json['indirim_orani'] as num?)?.toDouble() ?? 0.0,
        araToplam: (json['ara_toplam'] as num?)?.toDouble() ?? 0.0,
        urunAdi: json['urun'] != null
            ? (json['urun'] as Map<String, dynamic>)['urun_adi'] as String?
            : null,
        marka: json['urun'] != null
            ? (json['urun'] as Map<String, dynamic>)['marka'] as String?
            : null,
      );
}

class Kargo {
  final int kargoId;
  final int sipId;
  final String? kargoFirmasi;
  final String? takipNo;
  final String? gonderimTarihi;
  final String? teslimTarihi;
  final String kargoDurumu;

  const Kargo({
    required this.kargoId,
    required this.sipId,
    this.kargoFirmasi,
    this.takipNo,
    this.gonderimTarihi,
    this.teslimTarihi,
    required this.kargoDurumu,
  });

  factory Kargo.fromJson(Map<String, dynamic> json) => Kargo(
        kargoId: json['kargo_id'] as int,
        sipId: json['sip_id'] as int,
        kargoFirmasi: json['kargo_firmasi'] as String?,
        takipNo: json['takip_no'] as String?,
        gonderimTarihi: json['gonderim_tarihi'] as String?,
        teslimTarihi: json['teslim_tarihi'] as String?,
        kargoDurumu: json['kargo_durumu'] as String? ?? 'Hazırlanıyor',
      );
}

class Siparis {
  final int sipId;
  final int perId;
  final int topId;
  final String siparisTarihi;
  final String durum;
  final double toplamTutar;
  final String? odemeTuru;
  final String? teslimTarihi;
  final String? magazaAdi;
  final String? firmaAdi;
  final List<SiparisDetay> detaylar;
  final Kargo? kargo;

  const Siparis({
    required this.sipId,
    required this.perId,
    required this.topId,
    required this.siparisTarihi,
    required this.durum,
    required this.toplamTutar,
    this.odemeTuru,
    this.teslimTarihi,
    this.magazaAdi,
    this.firmaAdi,
    this.detaylar = const [],
    this.kargo,
  });

  factory Siparis.fromJson(Map<String, dynamic> json) => Siparis(
        sipId: json['sip_id'] as int,
        perId: json['per_id'] as int,
        topId: json['top_id'] as int,
        siparisTarihi: json['siparis_tarihi'] as String? ?? '',
        durum: json['durum'] as String? ?? 'Hazırlanıyor',
        toplamTutar: (json['toplam_tutar'] as num?)?.toDouble() ?? 0.0,
        odemeTuru: json['odeme_turu'] as String?,
        teslimTarihi: json['teslim_tarihi'] as String?,
        magazaAdi: json['perakendeci'] != null
            ? (json['perakendeci'] as Map<String, dynamic>)['magaza_adi'] as String?
            : null,
        firmaAdi: json['toptanci'] != null
            ? (json['toptanci'] as Map<String, dynamic>)['firma_adi'] as String?
            : null,
        detaylar: json['siparis_detay'] != null
            ? (json['siparis_detay'] as List)
                .map((d) => SiparisDetay.fromJson(d as Map<String, dynamic>))
                .toList()
            : [],
        kargo: json['kargo'] != null
            ? (json['kargo'] is Map
                ? Kargo.fromJson(json['kargo'] as Map<String, dynamic>)
                : ((json['kargo'] as List).isNotEmpty
                    ? Kargo.fromJson((json['kargo'] as List).first as Map<String, dynamic>)
                    : null))
            : null,
      );
}
