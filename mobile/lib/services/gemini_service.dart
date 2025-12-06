import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for Gemini AI integration
/// Provides text and image analysis capabilities
class GeminiService {
  // API key from environment variable
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  GenerativeModel? _textModel;
  GenerativeModel? _visionModel;

  /// Initialize models
  void initialize() {
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not configured');
    }

    _textModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );

    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );
  }

  /// Analyze examination transcript and provide medical insights
  Future<Map<String, dynamic>> analyzeExamination(String transcript) async {
    if (_textModel == null) initialize();

    try {
      final prompt = '''
Göz muayenesi bulgularını analiz et ve aşağıdaki formatta yanıt ver:

Transkript:
$transcript

Lütfen şunları analiz et:
1. Bulgularda anormallik var mı?
2. Olası tanılar nelerdir? (en az 2, en fazla 5)
3. Önerilen ek testler veya takip
4. Risk faktörleri
5. Güven skoru (0-100 arası)

Yanıtı JSON formatında ver:
{
  "analiz_ozeti": "Kısa özet",
  "anormallikler": ["liste"],
  "onerilen_tanilar": ["tanı1", "tanı2"],
  "onerilen_testler": ["test1", "test2"],
  "risk_faktorleri": ["risk1"],
  "guven_skoru": 85,
  "uyarilar": ["uyarı metni varsa"]
}
''';

      final content = [Content.text(prompt)];
      final response = await _textModel!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini boş yanıt döndü');
      }

      // Extract JSON from response (might have markdown formatting)
      String jsonStr = response.text!;
      if (jsonStr.contains('```json')) {
        final startIndex = jsonStr.indexOf('```json') + 7;
        final endIndex = jsonStr.indexOf('```', startIndex);
        jsonStr = jsonStr.substring(startIndex, endIndex).trim();
      } else if (jsonStr.contains('```')) {
        final startIndex = jsonStr.indexOf('```') + 3;
        final endIndex = jsonStr.indexOf('```', startIndex);
        jsonStr = jsonStr.substring(startIndex, endIndex).trim();
      }

      // For now, return a structured response
      // In production, parse the JSON response
      return {
        'metin_analiz': response.text,
        'timestamp': DateTime.now().toIso8601String(),
        'model': 'gemini-2.0-flash-exp',
      };
    } catch (e) {
      throw Exception('Gemini analiz hatası: $e');
    }
  }

  /// Analyze eye image for abnormalities
  Future<Map<String, dynamic>> analyzeEyeImage(Uint8List imageBytes) async {
    if (_visionModel == null) initialize();

    try {
      final prompt = '''
Bu göz fotoğrafını analiz et ve aşağıdaki konularda değerlendirme yap:

1. Görüntü kalitesi uygun mu?
2. Görünür anormallikler var mı?
3. Dikkat çekilmesi gereken bulgular
4. Öneri ve uyarılar
5. Güven skoru (0-100)

Yanıtı JSON formatında ver:
{
  "goruntu_kalitesi": "iyi/orta/kötü",
  "anormallik_tespiti": "var/yok",
  "tespit_edilen_bulgular": ["bulgu1", "bulgu2"],
  "oneriler": ["öneri1"],
  "guven_skoru": 80,
  "uyarilar": ["DİKKAT: Bu bir ön değerlendirmedir, kesin tanı için uzman muayenesi gereklidir."]
}
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _visionModel!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini boş yanıt döndü');
      }

      return {
        'gorsel_analiz': response.text,
        'timestamp': DateTime.now().toIso8601String(),
        'model': 'gemini-2.0-flash-exp',
      };
    } catch (e) {
      throw Exception('Gemini görüntü analiz hatası: $e');
    }
  }

  /// Combined analysis - both transcript and images
  Future<Map<String, dynamic>> analyzeCombined(
    String transcript,
    List<Uint8List> images,
  ) async {
    final results = <String, dynamic>{};

    // Analyze text
    try {
      final textAnalysis = await analyzeExamination(transcript);
      results['metin_analiz'] = textAnalysis['metin_analiz'];
    } catch (e) {
      results['metin_analiz_hata'] = e.toString();
    }

    // Analyze images
    final imageAnalyses = <Map<String, dynamic>>[];
    for (var i = 0; i < images.length; i++) {
      try {
        final imageAnalysis = await analyzeEyeImage(images[i]);
        imageAnalyses.add({
          'index': i,
          'analiz': imageAnalysis['gorsel_analiz'],
        });
      } catch (e) {
        imageAnalyses.add({
          'index': i,
          'hata': e.toString(),
        });
      }
    }
    results['gorsel_analizler'] = imageAnalyses;

    // Overall confidence score - calculate from analyses if available
    // For now, return null if no analyses succeeded
    double? overallConfidence;
    if (results.containsKey('metin_analiz') || imageAnalyses.isNotEmpty) {
      // TODO: Calculate actual confidence from analysis results
      // This is a placeholder and should be replaced with actual logic
      overallConfidence = null;
    }
    
    if (overallConfidence != null) {
      results['guven_skoru'] = overallConfidence;
    }

    // Suggested diagnoses (would be extracted from AI response)
    results['onerilen_tanilar'] = <String>[];

    results['timestamp'] = DateTime.now().toIso8601String();

    return results;
  }

  /// Check if API key is configured
  static bool isConfigured() {
    return apiKey.isNotEmpty;
  }
}
