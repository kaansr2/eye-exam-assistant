import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../providers/examination_provider.dart';

/// Hasta arama ve yeni hasta ekleme ekranı
class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _searchResults = [];
  bool _showNewPatientForm = false;

  // Yeni hasta formu kontrolleri
  final _formKey = GlobalKey<FormState>();
  final _tcController = TextEditingController();
  final _adSoyadController = TextEditingController();
  final _telefonController = TextEditingController();
  DateTime? _dogumTarihi;
  String _cinsiyet = Constants.male;

  @override
  void initState() {
    super.initState();
    // Load patients when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tcController.dispose();
    _adSoyadController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  /// Hasta arama işlemi
  void _searchPatient(String query) {
    final patientProvider = context.read<PatientProvider>();
    setState(() {
      _searchResults = patientProvider.searchPatients(query);
    });
  }

  /// Yeni hasta kaydetme
  Future<void> _saveNewPatient() async {
    if (!_formKey.currentState!.validate() || _dogumTarihi == null) {
      if (_dogumTarihi == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen doğum tarihi seçin')),
        );
      }
      return;
    }

    final newPatient = Patient(
      tcKimlikNo: _tcController.text,
      adSoyad: _adSoyadController.text,
      dogumTarihi: _dogumTarihi!,
      cinsiyet: _cinsiyet,
      telefon: _telefonController.text.isNotEmpty ? _telefonController.text : null,
    );

    final patientProvider = context.read<PatientProvider>();
    final success = await patientProvider.addPatient(newPatient);

    if (!mounted) return;

    if (success) {
      // Start new examination with this patient
      final examinationProvider = context.read<ExaminationProvider>();
      examinationProvider.startNewExamination(patientProvider.currentPatient!);

      // Navigate to recording screen
      Navigator.pushNamed(context, '/recording');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(patientProvider.errorMessage ?? 'Hasta kaydedilemedi'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
    }
  }

  /// Doğum tarihi seçici
  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _dogumTarihi = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Seçimi'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Arama çubuğu
              _buildSearchBar(),
              
              const SizedBox(height: AppConfig.defaultPadding),
              
              // Yeni hasta ekle butonu veya arama sonuçları
              Expanded(
                child: _showNewPatientForm
                    ? _buildNewPatientForm()
                    : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
      // Yeni hasta ekle FAB
      floatingActionButton: !_showNewPatientForm
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _showNewPatientForm = true;
                });
              },
              icon: const Icon(Icons.person_add),
              label: const Text(Constants.addPatient),
            )
          : null,
    );
  }

  /// Arama çubuğu
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: Constants.searchPatientHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchPatient('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: _searchPatient,
    );
  }

  /// Arama sonuçları
  Widget _buildSearchResults() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        final isLoading = patientProvider.isLoading;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              Constants.noPatientFound,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showNewPatientForm = true;
                  // TC'yi otomatik doldur
                  if (_searchController.text.length == 11) {
                    _tcController.text = _searchController.text;
                  }
                });
              },
              icon: const Icon(Icons.person_add),
              label: const Text(Constants.addPatient),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'TC Kimlik No veya isim ile hasta arayın',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final patient = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConfig.primaryColor,
              child: Text(
                patient.adSoyad.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(patient.adSoyad),
            subtitle: Text('TC: ${patient.tcKimlikNo} • ${patient.yas} yaş'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Set current patient and start examination
              final examinationProvider = context.read<ExaminationProvider>();
              examinationProvider.startNewExamination(patient);
              
              Navigator.pushNamed(context, '/recording');
            },
          ),
        );
      },
    );
      },
    );
  }

  /// Yeni hasta formu
  Widget _buildNewPatientForm() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        final isLoading = patientProvider.isLoading;

        return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık ve geri butonu
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _showNewPatientForm = false;
                    });
                  },
                ),
                Text(
                  'Yeni Hasta Ekle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: AppConfig.defaultPadding),
            
            // TC Kimlik No
            TextFormField(
              controller: _tcController,
              decoration: const InputDecoration(
                labelText: 'TC Kimlik No *',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 11,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'TC Kimlik No zorunludur';
                }
                if (value.length != 11) {
                  return 'TC Kimlik No 11 haneli olmalıdır';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConfig.defaultPadding),
            
            // Ad Soyad
            TextFormField(
              controller: _adSoyadController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ad Soyad zorunludur';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConfig.defaultPadding),
            
            // Doğum Tarihi
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Doğum Tarihi *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dogumTarihi != null
                      ? '${_dogumTarihi!.day.toString().padLeft(2, '0')}.${_dogumTarihi!.month.toString().padLeft(2, '0')}.${_dogumTarihi!.year}'
                      : 'Seçiniz',
                  style: TextStyle(
                    color: _dogumTarihi != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppConfig.defaultPadding),
            
            // Cinsiyet
            DropdownButtonFormField<String>(
              value: _cinsiyet,
              decoration: const InputDecoration(
                labelText: 'Cinsiyet *',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
              items: [Constants.male, Constants.female]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _cinsiyet = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: AppConfig.defaultPadding),
            
            // Telefon (opsiyonel)
            TextFormField(
              controller: _telefonController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: 'Opsiyonel',
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: AppConfig.largePadding),
            
            // Kaydet butonu
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _saveNewPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isLoading ? 'Kaydediliyor...' : 'Kaydet ve Devam Et'),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
