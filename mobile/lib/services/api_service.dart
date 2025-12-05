import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/patient.dart';
import '../models/examination.dart';

/// Backend API servisi
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.apiBaseUrl;

  /// HTTP GET isteği
  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('İstek başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }

  /// HTTP POST isteği
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ApiException('İstek başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }

  /// HTTP PUT isteği
  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('İstek başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }

  /// HTTP DELETE isteği
  Future<void> _delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException('İstek başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Bağlantı hatası: $e');
    }
  }

  // ==================== HASTA İŞLEMLERİ ====================

  /// Hasta ara (TC veya isimle)
  Future<List<Patient>> searchPatients(String query) async {
    final response = await _get('/patients/search?q=$query');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => Patient.fromJson(json)).toList();
  }

  /// Hasta detayı getir
  Future<Patient> getPatient(String patientId) async {
    final response = await _get('/patients/$patientId');
    return Patient.fromJson(response['data']);
  }

  /// Yeni hasta oluştur
  Future<Patient> createPatient(Patient patient) async {
    final response = await _post('/patients', patient.toJson());
    return Patient.fromJson(response['data']);
  }

  /// Hasta güncelle
  Future<Patient> updatePatient(String patientId, Patient patient) async {
    final response = await _put('/patients/$patientId', patient.toJson());
    return Patient.fromJson(response['data']);
  }

  /// Hasta sil
  Future<void> deletePatient(String patientId) async {
    await _delete('/patients/$patientId');
  }

  // ==================== MUAYENE İŞLEMLERİ ====================

  /// Hasta muayene geçmişi
  Future<List<Examination>> getPatientExaminations(String patientId) async {
    final response = await _get('/patients/$patientId/examinations');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => Examination.fromJson(json)).toList();
  }

  /// Tüm muayeneler (son X tane)
  Future<List<Examination>> getRecentExaminations({int limit = 10}) async {
    final response = await _get('/examinations?limit=$limit');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => Examination.fromJson(json)).toList();
  }

  /// Muayene detayı
  Future<Examination> getExamination(String examinationId) async {
    final response = await _get('/examinations/$examinationId');
    return Examination.fromJson(response['data']);
  }

  /// Yeni muayene oluştur
  Future<Examination> createExamination(Examination examination) async {
    final response = await _post('/examinations', examination.toJson());
    return Examination.fromJson(response['data']);
  }

  /// Muayene güncelle
  Future<Examination> updateExamination(String examinationId, Examination examination) async {
    final response = await _put('/examinations/$examinationId', examination.toJson());
    return Examination.fromJson(response['data']);
  }

  /// Muayene sil
  Future<void> deleteExamination(String examinationId) async {
    await _delete('/examinations/$examinationId');
  }

  // ==================== AI ANALİZ İŞLEMLERİ ====================

  /// Görüntü analizi (Gemini)
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    // TODO: Multipart form data ile görüntü gönderimi
    final response = await _post('/analysis/image', {'image_path': imagePath});
    return response['data'];
  }

  /// Metin analizi (NLP)
  Future<Map<String, dynamic>> analyzeText(String text) async {
    final response = await _post('/analysis/text', {'text': text});
    return response['data'];
  }

  /// Transkripsiyon analizi
  Future<Map<String, dynamic>> analyzeTranscription(String transcription) async {
    final response = await _post('/analysis/transcription', {'transcription': transcription});
    return response['data'];
  }
}

/// API hata sınıfı
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
