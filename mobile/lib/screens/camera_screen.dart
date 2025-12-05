import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

/// Kamera ekranı - Göz fotoğrafı çekme
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _selectedEye = 'right'; // 'right', 'left', 'both'
  bool _isCameraReady = false;
  bool _isCapturing = false;
  final List<Map<String, dynamic>> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Kamera başlatma
  Future<void> _initializeCamera() async {
    // TODO: Kamera servisini başlat
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isCameraReady = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Kamera servisini temizle
    super.dispose();
  }

  /// Fotoğraf çek
  Future<void> _captureImage() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    // TODO: Gerçek fotoğraf çekme işlemi
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _capturedImages.add({
        'eye': _selectedEye,
        'timestamp': DateTime.now(),
        // 'path': imagePath,
      });
      _isCapturing = false;
    });

    // Başarılı mesajı göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getEyeLabel(_selectedEye)} fotoğrafı çekildi'),
          backgroundColor: AppConfig.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Çekilen fotoğrafı sil
  void _deleteImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  /// Onay ekranına git
  void _proceedToReview() {
    Navigator.pushNamed(context, '/review', arguments: {
      'images': _capturedImages,
    });
  }

  /// Göz etiketi al
  String _getEyeLabel(String eye) {
    switch (eye) {
      case 'right':
        return Constants.rightEye;
      case 'left':
        return Constants.leftEye;
      case 'both':
        return Constants.bothEyes;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Göz Fotoğrafı'),
        actions: [
          if (_capturedImages.isNotEmpty)
            TextButton.icon(
              onPressed: _proceedToReview,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('İleri'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kamera önizleme alanı
            Expanded(
              flex: 3,
              child: _buildCameraPreview(),
            ),
            
            // Göz seçimi ve kontroller
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.defaultPadding),
                child: Column(
                  children: [
                    // Göz seçimi
                    _buildEyeSelector(),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Çekilen fotoğraflar
                    if (_capturedImages.isNotEmpty)
                      Expanded(
                        child: _buildCapturedImagesList(),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Text(
                            'Henüz fotoğraf çekilmedi',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: AppConfig.defaultPadding),
                    
                    // Çekim butonu
                    _buildCaptureButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kamera önizleme
  Widget _buildCameraPreview() {
    if (!_isCameraReady) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // TODO: Gerçek kamera önizlemesi ile değiştir
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Kamera Önizlemesi',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getEyeLabel(_selectedEye),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Göz seçici
  Widget _buildEyeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildEyeButton('right', Constants.rightEye, Icons.visibility),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildEyeButton('left', Constants.leftEye, Icons.visibility),
        ),
      ],
    );
  }

  /// Göz seçim butonu
  Widget _buildEyeButton(String eye, String label, IconData icon) {
    final isSelected = _selectedEye == eye;
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _selectedEye = eye;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppConfig.primaryColor : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : AppConfig.primaryColor,
        side: BorderSide(
          color: AppConfig.primaryColor,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  /// Çekilen fotoğraflar listesi
  Widget _buildCapturedImagesList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _capturedImages.length,
      itemBuilder: (context, index) {
        final image = _capturedImages[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Colors.grey[600]),
                    const SizedBox(height: 4),
                    Text(
                      image['eye'] == 'right' ? 'OD' : 'OS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _deleteImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppConfig.errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Çekim butonu
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppConfig.primaryColor, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isCapturing ? Colors.grey : AppConfig.primaryColor,
          ),
          child: _isCapturing
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 40,
                ),
        ),
      ),
    );
  }
}
