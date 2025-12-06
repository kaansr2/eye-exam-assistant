import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../models/examination.dart';
import '../services/storage_service.dart';

/// Examination state management provider
/// Manages examination data flow across screens
class ExaminationProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  // Current examination data
  Patient? _currentPatient;
  String _transcript = '';
  Map<String, dynamic> _parsedFindings = {};
  List<Map<String, dynamic>> _eyeImages = [];
  Map<String, dynamic>? _aiAnalysis;
  
  // Additional fields
  String _basvuruSikayeti = '';
  String _tani = '';
  String _tedavi = '';
  String _notlar = '';
  
  // Loading states
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  // History
  List<Examination> _examinations = [];

  // Getters
  Patient? get currentPatient => _currentPatient;
  String get transcript => _transcript;
  Map<String, dynamic> get parsedFindings => Map.unmodifiable(_parsedFindings);
  List<Map<String, dynamic>> get eyeImages => List.unmodifiable(_eyeImages);
  Map<String, dynamic>? get aiAnalysis => _aiAnalysis;
  String get basvuruSikayeti => _basvuruSikayeti;
  String get tani => _tani;
  String get tedavi => _tedavi;
  String get notlar => _notlar;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  List<Examination> get examinations => List.unmodifiable(_examinations);

  /// Initialize provider
  Future<void> initialize() async {
    await loadExaminations();
  }

  /// Start new examination
  void startNewExamination(Patient patient) {
    _currentPatient = patient;
    _transcript = '';
    _parsedFindings = {};
    _eyeImages = [];
    _aiAnalysis = null;
    _basvuruSikayeti = '';
    _tani = '';
    _tedavi = '';
    _notlar = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Set patient
  void setPatient(Patient patient) {
    _currentPatient = patient;
    notifyListeners();
  }

  /// Set transcript
  void setTranscript(String transcript) {
    _transcript = transcript;
    notifyListeners();
  }

  /// Set parsed findings
  void setParsedFindings(Map<String, dynamic> findings) {
    _parsedFindings = findings;
    notifyListeners();
  }

  /// Add eye image
  void addEyeImage(Map<String, dynamic> image) {
    _eyeImages.add(image);
    notifyListeners();
  }

  /// Remove eye image
  void removeEyeImage(int index) {
    if (index >= 0 && index < _eyeImages.length) {
      _eyeImages.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear eye images
  void clearEyeImages() {
    _eyeImages.clear();
    notifyListeners();
  }

  /// Set AI analysis
  void setAiAnalysis(Map<String, dynamic> analysis) {
    _aiAnalysis = analysis;
    notifyListeners();
  }

  /// Update başvuru şikayeti
  void setBasvuruSikayeti(String text) {
    _basvuruSikayeti = text;
    notifyListeners();
  }

  /// Update tanı
  void setTani(String text) {
    _tani = text;
    notifyListeners();
  }

  /// Update tedavi
  void setTedavi(String text) {
    _tedavi = text;
    notifyListeners();
  }

  /// Update notlar
  void setNotlar(String text) {
    _notlar = text;
    notifyListeners();
  }

  /// Set analyzing state
  void setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    notifyListeners();
  }

  /// Get vision data from parsed findings
  VisionData? getVisionData() {
    if (_parsedFindings.isEmpty) return null;
    
    return VisionData(
      sagGozluksuz: _parsedFindings['gorme_keskinligi_od']?.toString(),
      solGozluksuz: _parsedFindings['gorme_keskinligi_os']?.toString(),
    );
  }

  /// Get IOP data from parsed findings
  IopData? getIopData() {
    if (_parsedFindings.isEmpty) return null;
    
    // Helper function to extract numeric value from IOP string
    double? parseIopValue(dynamic value) {
      if (value == null) return null;
      final str = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(str);
    }
    
    return IopData(
      sagIop: parseIopValue(_parsedFindings['iop_od']),
      solIop: parseIopValue(_parsedFindings['iop_os']),
    );
  }

  /// Get anterior segment data from parsed findings
  AnteriorSegmentData? getAnteriorSegmentData() {
    if (_parsedFindings.isEmpty) return null;
    
    return AnteriorSegmentData(
      kornea: _parsedFindings['kornea']?.toString(),
    );
  }

  /// Get posterior segment data from parsed findings
  PosteriorSegmentData? getPosteriorSegmentData() {
    if (_parsedFindings.isEmpty) return null;
    
    return PosteriorSegmentData(
      optikDisk: _parsedFindings['fundus']?.toString(),
    );
  }

  /// Save examination
  Future<bool> saveExamination() async {
    if (_currentPatient == null) {
      _errorMessage = 'Hasta bilgisi eksik';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create examination object
      final examination = Examination(
        patientId: _currentPatient!.id!,
        muayeneTarihi: DateTime.now(),
        basvuruSikayeti: _basvuruSikayeti.isNotEmpty ? _basvuruSikayeti : null,
        gormeKeskinligi: getVisionData(),
        gozIciBasinci: getIopData(),
        onSegment: getAnteriorSegmentData(),
        arkaSegment: getPosteriorSegmentData(),
        tani: _tani.isNotEmpty ? _tani : null,
        tedavi: _tedavi.isNotEmpty ? _tedavi : null,
        notlar: _notlar.isNotEmpty ? _notlar : null,
        gorsellerUrls: _eyeImages.map((img) => img['path']?.toString() ?? '').where((p) => p.isNotEmpty).toList(),
        aiAnalizi: _aiAnalysis != null ? AiAnalysisData(
          gorselAnalizSonucu: _aiAnalysis!['gorsel_analiz']?.toString(),
          metinAnalizSonucu: _aiAnalysis!['metin_analiz']?.toString(),
          guvenSkoru: _aiAnalysis!['guven_skoru'] != null 
              ? double.tryParse(_aiAnalysis!['guven_skoru'].toString())
              : null,
          onerilenTanilar: (_aiAnalysis!['onerilen_tanilar'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
          analizTarihi: DateTime.now(),
        ) : null,
      );

      final savedExamination = await _storageService.saveExamination(examination);
      _examinations.insert(0, savedExamination);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Muayene kaydedilirken hata: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load examinations from storage
  Future<void> loadExaminations() async {
    try {
      _isLoading = true;
      notifyListeners();

      _examinations = await _storageService.loadExaminations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Muayeneler yüklenirken hata: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get examinations for a patient
  List<Examination> getPatientExaminations(String patientId) {
    return _examinations.where((e) => e.patientId == patientId).toList();
  }

  /// Clear current examination
  void clearExamination() {
    _currentPatient = null;
    _transcript = '';
    _parsedFindings = {};
    _eyeImages = [];
    _aiAnalysis = null;
    _basvuruSikayeti = '';
    _tani = '';
    _tedavi = '';
    _notlar = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
