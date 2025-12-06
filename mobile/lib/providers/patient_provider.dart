import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/storage_service.dart';

/// Patient state management provider
/// Manages patient list, search, and CRUD operations
class PatientProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Patient> _patients = [];
  Patient? _currentPatient;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Patient> get patients => List.unmodifiable(_patients);
  Patient? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize provider and load patients
  Future<void> initialize() async {
    await loadPatients();
  }

  /// Load patients from storage
  Future<void> loadPatients() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _patients = await _storageService.loadPatients();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Hastalar yüklenirken hata: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search patients by TC or name
  List<Patient> searchPatients(String query) {
    if (query.isEmpty) return _patients;

    final lowerQuery = query.toLowerCase();
    return _patients.where((patient) {
      return patient.tcKimlikNo.contains(query) ||
          patient.adSoyad.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Add new patient
  Future<bool> addPatient(Patient patient) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if patient with same TC already exists
      final existingIndex = _patients.indexWhere(
        (p) => p.tcKimlikNo == patient.tcKimlikNo,
      );

      if (existingIndex != -1) {
        _errorMessage = 'Bu TC Kimlik No ile kayıtlı hasta zaten var';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final savedPatient = await _storageService.savePatient(patient);
      _patients.add(savedPatient);
      _currentPatient = savedPatient;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Hasta kaydedilirken hata: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing patient
  Future<bool> updatePatient(Patient patient) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedPatient = await _storageService.updatePatient(patient);
      
      final index = _patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        _patients[index] = updatedPatient;
        if (_currentPatient?.id == patient.id) {
          _currentPatient = updatedPatient;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Hasta güncellenirken hata: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete patient
  Future<bool> deletePatient(String patientId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _storageService.deletePatient(patientId);
      _patients.removeWhere((p) => p.id == patientId);
      
      if (_currentPatient?.id == patientId) {
        _currentPatient = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Hasta silinirken hata: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set current patient
  void setCurrentPatient(Patient? patient) {
    _currentPatient = patient;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get patient by ID
  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get patient by TC
  Patient? getPatientByTc(String tcKimlikNo) {
    try {
      return _patients.firstWhere((p) => p.tcKimlikNo == tcKimlikNo);
    } catch (e) {
      return null;
    }
  }
}
