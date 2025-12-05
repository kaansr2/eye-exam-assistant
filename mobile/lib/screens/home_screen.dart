import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

/// Ana ekran - Yeni muayene başlatma ve son muayeneler listesi
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () {
              // TODO: Ayarlar sayfasına git
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Büyük "Yeni Muayene Başlat" butonu
              _buildNewExaminationButton(context),
              
              const SizedBox(height: AppConfig.largePadding),
              
              // Son muayeneler başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son Muayeneler',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/history');
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Tümünü Gör'),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConfig.defaultPadding),
              
              // Son muayeneler listesi
              Expanded(
                child: _buildRecentExaminationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Büyük "Yeni Muayene Başlat" butonu
  Widget _buildNewExaminationButton(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/patient-search');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
          ),
          elevation: 4,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48),
            SizedBox(height: 8),
            Text(
              Constants.newExamination,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// Son muayeneler listesi (placeholder)
  Widget _buildRecentExaminationsList() {
    // TODO: Gerçek verilerle değiştir
    // Şu an için boş liste göster
    return _buildEmptyState();
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            Constants.noExaminationFound,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni muayene başlatmak için yukarıdaki butona tıklayın.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
