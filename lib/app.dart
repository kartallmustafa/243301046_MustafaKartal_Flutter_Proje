import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/siparis_provider.dart';
import 'providers/urun_provider.dart';
import 'providers/stok_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_shell.dart';

class OptikTakipApp extends StatefulWidget {
  const OptikTakipApp({super.key});

  @override
  State<OptikTakipApp> createState() => _OptikTakipAppState();
}

class _OptikTakipAppState extends State<OptikTakipApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _authProvider.init();

    _router = GoRouter(
      refreshListenable: _authProvider,
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = _authProvider.isLoggedIn;
        final isAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (!loggedIn && !isAuth) return '/login';
        if (loggedIn && isAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const MainShell(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => SiparisProvider()),
        ChangeNotifierProvider(create: (_) => UrunProvider()),
        ChangeNotifierProvider(create: (_) => StokProvider()),
      ],
      child: MaterialApp.router(
        title: 'OptikTakip',
        theme: buildAppTheme(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
