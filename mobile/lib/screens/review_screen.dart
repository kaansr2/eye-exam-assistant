import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

/// Onay ekranı - Tüm bilgileri gözden geçirme ve onaylama
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = false;
  bool _isEditing = false;
  
  // Düzenlenebilir alanlar
  final _sikayetController = TextEditingController();
  final _taniController = TextEditingController();
  final _tedaviController = TextEditingController();
  final _notlarController = TextEditingController();

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
    setState(() {
      _isLoading = true;
    });

    // TODO: API'ye muayene kaydet
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Constants.saveSuccess),
          backgroundColor: AppConfig.successColor,
        ),
      );
      
      // Ana ekrana dön
      Navigator.of(context).popUntil((route) => route.isFirst);
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
      return TextField(
        controller: _sikayetController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Hastanın şikayetini yazın...',
          border: OutlineInputBorder(),
        ),
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
    return Column(
      children: [
        _buildFindingRow('Görme Keskinliği (OD)', '-'),
        _buildFindingRow('Görme Keskinliği (OS)', '-'),
        _buildFindingRow('Göz İçi Basıncı (OD)', '- mmHg'),
        _buildFindingRow('Göz İçi Basıncı (OS)', '- mmHg'),
        _buildFindingRow('Ön Segment', 'Normal'),
        _buildFindingRow('Fundus', 'Normal'),
      ],
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
    // TODO: Gerçek fotoğraflarla değiştir
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Çekilen göz fotoğrafları burada görünecek',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  /// AI analizi
  Widget _buildAiAnalysis() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Önerileri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Görüntü analizi sonuçları ve önerilen tanılar burada görünecek.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Güven Skoru: ',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '-%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tanı ve tedavi
  Widget _buildDiagnosisTreatment() {
    if (_isEditing) {
      return Column(
        children: [
          TextField(
            controller: _taniController,
            decoration: const InputDecoration(
              labelText: 'Tanı',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tedaviController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Tedavi',
              border: OutlineInputBorder(),
            ),
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
      return TextField(
        controller: _notlarController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Ek notlar...',
          border: OutlineInputBorder(),
        ),
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveExamination,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.successColor,
          foregroundColor: Colors.white,
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle),
        label: Text(_isLoading ? 'Kaydediliyor...' : 'Onayla ve Kaydet'),
      ),
    );
  }
}
