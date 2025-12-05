import 'package:flutter/material.dart';

/// Uygulama yapılandırma sabitleri
class AppConfig {
  // Uygulama bilgileri
  static const String appName = 'Göz Muayene Asistanı';
  static const String appVersion = '1.0.0';
  
  // API yapılandırması
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Tema renkleri
  static const Color primaryColor = Color(0xFF1976D2); // Mavi - Güven, profesyonellik
  static const Color secondaryColor = Color(0xFF26A69A); // Teal - Sağlık, temizlik
  static const Color errorColor = Color(0xFFD32F2F); // Kırmızı - Uyarılar
  static const Color successColor = Color(0xFF388E3C); // Yeşil - Başarı
  static const Color warningColor = Color(0xFFF57C00); // Turuncu - Dikkat
  
  // UI sabitleri
  static const double minButtonSize = 48.0; // Doktor dostu minimum buton boyutu
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 12.0;
  
  // Ses kayıt ayarları
  static const int maxRecordingDurationSeconds = 300; // 5 dakika
  static const String speechLocale = 'tr-TR'; // Türkçe
  
  // Kamera ayarları
  static const double imageQuality = 85.0;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Yerel depolama anahtarları
  static const String lastPatientIdKey = 'last_patient_id';
  static const String userPreferencesKey = 'user_preferences';
  
  // Validasyon
  static const int minTcKimlikLength = 11;
  static const int maxNameLength = 100;
  
  // Debug modu
  static const bool isDebugMode = true;
}
