import 'package:flutter/material.dart';
import '../models/urun.dart';
import '../services/urun_service.dart';

class UrunProvider extends ChangeNotifier {
  List<Urun> _urunler = [];
  bool _loading = false;
  String? _secilenTip;

  List<Urun> get urunler {
    if (_secilenTip == null) return _urunler;
    return _urunler.where((u) => u.tip == _secilenTip).toList();
  }

  bool get loading => _loading;
  String? get secilenTip => _secilenTip;

  void setTip(String? tip) {
    _secilenTip = tip;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    try {
      _urunler = await UrunService.fetchAll();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }
}
