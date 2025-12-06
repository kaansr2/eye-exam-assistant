import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/patient_search_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/review_screen.dart';
import 'screens/history_screen.dart';
import 'config/app_config.dart';
import 'providers/speech_provider.dart';

void main() {
  runApp(const EyeExamAssistantApp());
}

/// Ana uygulama widget'ı
class EyeExamAssistantApp extends StatelessWidget {
  const EyeExamAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        // Localization support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'), // Türkçe
          Locale('en', 'US'), // İngilizce (fallback)
        ],
        locale: const Locale('tr', 'TR'), // Varsayılan Türkçe
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConfig.primaryColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // Büyük butonlar için varsayılan ayarlar
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // Yüksek kontrast için metin temaları
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          // AppBar teması
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        // Koyu tema desteği
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConfig.primaryColor,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          // Büyük butonlar için varsayılan ayarlar
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // Yüksek kontrast için metin temaları
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          // AppBar teması
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system, // Sistem temasını takip et
        // Uygulama rotaları
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/patient-search': (context) => const PatientSearchScreen(),
          '/recording': (context) => const RecordingScreen(),
          '/camera': (context) => const CameraScreen(),
          '/review': (context) => const ReviewScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}
