import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _role = kRolePerakendeci;
  bool _passVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _shopCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
      fullName: _nameCtrl.text.trim(),
      magazaAdi: _role == kRolePerakendeci ? _shopCtrl.text.trim() : null,
      firmaAdi: _role == kRoleToptanci ? _shopCtrl.text.trim() : null,
      telefon: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      sehir: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
    );
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
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Hesap Türü', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              RadioGroup<String>(
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
                child: const Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Perakendeci'),
                        subtitle: Text('Optik Mağazası'),
                        value: kRolePerakendeci,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Toptancı'),
                        subtitle: Text('Tedarikçi'),
                        value: kRoleToptanci,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Ad Soyad giriniz' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shopCtrl,
                decoration: InputDecoration(
                  labelText: _role == kRolePerakendeci ? 'Mağaza Adı' : 'Firma Adı',
                  prefixIcon: const Icon(Icons.store_outlined),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'İşletme adı giriniz' : null,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon (opsiyonel)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Şehir (opsiyonel)',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 24),
              auth.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _register,
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Kayıt Ol'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Zaten hesabınız var mı? Giriş yapın'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
