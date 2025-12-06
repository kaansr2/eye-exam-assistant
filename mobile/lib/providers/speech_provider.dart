import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/speech_service.dart';
import '../utils/medical_terms.dart';
import '../config/app_config.dart';

/// Speech state management provider
/// ChangeNotifier ile state management sağlar
class SpeechProvider extends ChangeNotifier {
  final SpeechService _speechService = SpeechService();

  // State değişkenleri
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;
  String _currentText = ''; // Anlık tanınan metin
  String _fullTranscription = ''; // Tüm transkripsiyon
  final List<String> _transcriptionHistory = []; // Transkripsiyon geçmişi
  String? _errorMessage;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get currentText => _currentText;
  String get fullTranscription => _fullTranscription;
  List<String> get transcriptionHistory => List.unmodifiable(_transcriptionHistory);
  String? get errorMessage => _errorMessage;
  Duration get recordingDuration => _recordingDuration;

  /// Son N cümleyi al
  List<String> get recentTranscriptions {
    const maxItems = 5;
    if (_transcriptionHistory.length <= maxItems) {
      return _transcriptionHistory;
    }
    return _transcriptionHistory.sublist(_transcriptionHistory.length - maxItems);
  }

  /// Provider'ı başlat
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isAvailable = await _speechService.initialize();
      _isInitialized = true;

      // Callback'leri ayarla
      _speechService.onResult = _onSpeechResult;
      _speechService.onPartialResult = _onPartialResult;
      _speechService.onError = _onSpeechError;
      _speechService.onListeningStarted = _onListeningStarted;
      _speechService.onListeningStopped = _onListeningStopped;

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechProvider: Başlatıldı, available: $_isAvailable');
      }

      notifyListeners();
      return _isAvailable;
    } catch (e) {
      _errorMessage = 'Ses tanıma başlatılamadı: $e';
      notifyListeners();
      return false;
    }
  }

  /// Dinlemeye başla
  Future<void> startListening() async {
    if (_isListening) return;

    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    _errorMessage = null;
    await _speechService.startListening();
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speechService.stopListening();
  }

  /// Dinlemeyi aç/kapat
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Transkripsiyon temizle
  void clearTranscription() {
    _currentText = '';
    _fullTranscription = '';
    _transcriptionHistory.clear();
    _recordingDuration = Duration.zero;
    _errorMessage = null;
    notifyListeners();
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Transkripsiyon ekle (manuel)
  void addTranscription(String text) {
    if (text.isEmpty) return;

    // Tıbbi terimleri düzelt
    final correctedText = MedicalTerms.correctText(text);

    _transcriptionHistory.add(correctedText);
    _fullTranscription = _transcriptionHistory.join('\n');
    notifyListeners();
  }

  /// Mevcut metni tıbbi terimlerle düzelt
  String get correctedFullTranscription {
    return MedicalTerms.correctText(_fullTranscription);
  }

  /// Transkripsiyondan değerleri çıkar
  Map<String, dynamic> extractMedicalValues() {
    return MedicalTerms.extractValues(_fullTranscription);
  }

  /// Kayıt süresini formatla
  String get formattedDuration {
    final minutes = _recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ==================== PRIVATE METODLAR ====================

  /// Nihai sonuç callback'i
  void _onSpeechResult(String text) {
    if (text.isEmpty) return;

    // Tıbbi terimleri düzelt
    final correctedText = MedicalTerms.correctText(text);

    _currentText = '';
    _transcriptionHistory.add(correctedText);
    _fullTranscription = _transcriptionHistory.join('\n');

    if (AppConfig.isDebugMode) {
      debugPrint('SpeechProvider Result: $correctedText');
    }

    notifyListeners();
  }

  /// Kısmi sonuç callback'i
  void _onPartialResult(String text) {
    _currentText = text;
    notifyListeners();
  }

  /// Hata callback'i
  void _onSpeechError(String error) {
    _errorMessage = error;
    _isListening = false;
    _stopDurationTimer();
    notifyListeners();
  }

  /// Dinleme başladı callback'i
  void _onListeningStarted() {
    _isListening = true;
    _currentText = '';
    _startDurationTimer();
    notifyListeners();
  }

  /// Dinleme durdu callback'i
  void _onListeningStopped() {
    _isListening = false;
    _stopDurationTimer();

    // Kısmi metin varsa kaydet
    if (_currentText.isNotEmpty) {
      _onSpeechResult(_currentText);
    }

    notifyListeners();
  }

  /// Süre timer'ını başlat
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _recordingDuration = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  /// Süre timer'ını durdur
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _speechService.dispose();
    super.dispose();
  }
}
