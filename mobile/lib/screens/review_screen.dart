import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:io';
import '../config/app_config.dart';
import '../utils/constants.dart';
import '../providers/examination_provider.dart';
import '../services/gemini_service.dart';
import '../widgets/voice_text_field.dart';
import '../widgets/ai_analysis_card.dart';

/// Onay ekranı - Tüm bilgileri gözden geçirme ve onaylama
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isEditing = false;
  
  // Düzenlenebilir alanlar
  final _sikayetController = TextEditingController();
  final _taniController = TextEditingController();
  final _tedaviController = TextEditingController();
  final _notlarController = TextEditingController();

  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examinationProvider = context.read<ExaminationProvider>();
      _sikayetController.text = examinationProvider.basvuruSikayeti;
      _taniController.text = examinationProvider.tani;
      _tedaviController.text = examinationProvider.tedavi;
      _notlarController.text = examinationProvider.notlar;
    });
  }

  @override
  void dispose() {
    _sikayetController.dispose();
    _taniController.dispose();
    _tedaviController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  /// Muayeneyi kaydet
  Future<void> _saveExamination() async {
    final examinationProvider = context.read<ExaminationProvider>();

    // Update fields from controllers
    examinationProvider.setBasvuruSikayeti(_sikayetController.text);
    examinationProvider.setTani(_taniController.text);
    examinationProvider.setTedavi(_tedaviController.text);
    examinationProvider.setNotlar(_notlarController.text);

    final success = await examinationProvider.saveExamination();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Constants.saveSuccess),
          backgroundColor: AppConfig.successColor,
        ),
      );
      
      // Ana ekrana dön
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(examinationProvider.errorMessage ?? 'Kaydedilemedi'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
    }
  }

  /// AI analizi yap
  Future<void> _performAiAnalysis() async {
    final examinationProvider = context.read<ExaminationProvider>();

    if (!GeminiService.isConfigured()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gemini API key yapılandırılmamış'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
      return;
    }

    examinationProvider.setAnalyzing(true);

    try {
      final transcript = examinationProvider.transcript;
      final images = examinationProvider.eyeImages;

      // If we have images, do combined analysis
      if (images.isNotEmpty && transcript.isNotEmpty) {
        // Load image bytes
        final imageBytesList = <Uint8List>[];
        for (final img in images) {
          try {
            final file = File(img['path']);
            if (await file.exists()) {
              imageBytesList.add(await file.readAsBytes());
            }
          } catch (e) {
            // Skip if image can't be loaded
          }
        }

        final analysis = await _geminiService.analyzeCombined(
          transcript,
          imageBytesList,
        );
        examinationProvider.setAiAnalysis(analysis);
      } else if (transcript.isNotEmpty) {
        // Text only analysis
        final analysis = await _geminiService.analyzeExamination(transcript);
        examinationProvider.setAiAnalysis(analysis);
      } else {
        throw Exception('Analiz için veri bulunamadı');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI analizi tamamlandı'),
            backgroundColor: AppConfig.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI analiz hatası: $e'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      examinationProvider.setAnalyzing(false);
    }
  }

  /// Düzenleme modunu aç/kapat
  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muayene Özeti'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            tooltip: _isEditing ? 'Düzenlemeyi Bitir' : Constants.edit,
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // İçerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConfig.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hasta bilgisi
                    _buildSectionCard(
                      title: 'Hasta Bilgileri',
                      icon: Icons.person,
                      child: _buildPatientInfo(),
                    ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Başvuru şikayeti
                    _buildSectionCard(
                      title: 'Başvuru Şikayeti',
                      icon: Icons.medical_information,
                      child: _buildComplaintSection(),
                    ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Muayene bulguları
                    _buildSectionCard(
                      title: 'Muayene Bulguları',
                      icon: Icons.visibility,
                      child: _buildExaminationFindings(),
                    ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Göz fotoğrafları
                    _buildSectionCard(
                      title: 'Göz Fotoğrafları',
                      icon: Icons.photo_library,
                      child: _buildImagesSection(),
                    ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // AI Analizi
                    _buildSectionCard(
                      title: 'AI Analizi',
                      icon: Icons.auto_awesome,
                      child: _buildAiAnalysis(),
                    ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Tanı ve Tedavi
                    _buildSectionCard(
                      title: 'Tanı ve Tedavi',
                      icon: Icons.local_hospital,
                      child: _buildDiagnosisTreatment(),
                    ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Notlar
                    _buildSectionCard(
                      title: 'Ek Notlar',
                      icon: Icons.note,
                      child: _buildNotesSection(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Kaydet butonu
            Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Bölüm kartı
  Widget _buildSectionCard({
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

  /// Hasta bilgisi
  Widget _buildPatientInfo() {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        final patient = examinationProvider.currentPatient;
        
        if (patient == null) {
          return Column(
            children: [
              _buildInfoRow('Ad Soyad', 'Hasta Adı'),
              _buildInfoRow('TC Kimlik No', '***********'),
              _buildInfoRow('Yaş', '- yaş'),
              _buildInfoRow('Cinsiyet', '-'),
              _buildInfoRow('Muayene Tarihi', DateTime.now().toString().split(' ')[0]),
            ],
          );
        }

        return Column(
          children: [
            _buildInfoRow('Ad Soyad', patient.adSoyad),
            _buildInfoRow('TC Kimlik No', patient.tcKimlikNo),
            _buildInfoRow('Yaş', '${patient.yas} yaş'),
            _buildInfoRow('Cinsiyet', patient.cinsiyet),
            _buildInfoRow('Muayene Tarihi', DateTime.now().toString().split(' ')[0]),
          ],
        );
      },
    );
  }

  /// Bilgi satırı
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  /// Şikayet bölümü
  Widget _buildComplaintSection() {
    if (_isEditing) {
      return VoiceTextField(
        controller: _sikayetController,
        label: 'Başvuru Şikayeti',
        hint: 'Hastanın şikayetini yazın...',
        maxLines: 3,
        onChanged: (value) {
          // Update provider when text changes
          context.read<ExaminationProvider>().setBasvuruSikayeti(value);
        },
      );
    }
    
    return Text(
      _sikayetController.text.isEmpty
          ? 'Ses kaydından çıkarılan şikayet bilgisi burada görünecek.'
          : _sikayetController.text,
      style: TextStyle(
        color: _sikayetController.text.isEmpty ? Colors.grey : Colors.black,
      ),
    );
  }

  /// Muayene bulguları
  Widget _buildExaminationFindings() {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        final findings = examinationProvider.parsedFindings;
        
        return Column(
          children: [
            _buildFindingRow(
              'Görme Keskinliği (OD)',
              findings['gorme_keskinligi_od']?.toString() ?? '-',
            ),
            _buildFindingRow(
              'Görme Keskinliği (OS)',
              findings['gorme_keskinligi_os']?.toString() ?? '-',
            ),
            _buildFindingRow(
              'Göz İçi Basıncı (OD)',
              findings['iop_od']?.toString() ?? '- mmHg',
            ),
            _buildFindingRow(
              'Göz İçi Basıncı (OS)',
              findings['iop_os']?.toString() ?? '- mmHg',
            ),
            _buildFindingRow(
              'Ön Segment',
              findings['on_segment']?.toString() ?? 'Normal',
            ),
            _buildFindingRow(
              'Fundus',
              findings['fundus']?.toString() ?? 'Normal',
            ),
          ],
        );
      },
    );
  }

  /// Bulgu satırı
  Widget _buildFindingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Fotoğraflar bölümü
  Widget _buildImagesSection() {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        final images = examinationProvider.eyeImages;
        
        if (images.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Göz fotoğrafı eklenmedi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              final eyeLabel = image['eye'] == 'right' ? 'OD' : 'OS';
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        image: image['path'] != null 
                            ? DecorationImage(
                                image: FileImage(File(image['path'])),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: image['path'] == null
                          ? Icon(Icons.image, color: Colors.grey[600], size: 32)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eyeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// AI analizi
  Widget _buildAiAnalysis() {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        return AiAnalysisCard(
          analysis: examinationProvider.aiAnalysis,
          isLoading: examinationProvider.isAnalyzing,
          onAnalyze: _performAiAnalysis,
        );
      },
    );
  }

  /// Tanı ve tedavi
  Widget _buildDiagnosisTreatment() {
    if (_isEditing) {
      return Column(
        children: [
          VoiceTextField(
            controller: _taniController,
            label: 'Tanı',
            maxLines: 2,
            onChanged: (value) {
              context.read<ExaminationProvider>().setTani(value);
            },
          ),
          const SizedBox(height: 12),
          VoiceTextField(
            controller: _tedaviController,
            label: 'Tedavi',
            maxLines: 3,
            onChanged: (value) {
              context.read<ExaminationProvider>().setTedavi(value);
            },
          ),
        ],
      );
    }
    
    return Column(
      children: [
        _buildInfoRow('Tanı', _taniController.text.isEmpty ? '-' : _taniController.text),
        _buildInfoRow('Tedavi', _tedaviController.text.isEmpty ? '-' : _tedaviController.text),
      ],
    );
  }

  /// Notlar bölümü
  Widget _buildNotesSection() {
    if (_isEditing) {
      return VoiceTextField(
        controller: _notlarController,
        label: 'Ek Notlar',
        hint: 'Ek notlar...',
        maxLines: 3,
        onChanged: (value) {
          context.read<ExaminationProvider>().setNotlar(value);
        },
      );
    }
    
    return Text(
      _notlarController.text.isEmpty ? 'Not eklenmedi.' : _notlarController.text,
      style: TextStyle(
        color: _notlarController.text.isEmpty ? Colors.grey : Colors.black,
      ),
    );
  }

  /// Kaydet butonu
  Widget _buildSaveButton() {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        final isLoading = examinationProvider.isLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _saveExamination,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.successColor,
              foregroundColor: Colors.white,
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(isLoading ? 'Kaydediliyor...' : 'Onayla ve Kaydet'),
          ),
        );
      },
    );
  }
}
