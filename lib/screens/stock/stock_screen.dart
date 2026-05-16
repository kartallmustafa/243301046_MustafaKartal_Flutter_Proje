import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/stok.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stok_provider.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final stok = context.watch<StokProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (profile?.topId != null) stok.fetch(profile!.topId!);
            },
          ),
        ],
      ),
      body: stok.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryBar(stok),
                Expanded(child: _buildList(context, stok)),
              ],
            ),
    );
  }

  Widget _buildSummaryBar(StokProvider stok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          _badge('KRİTİK', stok.kritikCount, kCriticalColor),
          const SizedBox(width: 12),
          _badge('DÜŞÜK', stok.dusukCount, kLowColor),
          const SizedBox(width: 12),
          _badge('NORMAL', stok.stoklar.length - stok.kritikCount - stok.dusukCount, kNormalColor),
        ],
      ),
    );
  }

  Widget _badge(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  Widget _buildList(BuildContext context, StokProvider stok) {
    if (stok.stoklar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: kTextSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Stok bilgisi bulunamadı', style: TextStyle(color: kTextSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: stok.stoklar.length,
      itemBuilder: (_, i) => _StokCard(
        stok: stok.stoklar[i],
        onUpdate: (yeniMiktar) async {
          final profile = context.read<AuthProvider>().profile;
          if (profile?.topId != null) {
            await stok.update(stok.stoklar[i].stokId, yeniMiktar, profile!.topId!);
          }
        },
      ),
    );
  }
}

class _StokCard extends StatelessWidget {
  final Stok stok;
  final Future<void> Function(int) onUpdate;

  const _StokCard({required this.stok, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final renk = stokRengi(stok.miktar, stok.minStok);
    final durum = stokDurumu(stok.miktar, stok.minStok);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: renk.withValues(alpha: 0.15),
          child: Text(
            stok.miktar.toString(),
            style: TextStyle(color: renk, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${stok.marka ?? ''} ${stok.urunAdi ?? 'Ürün'}'.trim(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: ${stok.tip ?? '-'} • Min: ${stok.minStok}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(durum,
                  style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
              onPressed: () => _showUpdateDialog(context),
            ),
          ],
        ),
        isThreeLine: false,
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    final ctrl = TextEditingController(text: stok.miktar.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stok Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${stok.marka ?? ''} ${stok.urunAdi ?? ''}'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Yeni Miktar', border: OutlineInputBorder()),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              final yeni = int.tryParse(ctrl.text);
              if (yeni == null || yeni < 0) return;
              Navigator.pop(context);
              await onUpdate(yeni);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stok güncellendi'), backgroundColor: kNormalColor),
                );
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }
}
