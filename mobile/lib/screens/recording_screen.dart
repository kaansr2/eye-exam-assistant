import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';
import '../utils/permission_handler.dart';
import '../providers/speech_provider.dart';
import '../providers/examination_provider.dart';
import '../services/transcript_parser.dart';
import '../widgets/voice_input_button.dart';

/// Ses kayıt ekranı - Doktor konuşmasını kaydetme ve transkripsiyon
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _permissionGranted = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// Ekranı başlat
  Future<void> _initializeScreen() async {
    // Mikrofon izni kontrolü
    _permissionGranted = await AppPermissionHandler.requestMicrophonePermission(context);
    
    if (_permissionGranted && mounted) {
      // Speech provider'ı başlat
      final speechProvider = context.read<SpeechProvider>();
      await speechProvider.initialize();
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Kayıt başlat/durdur
  void _toggleRecording() async {
    if (!_permissionGranted) {
      _permissionGranted = await AppPermissionHandler.requestMicrophonePermission(context);
      if (!_permissionGranted) return;
    }

    final speechProvider = context.read<SpeechProvider>();
    await speechProvider.toggleListening();
  }

  /// Transkripsiyon temizle
  void _clearTranscription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transkripsiyon Temizle'),
        content: const Text('Tüm transkripsiyon silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SpeechProvider>().clearTranscription();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  /// İleri git (Kamera ekranına)
  void _proceedToCamera() {
    final speechProvider = context.read<SpeechProvider>();
    final examinationProvider = context.read<ExaminationProvider>();
    
    // Kayıt devam ediyorsa durdur
    if (speechProvider.isListening) {
      speechProvider.stopListening();
    }

    // Save transcript to examination provider
    final transcript = speechProvider.fullTranscription;
    examinationProvider.setTranscript(transcript);

    // Parse transcript into findings
    final parsedFindings = TranscriptParser.parse(transcript);
    examinationProvider.setParsedFindings(parsedFindings);

    Navigator.pushNamed(context, '/camera');
  }

  /// Scroll'u en alta kaydır
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Kaydı'),
        actions: [
          Consumer<SpeechProvider>(
            builder: (context, provider, _) {
              if (provider.fullTranscription.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Transkripsiyon Temizle',
                onPressed: _clearTranscription,
              );
            },
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.defaultPadding),
                child: Column(
                  children: [
                    // Hasta bilgisi kartı
                    _buildPatientInfoCard(),

                    const SizedBox(height: AppConfig.defaultPadding),

                    // Hata mesajı
                    _buildErrorMessage(),

                    // Transkripsiyon alanı
                    Expanded(
                      child: _buildTranscriptionArea(),
                    ),

                    const SizedBox(height: AppConfig.defaultPadding),

                    // Kayıt kontrolları
                    _buildRecordingControls(),

                    const SizedBox(height: AppConfig.defaultPadding),

                    // İleri butonu
                    Consumer<SpeechProvider>(
                      builder: (context, provider, _) {
                        if (provider.fullTranscription.isEmpty && !provider.isListening) {
                          return const SizedBox();
                        }
                        return _buildNextButton();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Hasta bilgisi kartı
  Widget _buildPatientInfoCard() {
    return Consumer<ExaminationProvider>(
      builder: (context, examinationProvider, _) {
        final patient = examinationProvider.currentPatient;
        
        if (patient == null) {
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

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppConfig.primaryColor,
                  radius: 24,
                  child: Text(
                    patient.adSoyad.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.adSoyad,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'TC: ${patient.tcKimlikNo} • ${patient.yas} yaş • ${patient.cinsiyet}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hata mesajı widget'ı
  Widget _buildErrorMessage() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        if (provider.errorMessage == null) return const SizedBox();

        return Container(
          margin: const EdgeInsets.only(bottom: AppConfig.defaultPadding),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConfig.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppConfig.errorColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppConfig.errorColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(
                    color: AppConfig.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  context.read<SpeechProvider>().clearError();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Transkripsiyon alanı
  Widget _buildTranscriptionArea() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        // Yeni metin geldiğinde scroll'u en alta kaydır
        if (provider.fullTranscription.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
            border: Border.all(
              color: provider.isListening ? AppConfig.errorColor : Colors.grey[300]!,
              width: provider.isListening ? 2 : 1,
            ),
          ),
          child: provider.fullTranscription.isEmpty && provider.currentText.isEmpty
              ? _buildEmptyState(provider.isListening)
              : _buildTranscriptionContent(provider),
        );
      },
    );
  }

  /// Boş durum göstergesi
  Widget _buildEmptyState(bool isListening) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isListening ? Icons.mic : Icons.mic_off,
            size: 48,
            color: isListening ? AppConfig.errorColor : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isListening ? 'Dinleniyor...' : Constants.noRecordingYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isListening ? AppConfig.errorColor : Colors.grey[600],
            ),
          ),
          if (!isListening) ...[
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
          if (isListening) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppConfig.errorColor.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Transkripsiyon içeriği
  Widget _buildTranscriptionContent(SpeechProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Anlık metin göstergesi (kayıt sırasında)
        if (provider.isListening && provider.currentText.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConfig.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hearing,
                  size: 18,
                  color: AppConfig.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.currentText,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Transkripsiyon geçmişi
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tam transkripsiyon
                Text(
                  provider.fullTranscription,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                // Kayıt sırasında gösterge
                if (provider.isListening)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppConfig.errorColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dinleniyor...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Kayıt kontrolleri
  Widget _buildRecordingControls() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Kayıt süresi göstergesi
            if (provider.isListening)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConfig.errorColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppConfig.errorColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.formattedDuration,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

            // Animasyonlu mikrofon butonu
            AnimatedVoiceButton(
              isRecording: provider.isListening,
              size: 100,
              currentText: provider.currentText,
              onStartRecording: _toggleRecording,
              onStopRecording: _toggleRecording,
              enableHaptics: true,
            ),
          ],
        );
      },
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
}
