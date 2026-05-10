import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _passVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (!ok && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: kCriticalColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.remove_red_eye_outlined, size: 72, color: kPrimaryColor),
              const SizedBox(height: 16),
              const Text(
                'OptikTakip',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
              const Text(
                'Sipariş Takip Sistemi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kTextSecondary),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'E-posta giriniz';
                        if (!v.contains('@')) return 'Geçerli e-posta giriniz';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: !_passVisible,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _passVisible = !_passVisible),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifre giriniz';
                        if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    auth.loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _login,
                            icon: const Icon(Icons.login),
                            label: const Text('Giriş Yap'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Hesabınız yok mu? Kayıt olun'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTestAccounts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestAccounts() {
    return Card(
      color: const Color(0xFFE3F2FD),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Test Hesapları', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _testAccountRow('Perakendeci', 'perakendeci@optik.com', 'Optik2026!'),
            _testAccountRow('Toptancı', 'toptanci@optik.com', 'Optik2026!'),
          ],
        ),
      ),
    );
  }

  Widget _testAccountRow(String rol, String email, String sifre) {
    return GestureDetector(
      onTap: () {
        _emailCtrl.text = email;
        _passCtrl.text = sifre;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Chip(
              label: Text(rol, style: const TextStyle(fontSize: 11)),
              backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(email, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
