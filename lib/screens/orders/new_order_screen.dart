import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/urun.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siparis_provider.dart';
import '../../providers/urun_provider.dart';
import '../../services/siparis_service.dart';
import '../../services/urun_service.dart';

class NewOrderScreen extends StatefulWidget {
  final Urun? preselectedUrun;
  const NewOrderScreen({super.key, this.preselectedUrun});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Urun? _secilenUrun;
  List<Toptanci> _toptancilar = [];
  Toptanci? _secilenToptanci;
  int _miktar = 1;
  String _odemeTuru = 'Havale';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedUrun != null) {
      _secilenUrun = widget.preselectedUrun;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final urunProvider = context.read<UrunProvider>();
    if (urunProvider.urunler.isEmpty) await urunProvider.fetchAll();
    final tops = await UrunService.fetchToptancilar();
    if (mounted) setState(() => _toptancilar = tops);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_secilenUrun == null) {
      _showError('Lütfen ürün seçiniz');
      return;
    }
    if (_secilenToptanci == null) {
      _showError('Lütfen toptancı seçiniz');
      return;
    }
    final profile = context.read<AuthProvider>().profile;
    if (profile?.perId == null) return;

    setState(() => _submitting = true);
    final siparisProvider = context.read<SiparisProvider>();
    try {
      final sipId = await SiparisService.createSiparis(
        perId: profile!.perId!,
        topId: _secilenToptanci!.topId,
        urunId: _secilenUrun!.urunId,
        miktar: _miktar,
        odemeTuru: _odemeTuru,
      );
      await siparisProvider.fetchForPerakendeci(profile.perId!);
      if (mounted) {
        _showSuccess('Sipariş #$sipId oluşturuldu!');
        setState(() {
          _secilenUrun = null;
          _secilenToptanci = null;
          _miktar = 1;
          _odemeTuru = 'Havale';
        });
      }
    } catch (e) {
      _showError('Sipariş oluşturulamadı: $e');
    }
    if (mounted) setState(() => _submitting = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kCriticalColor),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kNormalColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urunler = context.watch<UrunProvider>().urunler;
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Sipariş')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Ürün Seç', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Urun>(
                key: ValueKey(_secilenUrun),
                initialValue: _secilenUrun,
                isExpanded: true,
                hint: const Text('Ürün seçiniz'),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.lens_outlined)),
                items: urunler.map((u) => DropdownMenuItem(
                  value: u,
                  child: Text('${u.marka ?? ''} ${u.model ?? u.urunAdi} (${fmt.format(u.birimFiyat)})',
                      overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (u) {
                  setState(() {
                    _secilenUrun = u;
                    // Ürüne ait toptancıyı otomatik seç
                    if (u != null && u.topId != null) {
                      _secilenToptanci = _toptancilar
                          .where((t) => t.topId == u.topId)
                          .firstOrNull;
                    }
                  });
                },
                validator: (_) => _secilenUrun == null ? 'Ürün seçiniz' : null,
              ),
              const SizedBox(height: 16),
              const Text('Toptancı Seç', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Toptanci>(
                key: ValueKey(_secilenToptanci),
                initialValue: _secilenToptanci,
                isExpanded: true,
                hint: const Text('Toptancı seçiniz'),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.business_outlined)),
                items: _toptancilar.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.firmaAdi, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (t) => setState(() => _secilenToptanci = t),
                validator: (_) => _secilenToptanci == null ? 'Toptancı seçiniz' : null,
              ),
              const SizedBox(height: 16),
              const Text('Miktar', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() { if (_miktar > 1) _miktar--; }),
                    icon: const Icon(Icons.remove_circle_outline, color: kPrimaryColor),
                  ),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey(_miktar),
                      initialValue: '$_miktar',
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(),
                      onChanged: (v) => setState(() => _miktar = int.tryParse(v) ?? 1),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Geçerli miktar girin';
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _miktar++),
                    icon: const Icon(Icons.add_circle_outline, color: kPrimaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Ödeme Türü', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Havale', label: Text('Havale'), icon: Icon(Icons.account_balance)),
                  ButtonSegment(value: 'Kredi Kartı', label: Text('Kredi Kartı'), icon: Icon(Icons.credit_card)),
                ],
                selected: {_odemeTuru},
                onSelectionChanged: (s) => setState(() => _odemeTuru = s.first),
              ),
              if (_secilenUrun != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: kPrimaryColor.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Sipariş Özeti', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Birim Fiyat'),
                            Text(fmt.format(_secilenUrun!.birimFiyat)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Miktar'),
                            Text('$_miktar adet'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              fmt.format(_secilenUrun!.birimFiyat * _miktar),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Siparişi Oluştur'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
