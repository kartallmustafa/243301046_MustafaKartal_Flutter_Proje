import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/siparis.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siparis_provider.dart';
import '../../services/siparis_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int sipId;
  const OrderDetailScreen({super.key, required this.sipId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Siparis? _siparis;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SiparisService.fetchById(widget.sipId);
    if (mounted) setState(() { _siparis = s; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AuthProvider>().profile;
    final isToptanci = profile?.isToptanci ?? false;
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş #${widget.sipId}'),
        actions: [
          if (isToptanci && _siparis != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) => _updateDurum(context, val),
              itemBuilder: (_) => kSiparisDurumlari
                  .map((d) => PopupMenuItem(value: d, child: Text(d)))
                  .toList(),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _siparis == null
              ? const Center(child: Text('Sipariş bulunamadı'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      _buildInfoCard(fmt),
                      const SizedBox(height: 16),
                      _buildDetaylar(fmt),
                      if (_siparis!.kargo != null) ...[
                        const SizedBox(height: 16),
                        _buildKargoCard(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    final s = _siparis!;
    final renk = siparisRengi(s.durum);
    return Card(
      color: renk.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.circle, color: renk, size: 12),
            const SizedBox(width: 8),
            Text(s.durum,
                style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Text(s.siparisTarihi, style: const TextStyle(color: kTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(NumberFormat fmt) {
    final s = _siparis!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sipariş Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            if (s.magazaAdi != null) _infoRow('Mağaza', s.magazaAdi!),
            if (s.firmaAdi != null) _infoRow('Toptancı', s.firmaAdi!),
            if (s.odemeTuru != null) _infoRow('Ödeme', s.odemeTuru!),
            if (s.teslimTarihi != null) _infoRow('Teslim Tarihi', s.teslimTarihi!),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toplam Tutar', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(fmt.format(s.toplamTutar),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetaylar(NumberFormat fmt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ürünler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            if (_siparis!.detaylar.isEmpty)
              const Text('Ürün bilgisi yok', style: TextStyle(color: kTextSecondary))
            else
              ..._siparis!.detaylar.map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.lens_outlined, size: 16, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${d.marka ?? ''} ${d.urunAdi ?? 'Ürün'}',
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text('${d.miktar} adet × ${fmt.format(d.birimFiyat)}',
                                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(fmt.format(d.araToplam),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildKargoCard() {
    final k = _siparis!.kargo!;
    final renk = k.kargoDurumu == 'Teslim Edildi'
        ? kNormalColor
        : k.kargoDurumu == 'İptal'
            ? kCriticalColor
            : kAccentColor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kargo Bilgisi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            if (k.kargoFirmasi != null) _infoRow('Firma', k.kargoFirmasi!),
            if (k.takipNo != null) _infoRow('Takip No', k.takipNo!),
            if (k.gonderimTarihi != null) _infoRow('Gönderim', k.gonderimTarihi!),
            if (k.teslimTarihi != null) _infoRow('Teslim', k.teslimTarihi!),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(k.kargoDurumu,
                  style: TextStyle(color: renk, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: kTextSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _updateDurum(BuildContext context, String yeniDurum) async {
    if (_siparis?.durum == yeniDurum) return;
    final siparisProvider = context.read<SiparisProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await siparisProvider.updateDurum(widget.sipId, yeniDurum);
    await _load();
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Durum "$yeniDurum" olarak güncellendi'), backgroundColor: kNormalColor),
      );
    }
  }
}
