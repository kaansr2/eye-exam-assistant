import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Ses tanıma servisi
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  bool _isInitialized = false;
  bool _isListening = false;
  
  // Callback'ler
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function(String)? onError;
  Function()? onListeningStarted;
  Function()? onListeningStopped;

  /// Servis durumu
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  /// Servisi başlat
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // TODO: speech_to_text paketini başlat
      // _speechToText = SpeechToText();
      // _isInitialized = await _speechToText.initialize(
      //   onStatus: _onStatus,
      //   onError: _onSpeechError,
      // );
      
      // Simüle edilmiş başarı
      await Future.delayed(const Duration(milliseconds: 100));
      _isInitialized = true;
      
      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Başlatıldı');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechService: Başlatma hatası - $e');
      return false;
    }
  }

  /// Dinlemeye başla
  Future<void> startListening() async {
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

      // TODO: Gerçek dinleme başlat
      // await _speechToText.listen(
      //   onResult: _onSpeechResult,
      //   localeId: AppConfig.speechLocale,
      //   listenFor: Duration(seconds: AppConfig.maxRecordingDurationSeconds),
      //   partialResults: true,
      //   cancelOnError: false,
      // );

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Dinleme başladı');
      }
    } catch (e) {
      _isListening = false;
      onError?.call('Dinleme başlatılamadı: $e');
    }
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      // TODO: Gerçek dinlemeyi durdur
      // await _speechToText.stop();
      
      _isListening = false;
      onListeningStopped?.call();

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Dinleme durduruldu');
      }
    } catch (e) {
      onError?.call('Dinleme durdurulamadı: $e');
    }
  }

  /// Dinlemeyi iptal et
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      // TODO: Gerçek dinlemeyi iptal et
      // await _speechToText.cancel();
      
      _isListening = false;
      onListeningStopped?.call();

      if (AppConfig.isDebugMode) {
        debugPrint('SpeechService: Dinleme iptal edildi');
      }
    } catch (e) {
      onError?.call('Dinleme iptal edilemedi: $e');
    }
  }

  /// Mevcut dilleri al
  Future<List<String>> getAvailableLocales() async {
    // TODO: Gerçek dil listesini al
    // final locales = await _speechToText.locales();
    // return locales.map((l) => l.localeId).toList();
    
    return ['tr-TR', 'en-US'];
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

  // TODO: Gerçek callback'leri implemente et
  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   if (result.finalResult) {
  //     onResult?.call(result.recognizedWords);
  //   } else {
  //     onPartialResult?.call(result.recognizedWords);
  //   }
  // }

  // void _onStatus(String status) {
  //   if (AppConfig.isDebugMode) {
  //     debugPrint('SpeechService Status: $status');
  //   }
  // }

  // void _onSpeechError(SpeechRecognitionError error) {
  //   onError?.call(error.errorMsg);
  //   _isListening = false;
  // }
}

/// Tıbbi terim düzeltme servisi
class MedicalTermCorrector {
  /// Göz terimleri sözlüğü
  static const Map<String, String> _eyeTerms = {
    // Görme keskinliği
    'vizyon': 'görme keskinliği',
    'gorme': 'görme',
    'görme': 'görme',
    
    // Katarakt
    'katarakt': 'katarakt',
    'nükleer': 'nükleer',
    'kortikal': 'kortikal',
    'subkapsüler': 'subkapsüler',
    'psk': 'PSC',
    'psc': 'PSC',
    
    // Glokom
    'glokom': 'glokom',
    'göz tansiyonu': 'göz içi basıncı',
    'tansiyon': 'göz içi basıncı',
    'iop': 'IOP',
    'cup disk': 'C/D oranı',
    
    // Retina
    'retina': 'retina',
    'makula': 'makula',
    'fundus': 'fundus',
    'optik disk': 'optik disk',
    'drusen': 'drusen',
    
    // Ön segment
    'kornea': 'kornea',
    'konjonktiva': 'konjonktiva',
    'iris': 'iris',
    'lens': 'lens',
    'ön kamara': 'ön kamara',
    'pupilla': 'pupilla',
    
    // Şikayetler
    'bulanık': 'bulanık görme',
    'çift görme': 'diplopi',
    'diplopi': 'diplopi',
    'kızarıklık': 'kızarıklık',
    'ağrı': 'ağrı',
    'kaşıntı': 'kaşıntı',
    'sulanma': 'sulanma',
    'fotofobi': 'ışığa hassasiyet',
  };

  /// Metni düzelt
  static String correctText(String text) {
    String corrected = text.toLowerCase();
    
    _eyeTerms.forEach((key, value) {
      corrected = corrected.replaceAll(key.toLowerCase(), value);
    });
    
    return corrected;
  }

  /// Sayısal değerleri çıkar
  static Map<String, dynamic> extractValues(String text) {
    final Map<String, dynamic> values = {};
    
    // Görme keskinliği pattern'leri
    final visionPattern = RegExp(r'(\d+)\s*[/üzerinden]\s*(\d+)');
    final visionMatches = visionPattern.allMatches(text);
    for (final match in visionMatches) {
      values['vision'] = '${match.group(1)}/${match.group(2)}';
    }
    
    // IOP pattern'leri
    final iopPattern = RegExp(r'(?:basınç|tansiyon|iop)\s*(\d+)');
    final iopMatches = iopPattern.allMatches(text.toLowerCase());
    for (final match in iopMatches) {
      values['iop'] = int.tryParse(match.group(1) ?? '');
    }
    
    // C/D oranı pattern'leri
    final cdPattern = RegExp(r'(?:cd|c/d|cup disk)\s*(?:oranı)?\s*([\d.]+)');
    final cdMatches = cdPattern.allMatches(text.toLowerCase());
    for (final match in cdMatches) {
      values['cd_ratio'] = double.tryParse(match.group(1) ?? '');
    }
    
    return values;
  }
}
