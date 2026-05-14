import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/siparis.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siparis_provider.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final siparisProvider = context.watch<SiparisProvider>();
    final isPerakendeci = profile?.isPerakendeci ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isPerakendeci ? 'Siparişlerim' : 'Siparişler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (profile == null) return;
              if (isPerakendeci && profile.perId != null) {
                siparisProvider.fetchForPerakendeci(profile.perId!);
              } else if (!isPerakendeci && profile.topId != null) {
                siparisProvider.fetchForToptanci(profile.topId!);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context, siparisProvider),
          Expanded(child: _buildList(context, siparisProvider, isPerakendeci)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, SiparisProvider provider) {
    final durumlar = ['Tümü', ...kSiparisDurumlari];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: durumlar.map((d) {
            final selected = provider.durumFiltre == d;
            final renk = d == 'Tümü' ? kPrimaryColor : siparisRengi(d);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setDurumFiltre(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? renk : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      color: selected ? Colors.white : kTextSecondary,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, SiparisProvider provider, bool isPerakendeci) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: kCriticalColor, size: 48),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: const TextStyle(color: kCriticalColor),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    final list = provider.siparisler;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72,
                color: kTextSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Sipariş bulunamadı',
                style: TextStyle(color: kTextSecondary, fontSize: 16)),
            const SizedBox(height: 6),
            Text('Henüz bu durumda sipariş yok',
                style: TextStyle(color: kTextSecondary.withValues(alpha: 0.6), fontSize: 13)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        final profile = context.read<AuthProvider>().profile;
        if (profile == null) return;
        if (isPerakendeci && profile.perId != null) {
          await provider.fetchForPerakendeci(profile.perId!);
        } else if (!isPerakendeci && profile.topId != null) {
          await provider.fetchForToptanci(profile.topId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
        itemCount: list.length,
        itemBuilder: (_, i) => _SiparisCard(siparis: list[i]),
      ),
    );
  }
}

class _SiparisCard extends StatelessWidget {
  final Siparis siparis;
  const _SiparisCard({required this.siparis});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final renk = siparisRengi(siparis.durum);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OrderDetailScreen(sipId: siparis.sipId)),
          ),
          child: Row(
            children: [
              // Sol durum çubuğu
              Container(
                width: 5,
                height: 100,
                decoration: BoxDecoration(
                  color: renk,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Sol ikon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: renk.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long, color: renk, size: 22),
                ),
              ),
              // İçerik
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sipariş #${siparis.sipId}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: renk.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              siparis.durum,
                              style: TextStyle(
                                  color: renk,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 12, color: kTextSecondary),
                          const SizedBox(width: 4),
                          Text(
                            siparis.siparisTarihi,
                            style: const TextStyle(
                                color: kTextSecondary, fontSize: 12),
                          ),
                          if (siparis.firmaAdi != null) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.business_outlined,
                                size: 12, color: kTextSecondary),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                siparis.firmaAdi!,
                                style: const TextStyle(
                                    color: kTextSecondary, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (siparis.odemeTuru != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                siparis.odemeTuru!,
                                style: const TextStyle(
                                    color: kTextSecondary, fontSize: 11),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            fmt.format(siparis.toplamTutar),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
