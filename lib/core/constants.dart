import 'package:flutter/material.dart';

const String supabaseUrl = 'https://fxyqwmnrmlxcxrbpngdv.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4eXF3bW5ybWx4Y3hyYnBuZ2R2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNjU3MjUsImV4cCI6MjA5NDk0MTcyNX0.Tcwxf7Y53BO6NfZ_R-J4-LbaGR0eMM-0lDlzpM2kygM';

// Uygulama renkleri
const Color kPrimaryColor = Color(0xFF1565C0);
const Color kAccentColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kCardColor = Colors.white;
const Color kCriticalColor = Color(0xFFD32F2F);
const Color kLowColor = Color(0xFFF57C00);
const Color kNormalColor = Color(0xFF388E3C);
const Color kTextSecondary = Color(0xFF757575);

const List<String> kSiparisDurumlari = ['Hazırlanıyor', 'Kargoda', 'Teslim Edildi', 'İptal'];
const List<String> kKargoDurumlari = ['Hazırlanıyor', 'Dağıtımda', 'Teslim Edildi', 'İptal'];
const List<String> kOdemeTurleri = ['Havale', 'Kredi Kartı'];
const List<String> kUrunTipleri = ['CAM', 'CERCEVE'];
const String kRolePerakendeci = 'perakendeci';
const String kRoleToptanci = 'toptanci';
const int kMinStokDefault = 5;

Color siparisRengi(String durum) {
  switch (durum) {
    case 'Hazırlanıyor': return kLowColor;
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