import 'package:flutter/material.dart';

const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
const String supabaseAnonKey = 'YOUR_ANON_KEY';

// Uygulama renkleri
const Color kPrimaryColor = Color(0xFF1565C0);
const Color kAccentColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kCardColor = Colors.white;
const Color kCriticalColor = Color(0xFFD32F2F);
const Color kLowColor = Color(0xFFF57C00);
const Color kNormalColor = Color(0xFF388E3C);
const Color kTextSecondary = Color(0xFF757575);

// Siparis durumlari
const List<String> kSiparisDurumlari = [
  'Hazirlanıyor',
  'Kargoda',
  'Teslim Edildi',
  'İptal',
];

// Kargo durumlari
const List<String> kKargoDurumlari = [
  'Hazirlanıyor',
  'Dagıtımda',
  'Teslim Edildi',
  'İptal',
];

// Odeme turleri
const List<String> kOdemeTurleri = ['Havale', 'Kredi Kartı'];

// Urun tipleri
const List<String> kUrunTipleri = ['CAM', 'CERCEVE'];

// Kullanici rolleri
const String kRolePerakendeci = 'perakendeci';
const String kRoleToptanci = 'toptanci';

// Stok durum esikleri
const int kMinStokDefault = 5;

Color siparisRengi(String durum) {
  switch (durum) {
    case 'Hazirlanıyor': return kLowColor;
    case 'Kargoda': return kAccentColor;
    case 'Teslim Edildi': return kNormalColor;
    case 'İptal': return kCriticalColor;
    default: return kTextSecondary;
  }
}

Color stokRengi(int miktar, int minStok) {
  if (miktar <= 0) return kCriticalColor;
  if (miktar <= minStok) return kLowColor;
  return kNormalColor;
}

String stokDurumu(int miktar, int minStok) {
  if (miktar <= 0) return 'KRİTİK';
  if (miktar <= minStok) return 'DÜŞÜK';
  return 'NORMAL';
}