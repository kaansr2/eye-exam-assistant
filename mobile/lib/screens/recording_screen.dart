import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

/// Ses kayıt ekranı - Doktor konuşmasını kaydetme ve transkripsiyon
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _isRecording = false;
  String _transcription = '';
  Duration _recordingDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    // TODO: Ses kayıt servisini başlat
  }

  @override
  void dispose() {
    // TODO: Ses kayıt servisini temizle
    super.dispose();
  }

  /// Kayıt başlat/durdur
  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Kayıt durdurulduğunda
        // TODO: Ses kaydını işle
      }
    });
  }

  /// Transkripsiyon temizle
  void _clearTranscription() {
    setState(() {
      _transcription = '';
    });
  }

  /// İleri git (Kamera ekranına)
  void _proceedToCamera() {
    Navigator.pushNamed(context, '/camera', arguments: {
      'transcription': _transcription,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Kaydı'),
        actions: [
          if (_transcription.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Transkripsiyon Temizle',
              onPressed: _clearTranscription,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            children: [
              // Hasta bilgisi kartı
              _buildPatientInfoCard(),
              
              const SizedBox(height: AppConfig.defaultPadding),
              
              // Transkripsiyon alanı
              Expanded(
                child: _buildTranscriptionArea(),
              ),
              
              const SizedBox(height: AppConfig.defaultPadding),
              
              // Kayıt kontrolları
              _buildRecordingControls(),
              
              const SizedBox(height: AppConfig.defaultPadding),
              
              // İleri butonu
              if (_transcription.isNotEmpty || !_isRecording)
                _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Hasta bilgisi kartı
  Widget _buildPatientInfoCard() {
    // TODO: Argümanlardan hasta bilgisini al
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppConfig.primaryColor,
              radius: 24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasta Adı',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'TC: *********** • - yaş',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Transkripsiyon alanı
  Widget _buildTranscriptionArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        border: Border.all(
          color: _isRecording ? AppConfig.errorColor : Colors.grey[300]!,
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: _transcription.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRecording ? Icons.mic : Icons.mic_off,
                    size: 48,
                    color: _isRecording ? AppConfig.errorColor : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRecording
                        ? 'Dinleniyor...'
                        : Constants.noRecordingYet,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (!_isRecording) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Muayene bulgularını sesli olarak söyleyin',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
          : SingleChildScrollView(
              child: Text(
                _transcription,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
    );
  }

  /// Kayıt kontrolleri
  Widget _buildRecordingControls() {
    return Column(
      children: [
        // Kayıt süresi göstergesi
        if (_isRecording)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fiber_manual_record, color: AppConfig.errorColor, size: 12),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordingDuration),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        
        // Büyük mikrofon butonu
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppConfig.errorColor : AppConfig.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppConfig.errorColor : AppConfig.primaryColor)
                      .withOpacity(0.3),
                  spreadRadius: _isRecording ? 8 : 4,
                  blurRadius: _isRecording ? 16 : 8,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Buton yazısı
        Text(
          _isRecording ? Constants.stopRecording : Constants.startRecording,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isRecording ? AppConfig.errorColor : AppConfig.primaryColor,
          ),
        ),
      ],
    );
  }

  /// İleri butonu
  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _proceedToCamera,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.secondaryColor,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Göz Fotoğrafı Çek'),
      ),
    );
  }

  /// Süre formatlama
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
