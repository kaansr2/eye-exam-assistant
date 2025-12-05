import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Muayene kartı widget'ı
class ExaminationCard extends StatelessWidget {
  final String patientName;
  final String diagnosis;
  final DateTime date;
  final bool hasImages;
  final bool isApproved;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExaminationCard({
    super.key,
    required this.patientName,
    required this.diagnosis,
    required this.date,
    this.hasImages = false,
    this.isApproved = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        side: isApproved
            ? const BorderSide(color: AppConfig.successColor, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: hasta adı ve tarih
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: AppConfig.primaryColor,
                    radius: 20,
                    child: Text(
                      patientName.isNotEmpty
                          ? patientName.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hasta adı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Durum ikonu
                  if (isApproved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConfig.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppConfig.successColor,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Onaylı',
                            style: TextStyle(
                              color: AppConfig.successColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Tanı
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        diagnosis.isNotEmpty ? diagnosis : 'Tanı girilmedi',
                        style: TextStyle(
                          color: diagnosis.isNotEmpty
                              ? Colors.grey[800]
                              : Colors.grey[500],
                          fontStyle: diagnosis.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Alt satır: simgeler ve aksiyonlar
              Row(
                children: [
                  // Görsel ikonu
                  if (hasImages)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConfig.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image,
                            size: 14,
                            color: AppConfig.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Görsel',
                            style: TextStyle(
                              color: AppConfig.primaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Düzenle butonu
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Düzenle',
                      color: Colors.grey[600],
                      visualDensity: VisualDensity.compact,
                    ),

                  // Sil butonu
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Sil',
                      color: AppConfig.errorColor,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarihi formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün ${_padZero(date.hour)}:${_padZero(date.minute)}';
    } else if (difference.inDays == 1) {
      return 'Dün ${_padZero(date.hour)}:${_padZero(date.minute)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${_padZero(date.day)}.${_padZero(date.month)}.${date.year}';
    }
  }

  String _padZero(int number) => number.toString().padLeft(2, '0');
}
