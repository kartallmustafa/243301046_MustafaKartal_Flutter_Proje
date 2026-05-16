import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/urun.dart';
import '../../providers/urun_provider.dart';
import 'product_detail_screen.dart';

// Local asset fotoğrafları (Unsplash - ücretsiz)
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

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UrunProvider>();
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ürün Kataloğu'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => provider.fetchAll()),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(context, provider),
          Expanded(child: _buildGrid(provider, fmt)),
        ],
      ),
    );
  }

  Widget _buildFilter(BuildContext context, UrunProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _FilterBtn(
            label: 'Tümü',
            icon: Icons.apps,
            selected: provider.secilenTip == null,
            color: kPrimaryColor,
            onTap: () => provider.setTip(null),
          ),
          const SizedBox(width: 8),
          _FilterBtn(
            label: 'Cam',
            icon: Icons.lens_outlined,
            selected: provider.secilenTip == 'CAM',
            color: kAccentColor,
            onTap: () => provider.setTip('CAM'),
          ),
          const SizedBox(width: 8),
          _FilterBtn(
            label: 'Çerçeve',
            icon: Icons.remove_red_eye_outlined,
            selected: provider.secilenTip == 'CERCEVE',
            color: const Color(0xFF7B1FA2),
            onTap: () => provider.setTip('CERCEVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(UrunProvider provider, NumberFormat fmt) {
    if (provider.loading) return const Center(child: CircularProgressIndicator());
    final urunler = provider.urunler;
    if (urunler.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: kTextSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('Ürün bulunamadı', style: TextStyle(color: kTextSecondary)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: urunler.length,
      itemBuilder: (_, i) => _UrunCard(urun: urunler[i], fmt: fmt),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : kTextSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrunCard extends StatelessWidget {
  final Urun urun;
  final NumberFormat fmt;
  const _UrunCard({required this.urun, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isCam = urun.tip == 'CAM';
    final pool = isCam ? _camFotolar : _cerceveFotolar;
    final assetPath = pool[urun.urunId % pool.length];
    final accentColor = isCam ? kAccentColor : const Color(0xFF7B1FA2);
    final gradStart = isCam ? const Color(0xFF1565C0) : const Color(0xFF6A1B9A);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(urun: urun)),
      ),
      child: Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün fotoğrafı
          SizedBox(
            height: 130,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradStart, gradStart.withValues(alpha: 0.6)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.white54, size: 36),
                    ),
                  ),
                ),
                // Alt karartma bandı (tip etiketine kontrast için)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Tip etiketi (foto üstünde)
                Positioned(
                  bottom: 8, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCam ? kAccentColor : const Color(0xFF7B1FA2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCam ? 'CAM' : 'ÇERÇEVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Ürün bilgileri
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun.marka ?? urun.urunAdi,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (urun.model != null)
                    Text(
                      urun.model!,
                      style: const TextStyle(color: kTextSecondary, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  if (urun.renk != null)
                    Text(
                      urun.renk!,
                      style: TextStyle(
                          color: kTextSecondary.withValues(alpha: 0.75), fontSize: 10),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        fmt.format(urun.birimFiyat),
                        style: TextStyle(
                          color: gradStart,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.arrow_forward_ios, size: 11, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),   // Card
    );   // GestureDetector
  }
}
