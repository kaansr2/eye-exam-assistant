import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';
import 'constants.dart';

/// Uygulama izin yönetimi sınıfı
class AppPermissionHandler {
  /// Mikrofon izni kontrolü ve isteme
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied || await Permission.microphone.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(
          context,
          title: 'Mikrofon İzni Gerekli',
          message: Constants.microphonePermission,
        );
      }
      return false;
    }

    return false;
  }

  /// Kamera izni kontrolü ve isteme
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied || await Permission.camera.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(
          context,
          title: 'Kamera İzni Gerekli',
          message: Constants.cameraPermission,
        );
      }
      return false;
    }

    return false;
  }

  /// Mikrofon izni durumu kontrolü (dialog göstermeden)
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Kamera izni durumu kontrolü (dialog göstermeden)
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// İzin reddedildi dialog'u göster
  static Future<void> _showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppConfig.warningColor),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'Lütfen uygulama ayarlarından izin verin.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Ayarlara Git'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// İzin bilgi dialog'u göster (istemeden önce)
  static Future<bool> showPermissionInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: AppConfig.primaryColor),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu izin sadece bu özellik için kullanılacaktır.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('İzin Ver'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Tüm gerekli izinleri kontrol et ve iste
  static Future<Map<String, bool>> requestAllPermissions(BuildContext context) async {
    final results = <String, bool>{};

    // Mikrofon izni
    results['microphone'] = await requestMicrophonePermission(context);

    // Kamera izni
    if (context.mounted) {
      results['camera'] = await requestCameraPermission(context);
    } else {
      results['camera'] = false;
    }

    return results;
  }
}
