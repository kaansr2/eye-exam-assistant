import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Widget to display AI analysis results
/// Shows analysis status, results, and confidence scores
class AiAnalysisCard extends StatelessWidget {
  final Map<String, dynamic>? analysis;
  final bool isLoading;
  final String? error;
  final VoidCallback? onAnalyze;
  final bool showAnalyzeButton;

  const AiAnalysisCard({
    super.key,
    this.analysis,
    this.isLoading = false,
    this.error,
    this.onAnalyze,
    this.showAnalyzeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppConfig.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Analizi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primaryColor,
                      ),
                ),
                const Spacer(),
                if (showAnalyzeButton && onAnalyze != null && !isLoading)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onAnalyze,
                    tooltip: 'Yeniden Analiz Et',
                  ),
              ],
            ),
            
            const Divider(),
            
            // Content
            if (isLoading)
              _buildLoadingState()
            else if (error != null)
              _buildErrorState(error!)
            else if (analysis != null)
              _buildAnalysisResults(analysis!)
            else
              _buildEmptyState(),
            
            // Analyze button
            if (showAnalyzeButton && onAnalyze != null && analysis == null && !isLoading)
              _buildAnalyzeButton(),
          ],
        ),
      ),
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI analizi yapılıyor...'),
          ],
        ),
      ),
    );
  }

  /// Error state
  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConfig.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppConfig.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'AI analizi henüz yapılmadı',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Analysis results
  Widget _buildAnalysisResults(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confidence score
        if (data.containsKey('guven_skoru'))
          _buildConfidenceScore(data['guven_skoru']),
        
        const SizedBox(height: 16),
        
        // Text analysis
        if (data.containsKey('metin_analiz'))
          _buildSection(
            'Metin Analizi',
            data['metin_analiz'].toString(),
            Icons.description,
          ),
        
        // Image analysis
        if (data.containsKey('gorsel_analiz'))
          _buildSection(
            'Görsel Analiz',
            data['gorsel_analiz'].toString(),
            Icons.image,
          ),
        
        // Suggested diagnoses
        if (data.containsKey('onerilen_tanilar') && data['onerilen_tanilar'] is List)
          _buildDiagnosesList(data['onerilen_tanilar'] as List),
        
        // Warning
        const SizedBox(height: 16),
        _buildWarning(),
      ],
    );
  }

  /// Confidence score display
  Widget _buildConfidenceScore(dynamic score) {
    final scoreValue = score is num ? score.toDouble() : 0.0;
    final scorePercent = scoreValue.clamp(0.0, 100.0);
    
    Color scoreColor;
    if (scorePercent >= 80) {
      scoreColor = AppConfig.successColor;
    } else if (scorePercent >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = AppConfig.errorColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: scoreColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Güven Skoru',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            '${scorePercent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Section builder
  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppConfig.primaryColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Diagnoses list
  Widget _buildDiagnosesList(List diagnoses) {
    if (diagnoses.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.medical_services, size: 18, color: AppConfig.primaryColor),
            SizedBox(width: 6),
            Text(
              'Önerilen Tanılar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...diagnoses.map((diagnosis) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.chevron_right, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  diagnosis.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Warning message
  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bu bir ön değerlendirmedir. Kesin tanı için uzman muayenesi gereklidir.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Analyze button
  Widget _buildAnalyzeButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAnalyze,
          icon: const Icon(Icons.psychology),
          label: const Text('AI Analizi Yap'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
