import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';
import '../providers/examination_provider.dart';
import '../providers/patient_provider.dart';
import '../models/examination.dart';
import 'examination_detail_screen.dart';

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
                child: _buildRecentExaminationsList(context),
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

  /// Son muayeneler listesi
  Widget _buildRecentExaminationsList(BuildContext context) {
    return Consumer2<ExaminationProvider, PatientProvider>(
      builder: (context, examinationProvider, patientProvider, _) {
        final examinations = examinationProvider.examinations;
        
        if (examinations.isEmpty) {
          return _buildEmptyState();
        }

        // Get recent 10 examinations
        final recentExams = examinations.take(10).toList();

        return ListView.builder(
          itemCount: recentExams.length,
          itemBuilder: (context, index) {
            final examination = recentExams[index];
            final patient = patientProvider.getPatientById(examination.patientId);
            
            return _buildExaminationCard(
              context,
              examination,
              patient?.adSoyad ?? 'Hasta Adı',
              patient,
            );
          },
        );
      },
    );
  }

  /// Build examination card
  Widget _buildExaminationCard(
    BuildContext context,
    Examination examination,
    String patientName,
    Patient? patient,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');
    final dateStr = dateFormat.format(examination.muayeneTarihi);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppConfig.primaryColor,
          radius: 24,
          child: Text(
            patientName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patientName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (examination.tani != null && examination.tani!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.medical_services, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      examination.tani!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to examination detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExaminationDetailScreen(
                examination: examination,
                patient: patient,
              ),
            ),
          );
        },
      ),
    );
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
