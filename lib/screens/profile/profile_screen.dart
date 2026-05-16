import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siparis_provider.dart';
import '../../providers/stok_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final siparisler = context.watch<SiparisProvider>();
    final stok = context.watch<StokProvider>();

    if (profile == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
              child: const Icon(Icons.person, size: 56, color: kPrimaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              profile.fullName ?? 'Kullanıcı',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.role == kRolePerakendeci ? 'Perakendeci' : 'Toptancı',
                style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(profile),
            const SizedBox(height: 16),
            _buildStatsCard(siparisler, stok, profile.isPerakendeci),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, auth),
              icon: const Icon(Icons.logout, color: kCriticalColor),
              label: const Text('Çıkış Yap', style: TextStyle(color: kCriticalColor)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kCriticalColor)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(dynamic profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hesap Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            _row('Rol', profile.role == kRolePerakendeci ? 'Perakendeci' : 'Toptancı'),
            if (profile.perId != null) _row('Perakendeci ID', '#${profile.perId}'),
            if (profile.topId != null) _row('Toptancı ID', '#${profile.topId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(SiparisProvider siparisler, StokProvider stok, bool isPerakendeci) {
    final toplam = siparisler.siparisler.length;
    final bekleyen = siparisler.bekleyenCount;
    final teslim = siparisler.siparisler.where((s) => s.durum == 'Teslim Edildi').length;
    final iptal = siparisler.siparisler.where((s) => s.durum == 'İptal').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isPerakendeci ? 'Sipariş İstatistikleri' : 'Gelen Sipariş İstatistikleri',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            _statRow('Toplam Sipariş', '$toplam', kPrimaryColor),
            _statRow('Bekleyen', '$bekleyen', kLowColor),
            _statRow('Teslim Edildi', '$teslim', kNormalColor),
            _statRow('İptal', '$iptal', kCriticalColor),
            if (!isPerakendeci) ...[
              const Divider(),
              _statRow('Kritik Stok', '${stok.kritikCount}', kCriticalColor),
              _statRow('Düşük Stok', '${stok.dusukCount}', kLowColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: kTextSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kTextSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kCriticalColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await auth.logout();
    }
  }
}
