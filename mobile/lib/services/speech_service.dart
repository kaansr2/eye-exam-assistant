import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../config/app_config.dart';
import '../utils/medical_terms.dart';

/// Ses tanıma servisi - speech_to_text paketi ile
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  /// Speech to text instance
  final SpeechToText _speechToText = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastStatus = '';
  
  // Callback'ler
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function(String)? onError;
  Function()? onListeningStarted;
  Function()? onListeningStopped;

  /// Servis durumu
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastStatus => _lastStatus;

  /// Servisi başlat
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: _onSpeechError,
        debugLogging: AppConfig.isDebugMode,
      );
      
      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Başlatıldı - $_isInitialized');
        final locales = await _speechToText.locales();
        debugPrint('SpeechService: Mevcut diller - ${locales.map((l) => l.localeId).join(', ')}');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechService: Başlatma hatası - $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Dinlemeye başla
  Future<void> startListening({String? localeId}) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        onError?.call('Ses tanıma servisi başlatılamadı');
        return;
      }
    }

    if (_isListening) return;

    try {
      _isListening = true;
      onListeningStarted?.call();

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: localeId ?? AppConfig.speechLocale,
        listenFor: Duration(seconds: AppConfig.maxRecordingDurationSeconds),
        pauseFor: const Duration(seconds: 3), // 3 saniye sessizlikten sonra dur
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation, // Dikte modu - uzun konuşmalar için
      );

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Dinleme başladı (locale: ${localeId ?? AppConfig.speechLocale})');
      }
    } catch (e) {
      _isListening = false;
      onError?.call('Dinleme başlatılamadı: $e');
      debugPrint('SpeechService: Dinleme hatası - $e');
    }
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      onListeningStopped?.call();

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Dinleme durduruldu');
      }
    } catch (e) {
      onError?.call('Dinleme durdurulamadı: $e');
      debugPrint('SpeechService: Durdurma hatası - $e');
    }
  }

  /// Dinlemeyi iptal et
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.cancel();
      _isListening = false;
      onListeningStopped?.call();

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Dinleme iptal edildi');
      }
    } catch (e) {
      onError?.call('Dinleme iptal edilemedi: $e');
      debugPrint('SpeechService: İptal hatası - $e');
    }
  }

  /// Mevcut dilleri al
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speechToText.locales();
  }

  /// Türkçe dil desteği var mı kontrol et
  Future<bool> hasTurkishSupport() async {
    final locales = await getAvailableLocales();
    return locales.any((l) => 
      l.localeId.toLowerCase().contains('tr') ||
      l.name.toLowerCase().contains('türk') ||
      l.name.toLowerCase().contains('turk')
    );
  }

  /// Servisi temizle
  void dispose() {
    stopListening();
    _isInitialized = false;
    onResult = null;
    onPartialResult = null;
    onError = null;
    onListeningStarted = null;
    onListeningStopped = null;
  }

  // ==================== PRIVATE METODLAR ====================

  /// Ses tanıma sonucu callback'i
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      // Nihai sonuç
      onResult?.call(result.recognizedWords);
      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService Final: ${result.recognizedWords}');
        debugPrint('SpeechService Confidence: ${result.confidence}');
      }
    } else {
      // Kısmi sonuç
      onPartialResult?.call(result.recognizedWords);
      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService Partial: ${result.recognizedWords}');
      }
    }
  }

  /// Durum değişikliği callback'i
  void _onStatus(String status) {
    _lastStatus = status;
    
    if (AppConfig.isDebugMode) {
      debugPrint('SpeechService Status: $status');
    }

    // Durum değişikliklerini işle
    switch (status) {
      case 'listening':
        if (!_isListening) {
          _isListening = true;
          onListeningStarted?.call();
        }
        break;
      case 'notListening':
      case 'done':
        if (_isListening) {
          _isListening = false;
          onListeningStopped?.call();
        }
        break;
    }
  }

  /// Hata callback'i
  void _onSpeechError(SpeechRecognitionError error) {
    final errorMessage = _getErrorMessage(error);
    onError?.call(errorMessage);
    _isListening = false;
    
    if (AppConfig.isDebugMode) {
      debugPrint('SpeechService Error: ${error.errorMsg} (permanent: ${error.permanent})');
    }
  }

  /// Hata mesajını kullanıcı dostu hale getir
  String _getErrorMessage(SpeechRecognitionError error) {
    switch (error.errorMsg) {
      case 'error_no_match':
        return 'Konuşma algılanamadı. Lütfen tekrar deneyin.';
      case 'error_speech_timeout':
        return 'Konuşma zaman aşımına uğradı.';
      case 'error_audio':
        return 'Ses kaydı hatası. Mikrofonu kontrol edin.';
      case 'error_server':
        return 'Sunucu hatası. İnternet bağlantınızı kontrol edin.';
      case 'error_network':
        return 'Ağ hatası. İnternet bağlantınızı kontrol edin.';
      case 'error_permission':
        return 'Mikrofon izni gerekli.';
      case 'error_busy':
        return 'Ses tanıma meşgul. Lütfen bekleyin.';
      default:
        return 'Ses tanıma hatası: ${error.errorMsg}';
    }
  }
}

/// Tıbbi terim düzeltme servisi - MedicalTerms'i kullanır
/// @deprecated MedicalTerms sınıfını doğrudan kullanın
class MedicalTermCorrector {
  /// Metni düzelt
  static String correctText(String text) {
    return MedicalTerms.correctText(text);
  }

  /// Sayısal değerleri çıkar
  static Map<String, dynamic> extractValues(String text) {
    return MedicalTerms.extractValues(text);
  }
}
