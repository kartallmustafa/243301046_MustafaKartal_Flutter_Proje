import 'package:flutter/material.dart';
import '../models/siparis.dart';
import '../services/siparis_service.dart';

class SiparisProvider extends ChangeNotifier {
  List<Siparis> _siparisler = [];
  bool _loading = false;
  String? _error;
  String _durumFiltre = 'Tümü';

  List<Siparis> get siparisler {
    if (_durumFiltre == 'Tümü') return _siparisler;
    return _siparisler.where((s) => s.durum == _durumFiltre).toList();
  }

  bool get loading => _loading;
  String? get error => _error;
  String get durumFiltre => _durumFiltre;

  void setDurumFiltre(String filtre) {
    _durumFiltre = filtre;
    notifyListeners();
  }

  Future<void> fetchForPerakendeci(int perId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _siparisler = await SiparisService.fetchByPerId(perId);
    } catch (e) {
      _error = 'Siparişler yüklenemedi: $e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchForToptanci(int topId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _siparisler = await SiparisService.fetchByTopId(topId);
    } catch (e) {
      _error = 'Siparişler yüklenemedi: $e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateDurum(int sipId, String yeniDurum) async {
    await SiparisService.updateDurum(sipId, yeniDurum);
    final idx = _siparisler.indexWhere((s) => s.sipId == sipId);
    if (idx != -1) {
      final s = _siparisler[idx];
      _siparisler[idx] = Siparis(
        sipId: s.sipId,
        perId: s.perId,
        topId: s.topId,
        siparisTarihi: s.siparisTarihi,
        durum: yeniDurum,
        toplamTutar: s.toplamTutar,
        odemeTuru: s.odemeTuru,
        teslimTarihi: s.teslimTarihi,
        magazaAdi: s.magazaAdi,
        firmaAdi: s.firmaAdi,
        detaylar: s.detaylar,
        kargo: s.kargo,
      );
      notifyListeners();
    }
  }

  int get bekleyenCount =>
      _siparisler.where((s) => s.durum == 'Hazırlanıyor' || s.durum == 'Kargoda').length;
}
