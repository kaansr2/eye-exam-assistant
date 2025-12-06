import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';
import '../models/examination.dart';

/// Local storage service using SharedPreferences
/// Handles CRUD operations for patients and examinations
class StorageService {
  static const String _patientsKey = 'patients';
  static const String _examinationsKey = 'examinations';
  
  final Uuid _uuid = const Uuid();

  /// Load all patients
  Future<List<Patient>> loadPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientsJson = prefs.getString(_patientsKey);
      
      if (patientsJson == null || patientsJson.isEmpty) {
        return [];
      }

      final List<dynamic> patientsList = json.decode(patientsJson);
      return patientsList.map((json) => Patient.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Hastalar yüklenemedi: $e');
    }
  }

  /// Save patient
  Future<Patient> savePatient(Patient patient) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patients = await loadPatients();

      // Generate ID if not exists
      final patientWithId = patient.id == null 
          ? patient.copyWith(id: _uuid.v4())
          : patient;

      patients.add(patientWithId);

      final patientsJson = json.encode(
        patients.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_patientsKey, patientsJson);

      return patientWithId;
    } catch (e) {
      throw Exception('Hasta kaydedilemedi: $e');
    }
  }

  /// Update patient
  Future<Patient> updatePatient(Patient patient) async {
    try {
      if (patient.id == null) {
        throw Exception('Hasta ID\'si bulunamadı');
      }

      final prefs = await SharedPreferences.getInstance();
      final patients = await loadPatients();

      final index = patients.indexWhere((p) => p.id == patient.id);
      if (index == -1) {
        throw Exception('Hasta bulunamadı');
      }

      patients[index] = patient;

      final patientsJson = json.encode(
        patients.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_patientsKey, patientsJson);

      return patient;
    } catch (e) {
      throw Exception('Hasta güncellenemedi: $e');
    }
  }

  /// Delete patient
  Future<void> deletePatient(String patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patients = await loadPatients();

      patients.removeWhere((p) => p.id == patientId);

      final patientsJson = json.encode(
        patients.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_patientsKey, patientsJson);
    } catch (e) {
      throw Exception('Hasta silinemedi: $e');
    }
  }

  /// Load all examinations
  Future<List<Examination>> loadExaminations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examinationsJson = prefs.getString(_examinationsKey);
      
      if (examinationsJson == null || examinationsJson.isEmpty) {
        return [];
      }

      final List<dynamic> examinationsList = json.decode(examinationsJson);
      return examinationsList.map((json) => Examination.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Muayeneler yüklenemedi: $e');
    }
  }

  /// Save examination
  Future<Examination> saveExamination(Examination examination) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examinations = await loadExaminations();

      // Generate ID if not exists
      final examinationWithId = examination.id == null 
          ? examination.copyWith(id: _uuid.v4())
          : examination;

      examinations.insert(0, examinationWithId); // Add to beginning

      final examinationsJson = json.encode(
        examinations.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_examinationsKey, examinationsJson);

      return examinationWithId;
    } catch (e) {
      throw Exception('Muayene kaydedilemedi: $e');
    }
  }

  /// Update examination
  Future<Examination> updateExamination(Examination examination) async {
    try {
      if (examination.id == null) {
        throw Exception('Muayene ID\'si bulunamadı');
      }

      final prefs = await SharedPreferences.getInstance();
      final examinations = await loadExaminations();

      final index = examinations.indexWhere((e) => e.id == examination.id);
      if (index == -1) {
        throw Exception('Muayene bulunamadı');
      }

      examinations[index] = examination;

      final examinationsJson = json.encode(
        examinations.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_examinationsKey, examinationsJson);

      return examination;
    } catch (e) {
      throw Exception('Muayene güncellenemedi: $e');
    }
  }

  /// Delete examination
  Future<void> deleteExamination(String examinationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examinations = await loadExaminations();

      examinations.removeWhere((e) => e.id == examinationId);

      final examinationsJson = json.encode(
        examinations.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_examinationsKey, examinationsJson);
    } catch (e) {
      throw Exception('Muayene silinemedi: $e');
    }
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientsKey);
    await prefs.remove(_examinationsKey);
  }
}
