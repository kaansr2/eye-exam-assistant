import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../config/app_config.dart';
import '../models/examination.dart';
import '../models/patient.dart';

/// Examination detail screen - Shows full details of a past examination
class ExaminationDetailScreen extends StatelessWidget {
  final Examination examination;
  final Patient? patient;

  const ExaminationDetailScreen({
    super.key,
    required this.examination,
    this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');
    final dateStr = dateFormat.format(examination.muayeneTarihi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muayene Detayı'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Info Card
              _buildSectionCard(
                context,
                title: 'Hasta Bilgileri',
                icon: Icons.person,
                child: _buildPatientInfo(context),
              ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Examination Date
              _buildSectionCard(
                context,
                title: 'Muayene Tarihi',
                icon: Icons.calendar_today,
                child: Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Chief Complaint
              if (examination.basvuruSikayeti != null &&
                  examination.basvuruSikayeti!.isNotEmpty)
                _buildSectionCard(
                  context,
                  title: 'Başvuru Şikayeti',
                  icon: Icons.medical_information,
                  child: Text(
                    examination.basvuruSikayeti!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Vision Acuity
              if (examination.gormeKeskinligi != null)
                _buildSectionCard(
                  context,
                  title: 'Görme Keskinliği',
                  icon: Icons.visibility,
                  child: _buildVisionData(context),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // IOP
              if (examination.gozIciBasinci != null)
                _buildSectionCard(
                  context,
                  title: 'Göz İçi Basıncı',
                  icon: Icons.speed,
                  child: _buildIopData(context),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Anterior Segment
              if (examination.onSegment != null)
                _buildSectionCard(
                  context,
                  title: 'Ön Segment',
                  icon: Icons.remove_red_eye,
                  child: _buildAnteriorSegment(context),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Posterior Segment
              if (examination.arkaSegment != null)
                _buildSectionCard(
                  context,
                  title: 'Arka Segment / Fundus',
                  icon: Icons.center_focus_strong,
                  child: _buildPosteriorSegment(context),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Eye Images
              if (examination.gorsellerUrls != null &&
                  examination.gorsellerUrls!.isNotEmpty)
                _buildSectionCard(
                  context,
                  title: 'Göz Fotoğrafları',
                  icon: Icons.photo_library,
                  child: _buildEyeImages(context),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Diagnosis
              if (examination.tani != null && examination.tani!.isNotEmpty)
                _buildSectionCard(
                  context,
                  title: 'Tanı',
                  icon: Icons.local_hospital,
                  child: Text(
                    examination.tani!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Treatment
              if (examination.tedavi != null && examination.tedavi!.isNotEmpty)
                _buildSectionCard(
                  context,
                  title: 'Tedavi',
                  icon: Icons.medication,
                  child: Text(
                    examination.tedavi!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // AI Analysis
              if (examination.aiAnalizi != null)
                _buildSectionCard(
                  context,
                  title: 'AI Analizi',
                  icon: Icons.auto_awesome,
                  child: _buildAiAnalysis(context),
                ),

              const SizedBox(height: AppConfig.defaultPadding),

              // Notes
              if (examination.notlar != null && examination.notlar!.isNotEmpty)
                _buildSectionCard(
                  context,
                  title: 'Ek Notlar',
                  icon: Icons.note,
                  child: Text(
                    examination.notlar!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConfig.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo(BuildContext context) {
    if (patient == null) {
      return const Text('Hasta bilgisi bulunamadı');
    }

    return Column(
      children: [
        _buildInfoRow(context, 'Ad Soyad', patient!.adSoyad),
        _buildInfoRow(context, 'TC Kimlik No', patient!.tcKimlikNo),
        _buildInfoRow(context, 'Yaş', '${patient!.yas} yaş'),
        _buildInfoRow(context, 'Cinsiyet', patient!.cinsiyet),
        if (patient!.telefon != null && patient!.telefon!.isNotEmpty)
          _buildInfoRow(context, 'Telefon', patient!.telefon!),
      ],
    );
  }

  Widget _buildVisionData(BuildContext context) {
    final vision = examination.gormeKeskinligi!;
    return Column(
      children: [
        if (vision.sagGozluksuz != null)
          _buildInfoRow(context, 'Sağ Göz (Gözlüksüz)', vision.sagGozluksuz!),
        if (vision.solGozluksuz != null)
          _buildInfoRow(context, 'Sol Göz (Gözlüksüz)', vision.solGozluksuz!),
        if (vision.sagGozluklu != null)
          _buildInfoRow(context, 'Sağ Göz (Gözlüklü)', vision.sagGozluklu!),
        if (vision.solGozluklu != null)
          _buildInfoRow(context, 'Sol Göz (Gözlüklü)', vision.solGozluklu!),
      ],
    );
  }

  Widget _buildIopData(BuildContext context) {
    final iop = examination.gozIciBasinci!;
    return Column(
      children: [
        if (iop.sagIop != null)
          _buildInfoRow(context, 'Sağ Göz', '${iop.sagIop} mmHg'),
        if (iop.solIop != null)
          _buildInfoRow(context, 'Sol Göz', '${iop.solIop} mmHg'),
      ],
    );
  }

  Widget _buildAnteriorSegment(BuildContext context) {
    final anterior = examination.onSegment!;
    return Column(
      children: [
        if (anterior.kornea != null)
          _buildInfoRow(context, 'Kornea', anterior.kornea!),
        if (anterior.onKamaraDerinligi != null)
          _buildInfoRow(context, 'Ön Kamara', anterior.onKamaraDerinligi!),
        if (anterior.iris != null) _buildInfoRow(context, 'İris', anterior.iris!),
        if (anterior.lens != null) _buildInfoRow(context, 'Lens', anterior.lens!),
      ],
    );
  }

  Widget _buildPosteriorSegment(BuildContext context) {
    final posterior = examination.arkaSegment!;
    return Column(
      children: [
        if (posterior.optikDisk != null)
          _buildInfoRow(context, 'Optik Disk', posterior.optikDisk!),
        if (posterior.makula != null)
          _buildInfoRow(context, 'Makula', posterior.makula!),
        if (posterior.retina != null)
          _buildInfoRow(context, 'Retina', posterior.retina!),
        if (posterior.vitreus != null)
          _buildInfoRow(context, 'Vitreus', posterior.vitreus!),
      ],
    );
  }

  Widget _buildEyeImages(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: examination.gorsellerUrls!.length,
        itemBuilder: (context, index) {
          final imagePath = examination.gorsellerUrls![index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showImageDialog(context, imagePath),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(imagePath),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    final file = File(imagePath);
    
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data != true) {
          return Icon(Icons.broken_image, color: Colors.grey[600], size: 32);
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, color: Colors.grey[600], size: 32);
          },
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Görüntü yüklenemedi'),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAnalysis(BuildContext context) {
    final ai = examination.aiAnalizi!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ai.metinAnalizSonucu != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metin Analizi:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(ai.metinAnalizSonucu!),
              ],
            ),
          ),
        if (ai.gorselAnalizSonucu != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Görsel Analizi:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(ai.gorselAnalizSonucu!),
              ],
            ),
          ),
        if (ai.guvenSkoru != null)
          _buildInfoRow(
              context, 'Güven Skoru', '${(ai.guvenSkoru! * 100).toInt()}%'),
        if (ai.onerilenTanilar != null && ai.onerilenTanilar!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Önerilen Tanılar:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                ...ai.onerilenTanilar!
                    .map((tani) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              const Text('• '),
                              Expanded(child: Text(tani)),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
