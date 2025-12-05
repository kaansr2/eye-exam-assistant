import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

/// Geçmiş ekranı - Hasta muayene geçmişi listesi
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _examinations = [];

  @override
  void initState() {
    super.initState();
    _loadExaminations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Muayeneleri yükle
  Future<void> _loadExaminations() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: API'den muayene geçmişini al
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
      // Simüle edilmiş veriler - gerçek API entegrasyonunda değişecek
      _examinations = [];
    });
  }

  /// Arama yap
  void _searchExaminations(String query) {
    // TODO: Arama filtrelemesi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muayene Geçmişi'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Arama çubuğu
            Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Hasta adı veya tarih ile arayın...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchExaminations('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _searchExaminations,
              ),
            ),

            // Filtreler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Bugün', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Bu Hafta', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Bu Ay', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Tümü', false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConfig.defaultPadding),

            // Muayene listesi
            Expanded(
              child: _buildExaminationsList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Filtre chip'i
  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Filtre uygula
      },
      selectedColor: AppConfig.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConfig.primaryColor,
    );
  }

  /// Muayene listesi
  Widget _buildExaminationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_examinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              Constants.noExaminationFound,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni muayene oluşturmak için ana ekrana dönün.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExaminations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
        itemCount: _examinations.length,
        itemBuilder: (context, index) {
          final examination = _examinations[index];
          return _buildExaminationCard(examination);
        },
      ),
    );
  }

  /// Muayene kartı
  Widget _buildExaminationCard(Map<String, dynamic> examination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Muayene detayına git
        },
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Row(
            children: [
              // Hasta avatarı
              CircleAvatar(
                backgroundColor: AppConfig.primaryColor,
                radius: 24,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      examination['patientName'] ?? 'Hasta Adı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      examination['diagnosis'] ?? 'Tanı bilgisi',
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          examination['date'] ?? '-',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Ok ikonu
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
