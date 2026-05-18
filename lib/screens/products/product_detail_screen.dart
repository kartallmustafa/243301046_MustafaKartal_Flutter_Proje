import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/urun.dart';
import '../../providers/auth_provider.dart';
import '../orders/new_order_screen.dart';

// Aynı fotoğraf havuzu (products_screen ile tutarlı)
const _cerceveFotolar = [
  'assets/images/cerceve1.jpg',
  'assets/images/cerceve2.jpg',
  'assets/images/cerceve3.jpg',
  'assets/images/cerceve4.jpg',
  'assets/images/cerceve5.jpg',
];

const _camFotolar = [
  'assets/images/cam1.jpg',
  'assets/images/cam2.jpg',
  'assets/images/cam3.jpg',
  'assets/images/cam4.jpg',
  'assets/images/cam5.jpg',
];

class ProductDetailScreen extends StatelessWidget {
  final Urun urun;
  const ProductDetailScreen({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    final isCam = urun.tip == 'CAM';
    final pool = isCam ? _camFotolar : _cerceveFotolar;
    final assetPath = pool[urun.urunId % pool.length];
    final gradStart = isCam ? const Color(0xFF1565C0) : const Color(0xFF6A1B9A);
    final gradEnd = isCam ? const Color(0xFF29B6F6) : const Color(0xFFCE93D8);
    final tipRenk = isCam ? kAccentColor : const Color(0xFF7B1FA2);
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final profile = context.watch<AuthProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Büyük fotoğraf alanı (hero)
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: gradStart,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [gradStart, gradEnd],
                        ),
                      ),
                    ),
                  ),
                  // Alt karartma
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Tip etiketi
                  Positioned(
                    bottom: 20, left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: tipRenk,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isCam ? 'OPTİK CAM' : 'GÖZLÜK ÇERÇEVESİ',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          urun.marka ?? urun.urunAdi,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 8)]),
                        ),
                        if (urun.model != null)
                          Text(
                            urun.model!,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 6)]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fiyat bandı
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradStart, gradEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradStart.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Birim Fiyat',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        fmt.format(urun.birimFiyat),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCam ? Icons.lens_outlined : Icons.remove_red_eye_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ürün detayları kartı
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 20,
                          decoration: BoxDecoration(
                            color: gradStart,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Ürün Detayları',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _DetailRow(
                    icon: Icons.label_outline,
                    label: 'Ürün Adı',
                    value: urun.urunAdi,
                    color: gradStart,
                  ),
                  if (urun.marka != null)
                    _DetailRow(
                      icon: Icons.branding_watermark_outlined,
                      label: 'Marka',
                      value: urun.marka!,
                      color: gradStart,
                    ),
                  if (urun.model != null)
                    _DetailRow(
                      icon: Icons.style_outlined,
                      label: 'Model',
                      value: urun.model!,
                      color: gradStart,
                    ),
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Tip',
                    value: isCam ? 'Optik Cam' : 'Gözlük Çerçevesi',
                    color: tipRenk,
                    valueColor: tipRenk,
                    bold: true,
                  ),
                  if (urun.renk != null)
                    _DetailRow(
                      icon: Icons.palette_outlined,
                      label: 'Renk',
                      value: urun.renk!,
                      color: gradStart,
                    ),
                  if (urun.malzeme != null)
                    _DetailRow(
                      icon: Icons.layers_outlined,
                      label: 'Malzeme',
                      value: urun.malzeme!,
                      color: gradStart,
                    ),
                  if (urun.kategoriAdi != null)
                    _DetailRow(
                      icon: Icons.folder_outlined,
                      label: 'Kategori',
                      value: urun.kategoriAdi!,
                      color: gradStart,
                    ),
                  if (urun.firmaAdi != null)
                    _DetailRow(
                      icon: Icons.business_outlined,
                      label: 'Tedarikçi',
                      value: urun.firmaAdi!,
                      color: gradStart,
                      isLast: true,
                    )
                  else
                    const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Ürün açıklaması kartı
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4, height: 20,
                        decoration: BoxDecoration(
                          color: gradStart,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Ürün Hakkında',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _buildDescription(urun, isCam),
                    style: const TextStyle(
                        color: kTextSecondary, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          // Sipariş ver butonu (sadece perakendeci)
          if (profile?.isPerakendeci == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewOrderScreen(preselectedUrun: urun),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Sipariş Ver',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradStart,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: gradStart.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildDescription(Urun urun, bool isCam) {
    final parts = <String>[];
    if (isCam) {
      parts.add('${urun.marka ?? 'Bu'} markasının özel üretim optik camı.');
      if (urun.malzeme != null) parts.add('${urun.malzeme} malzemeden üretilmiştir.');
      parts.add('Yüksek netlik ve UV koruması sunan kaliteli cam.');
      if (urun.model != null) parts.add('${urun.model} serisi.');
    } else {
      parts.add('${urun.marka ?? 'Bu'} markasının şık gözlük çerçevesi.');
      if (urun.malzeme != null) parts.add('${urun.malzeme} malzemeden üretilmiştir.');
      if (urun.renk != null) parts.add('${urun.renk} renk seçeneğiyle sunulmaktadır.');
      parts.add('Ergonomik tasarımı ve dayanıklı yapısıyla uzun kullanım sunar.');
    }
    return parts.join(' ');
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? valueColor;
  final bool bold;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
    this.bold = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, isLast ? 16 : 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: kTextSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
