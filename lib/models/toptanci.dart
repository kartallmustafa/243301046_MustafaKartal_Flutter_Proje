class Toptanci {
  final int topId;
  final String firmaAdi;
  final String? vergiNo;
  final String? telefon;
  final String? email;
  final String? adres;
  final String? sehir;

  const Toptanci({
    required this.topId,
    required this.firmaAdi,
    this.vergiNo,
    this.telefon,
    this.email,
    this.adres,
    this.sehir,
  });

  factory Toptanci.fromJson(Map<String, dynamic> json) => Toptanci(
        topId: json['top_id'] as int,
        firmaAdi: json['firma_adi'] as String,
        vergiNo: json['vergi_no'] as String?,
        telefon: json['telefon'] as String?,
        email: json['email'] as String?,
        adres: json['adres'] as String?,
        sehir: json['sehir'] as String?,
      );
}

class Perakendeci {
  final int perId;
  final String magazaAdi;
  final String? sahipAdi;
  final String? vergiNo;
  final String? telefon;
  final String? email;
  final String? adres;
  final String? sehir;

  const Perakendeci({
    required this.perId,
    required this.magazaAdi,
    this.sahipAdi,
    this.vergiNo,
    this.telefon,
    this.email,
    this.adres,
    this.sehir,
  });

  factory Perakendeci.fromJson(Map<String, dynamic> json) => Perakendeci(
        perId: json['per_id'] as int,
        magazaAdi: json['magaza_adi'] as String,
        sahipAdi: json['sahip_adi'] as String?,
        vergiNo: json['vergi_no'] as String?,
        telefon: json['telefon'] as String?,
        email: json['email'] as String?,
        adres: json['adres'] as String?,
        sehir: json['sehir'] as String?,
      );
}
