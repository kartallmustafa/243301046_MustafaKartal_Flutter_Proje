import 'package:flutter/material.dart';
import '../models/stok.dart';
import '../services/stok_service.dart';

class StokProvider extends ChangeNotifier {
  List<Stok> _stoklar = [];
  bool _loading = false;

  List<Stok> get stoklar => _stoklar;
  bool get loading => _loading;

  int get kritikCount => _stoklar.where((s) => s.durum == 'KRİTİK').length;
  int get dusukCount => _stoklar.where((s) => s.durum == 'DÜŞÜK').length;

  Future<void> fetch(int topId) async {
    _loading = true;
    notifyListeners();
    try {
      _stoklar = await StokService.fetchByTopId(topId);
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> update(int stokId, int yeniMiktar, int topId) async {
    await StokService.updateMiktar(stokId, yeniMiktar, topId);
    await fetch(topId);
  }
}
