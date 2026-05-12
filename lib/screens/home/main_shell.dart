import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siparis_provider.dart';
import '../../providers/stok_provider.dart';
import '../../providers/urun_provider.dart';
import 'home_tab.dart';
import '../orders/orders_screen.dart';
import '../orders/new_order_screen.dart';
import '../products/products_screen.dart';
import '../stock/stock_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final profile = auth.profile;
    if (profile == null) return;

    if (profile.isPerakendeci && profile.perId != null) {
      context.read<SiparisProvider>().fetchForPerakendeci(profile.perId!);
    } else if (profile.isToptanci && profile.topId != null) {
      context.read<SiparisProvider>().fetchForToptanci(profile.topId!);
      context.read<StokProvider>().fetch(profile.topId!);
    }
    context.read<UrunProvider>().fetchAll();
  }

  List<Widget> _screens(bool isPerakendeci) {
    if (isPerakendeci) {
      return [
        const HomeTab(),
        const OrdersScreen(),
        const NewOrderScreen(),
        const ProductsScreen(),
        const ProfileScreen(),
      ];
    }
    return [
      const HomeTab(),
      const OrdersScreen(),
      const StockScreen(),
      const ProductsScreen(),
      const ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _navItems(bool isPerakendeci) {
    if (isPerakendeci) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Ana Sayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Siparişlerim'),
        BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), activeIcon: Icon(Icons.shopping_cart), label: 'Yeni Sipariş'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Ürünler'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profil'),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Ana Sayfa'),
      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Siparişler'),
      BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stok'),
      BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Ürünler'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final isPerakendeci = profile?.isPerakendeci ?? true;
    final screens = _screens(isPerakendeci);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems(isPerakendeci),
      ),
    );
  }
}
