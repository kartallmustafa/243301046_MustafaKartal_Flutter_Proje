import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/siparis.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siparis_provider.dart';
import '../../providers/stok_provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OptikTakip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (profile.isPerakendeci && profile.perId != null) {
                context.read<SiparisProvider>().fetchForPerakendeci(profile.perId!);
              } else if (profile.isToptanci && profile.topId != null) {
                context.read<SiparisProvider>().fetchForToptanci(profile.topId!);
                context.read<StokProvider>().fetch(profile.topId!);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(profile.fullName ?? 'Kullanıcı', profile.role),
            const SizedBox(height: 20),
            profile.isPerakendeci
                ? _PerakendeceDashboard()
                : _ToptanciDashboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(String name, String role) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Günaydın' : hour < 18 ? 'İyi günler' : 'İyi akşamlar';
    final rolText = role == 'perakendeci' ? 'Perakendeci' : 'Toptancı';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, $name! 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('$rolText Paneli • ${DateFormat('d MMMM y', 'tr').format(DateTime.now())}',
            style: const TextStyle(color: kTextSecondary, fontSize: 13)),
      ],
    );
  }
}

class _PerakendeceDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final siparisler = context.watch<SiparisProvider>();
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final toplam = siparisler.siparisler.length;
    final bekleyen = siparisler.bekleyenCount;
    final teslim = siparisler.siparisler.where((s) => s.durum == 'Teslim Edildi').length;
    final toplamTutar = siparisler.siparisler.fold(0.0, (sum, s) => sum + s.toplamTutar);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard('Toplam Sipariş', '$toplam', Icons.receipt, kPrimaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Bekleyen', '$bekleyen', Icons.pending, kLowColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard('Teslim Edildi', '$teslim', Icons.check_circle, kNormalColor)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Toplam Harcama', fmt.format(toplamTutar), Icons.payments, kAccentColor)),
          ],
        ),
        const SizedBox(height: 24),
        if (siparisler.loading)
          const Center(child: CircularProgressIndicator())
        else if (siparisler.siparisler.isNotEmpty) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Son Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 8),
          ...siparisler.siparisler.take(3).map((s) => _SonSiparisCard(s)),
        ],
      ],
    );
  }
}

class _ToptanciDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final siparisler = context.watch<SiparisProvider>();
    final stok = context.watch<StokProvider>();

    final toplam = siparisler.siparisler.length;
    final bekleyen = siparisler.bekleyenCount;
    final kritik = stok.kritikCount;
    final dusuk = stok.dusukCount;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard('Gelen Siparişler', '$toplam', Icons.inbox, kPrimaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Bekleyen', '$bekleyen', Icons.pending, kLowColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard('Kritik Stok', '$kritik', Icons.warning, kCriticalColor)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Düşük Stok', '$dusuk', Icons.info, kLowColor)),
          ],
        ),
        const SizedBox(height: 24),
        if (siparisler.loading)
          const Center(child: CircularProgressIndicator())
        else if (siparisler.siparisler.isNotEmpty) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Son Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 8),
          ...siparisler.siparisler.take(3).map((s) => _SonSiparisCard(s)),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Icon(Icons.trending_up, color: Colors.white.withValues(alpha: 0.5), size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
          ],
        ),
      ),
    );
  }
}

class _SonSiparisCard extends StatelessWidget {
  final Siparis siparis;
  const _SonSiparisCard(this.siparis);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: siparisRengi(siparis.durum).withValues(alpha: 0.15),
          child: Icon(Icons.receipt, color: siparisRengi(siparis.durum)),
        ),
        title: Text('Sipariş #${siparis.sipId}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(siparis.siparisTarihi),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(fmt.format(siparis.toplamTutar),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: siparisRengi(siparis.durum).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(siparis.durum,
                  style: TextStyle(fontSize: 10, color: siparisRengi(siparis.durum))),
            ),
          ],
        ),
      ),
    );
  }
}
